//
//  ListEntity.swift
//  iOS
//
//  Created by Anton Cherkasov on 22.11.2025.
//

import Foundation
import CoreData

@objc(ListEntity)
public class ListEntity: NSManagedObject { }

extension ListEntity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<ListEntity> {
		return NSFetchRequest<ListEntity>(entityName: "ListEntity")
	}

	@NSManaged public var creationDate: Date?
	@NSManaged public var rawIcon: Int64
	@NSManaged public var rawOptions: Int64
	@NSManaged public var title: String?
	@NSManaged public var uuid: UUID?
	@NSManaged public var offset: Int64
	@NSManaged public var items: NSSet?
}

// MARK: - Reorderable
extension ListEntity: Reorderable { }

// MARK: - Identifiable
extension ListEntity: Identifiable {

	public var id: UUID {
		uuid!
	}
}

// MARK: - EntityConvertable
extension ListEntity: EntityConvertable {

	typealias Model = List

	var model: List {
		List(
			uuid: id,
			properties: .init(name: title ?? "Unknown Name", icon: icon)
		)
	}

	static func create(from model: List, in context: NSManagedObjectContext) -> Self {
		let entity = Self(context: context)

		entity.uuid = model.uuid
		entity.title = model.properties.name
		entity.icon = model.properties.icon
		entity.creationDate = .now

		return entity
	}
}

// MARK: - Computed Properties
extension ListEntity {

	var icon: Icon? {
		get {
			return Icon(rawValue: rawIcon)
		}
		set {
			self.rawIcon = newValue?.rawValue ?? 0
		}
	}

	var options: ListOptions {
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
extension ListEntity {

	@objc(addItemsObject:)
	@NSManaged public func addToItems(_ value: ItemEntity)

	@objc(removeItemsObject:)
	@NSManaged public func removeFromItems(_ value: ItemEntity)

	@objc(addItems:)
	@NSManaged public func addToItems(_ values: NSSet)

	@objc(removeItems:)
	@NSManaged public func removeFromItems(_ values: NSSet)

}
