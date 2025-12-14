//
//  FilterEntity+CoreDataProperties.swift
//
//
//  Created by Anton Cherkasov on 13.12.2025.
//
//

public import Foundation
public import CoreData

@objc(FilterEntity)
public class FilterEntity: NSManagedObject { }

extension FilterEntity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<FilterEntity> {
		return NSFetchRequest<FilterEntity>(entityName: "FilterEntity")
	}

	@NSManaged public var uuid: UUID?
	@NSManaged public var title: String?
	@NSManaged public var text: String?
	@NSManaged public var rawIcon: Int64
	@NSManaged public var rawItemOptions: NSNumber?
	@NSManaged public var tags: NSSet?

}

// MARK: - Identifiable
extension FilterEntity: Identifiable {

	public var id: UUID {
		uuid!
	}
}

// MARK: - EntityConvertable
extension FilterEntity: EntityConvertable {

	typealias Model = Filter

	var model: Filter {
		Filter(
			uuid: id,
			properties: .init(
				name: title ?? "",
				icon: icon,
				strikethrough: itemOptions?.contains(.strikethrough),
				tags: Set((tags as? Set<TagEntity>)?.map(\.id) ?? [])
			)
		)
	}

	static func create(from model: Filter, in context: NSManagedObjectContext) -> Self {
		let entity = Self(context: context)

		entity.uuid = model.uuid
		entity.title = model.properties.name
		entity.icon = model.properties.icon

		return entity
	}
}

// MARK: - Computed Properties
extension FilterEntity {

	var icon: Icon? {
		get {
			return Icon(rawValue: rawIcon)
		}
		set {
			self.rawIcon = newValue?.rawValue ?? 0
		}
	}

	var itemOptions: ItemOptions? {
		get {
			guard let number = rawItemOptions?.int64Value else {
				return nil
			}
			return .init(rawValue: number)
		}
		set {
			guard let newValue else {
				self.rawItemOptions = nil
				return
			}
			self.rawItemOptions = NSNumber(value: newValue.rawValue)
		}
	}
}

// MARK: Generated accessors for tags
extension FilterEntity {

	@objc(addTagsObject:)
	@NSManaged public func addToTags(_ value: TagEntity)

	@objc(removeTagsObject:)
	@NSManaged public func removeFromTags(_ value: TagEntity)

	@objc(addTags:)
	@NSManaged public func addToTags(_ values: NSSet)

	@objc(removeTags:)
	@NSManaged public func removeFromTags(_ values: NSSet)

}
