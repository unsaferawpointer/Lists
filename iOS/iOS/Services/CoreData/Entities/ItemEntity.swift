//
//  ItemEntity+CoreDataClass.swift
//  
//
//  Created by Anton Cherkasov on 19.10.2025.
//
//

public import Foundation
public import CoreData

public typealias ItemEntityCoreDataClassSet = NSSet
public typealias ItemEntityCoreDataPropertiesSet = NSSet

@objc(ItemEntity)
public class ItemEntity: NSManagedObject {

	@NSManaged public var uuid: UUID?
	@NSManaged public var text: String?
	@NSManaged public var creationDate: Date?
	@NSManaged public var rawOptions: Int64
	@NSManaged public var tags: NSSet?

	@NSManaged public var offset: Int64

	public override func awakeFromInsert() {
		super.awakeFromInsert()

		self.uuid = UUID()
		self.text = ""
		self.creationDate = .now
		self.rawOptions = 0

		self.offset = 0
	}
}

// MARK: - Identifiable
extension ItemEntity: Identifiable {

	public var id: UUID {
		uuid!
	}
}

// MARK: - Reorderable
extension ItemEntity: Reorderable { }

// MARK: - EntityConvertable
extension ItemEntity: EntityConvertable {

	var model: Item {
		Item(
			uuid: id,
			properties: .init(
				title: text ?? "Unknown title",
				isStrikethrough: isStrikethrough,
				tags: tagModels
			)
		)
	}

	static func create(from model: Item, in context: NSManagedObjectContext) -> Self {
		let entity = Self(context: context)

		entity.uuid = model.uuid
		entity.text = model.properties.title
		entity.isStrikethrough = model.properties.isStrikethrough

		return entity
	}
}

// MARK: - Calculated Properties
extension ItemEntity {

	var tagModels: [Tag] {
		get {
			return (tags as? Set<TagEntity>)?
				.sorted { lhs, rhs in
					lhs.offset < rhs.offset
				}.map(\.model) ?? []
		}
	}

	var options: ItemOptions {
		get {
			return .init(rawValue: rawOptions)
		}
		set {
			self.rawOptions = newValue.rawValue
		}
	}

	var isStrikethrough: Bool {
		get {
			return options.contains(.strikethrough)
		}
		set {
			guard newValue else {
				options.remove(.strikethrough)
				return
			}
			options.insert(.strikethrough)
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

extension ItemEntity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<ItemEntity> {
		return NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
	}
}

// MARK: Generated accessors for tags
extension ItemEntity {

	@objc(addTagsObject:)
	@NSManaged public func addToTags(_ value: TagEntity)

	@objc(removeTagsObject:)
	@NSManaged public func removeFromTags(_ value: TagEntity)

	@objc(addTags:)
	@NSManaged public func addToTags(_ values: NSSet)

	@objc(removeTags:)
	@NSManaged public func removeFromTags(_ values: NSSet)

}
