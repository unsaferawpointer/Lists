//
//  TagEntity.swift
//  iOS
//
//  Created by Anton Cherkasov on 15.11.2025.
//

import Foundation
import CoreData

@objc(TagEntity)
public class TagEntity: NSManagedObject {

}

extension TagEntity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<TagEntity> {
		return NSFetchRequest<TagEntity>(entityName: "TagEntity")
	}

	@NSManaged public var uuid: UUID?
	@NSManaged public var title: String?
	@NSManaged public var rawIcon: Int64
	@NSManaged public var rawOptions: Int64
	@NSManaged public var creationDate: Date?
	@NSManaged public var offset: Int64
	@NSManaged public var items: NSSet?
	@NSManaged public var filters: NSSet?

}

// MARK: - Reorderable
extension TagEntity: Reorderable { }

// MARK: - Identifiable
extension TagEntity: Identifiable {

	public var id: UUID {
		uuid!
	}
}

// MARK: - EntityConvertable
extension TagEntity: EntityConvertable {

	typealias Model = Tag

	var model: Tag {
		Tag(
			uuid: id,
			properties: .init(name: title ?? "Unknown Name", icon: icon)
		)
	}

	static func create(from model: Tag, in context: NSManagedObjectContext) -> Self {
		let entity = Self(context: context)

		entity.uuid = model.uuid
		entity.title = model.properties.name
		entity.icon = model.properties.icon
		entity.creationDate = .now

		return entity
	}
}

// MARK: - Computed Properties
extension TagEntity {

	var icon: Icon? {
		get {
			return Icon(rawValue: rawIcon)
		}
		set {
			self.rawIcon = newValue?.rawValue ?? 0
		}
	}

	var options: TagOptions {
		get {
			return .init(rawValue: rawOptions)
		}
		set {
			self.rawOptions = newValue.rawValue
		}
	}

	var isArchived: Bool {
		get {
			return options.contains(.isArchived)
		}
		set {
			guard newValue else {
				options.remove(.isArchived)
				return
			}
			options.insert(.isArchived)
		}
	}
}

// MARK: Generated accessors for items
extension TagEntity {

	@objc(addItemsObject:)
	@NSManaged public func addToItems(_ value: ItemEntity)

	@objc(removeItemsObject:)
	@NSManaged public func removeFromItems(_ value: ItemEntity)

	@objc(addItems:)
	@NSManaged public func addToItems(_ values: NSSet)

	@objc(removeItems:)
	@NSManaged public func removeFromItems(_ values: NSSet)

}

// MARK: Generated accessors for filters
extension TagEntity {

	@objc(addFiltersObject:)
	@NSManaged public func addToFilters(_ value: FilterEntity)

	@objc(removeFiltersObject:)
	@NSManaged public func removeFromFilters(_ value: FilterEntity)

	@objc(addFilters:)
	@NSManaged public func addToFilters(_ values: NSSet)

	@objc(removeFilters:)
	@NSManaged public func removeFromFilters(_ values: NSSet)

}
