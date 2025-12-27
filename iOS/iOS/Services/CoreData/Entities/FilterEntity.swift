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

	// MARK: - Raw Data

	@NSManaged public var rawIcon: Int64
	@NSManaged public var rawItemOptions: NSNumber?
	@NSManaged public var rawTagsMatchType: NSNumber?

	// MARK: - Relationship

	@NSManaged public var tags: NSSet?

}

// MARK: - Identifiable
extension FilterEntity: Identifiable {

	public var id: UUID {
		uuid!
	}
}

// MARK: - ManagedObject
extension FilterEntity: ManagedObject {

	typealias Properties = Filter.Properties

	typealias Relationships = Filter.Relationships

	static func createObject(in context: NSManagedObjectContext, with properties: Filter.Properties, relationships: Relationships?) {
		let newEntity = FilterEntity(context: context)
		newEntity.uuid = UUID()
		newEntity.update(with: properties, relationships: relationships)
	}

	func update(with properties: Filter.Properties, relationships: Filter.Relationships?) {
		self.title = properties.name
		self.icon = properties.icon
		self.itemOptions = properties.itemOptions

		guard
			let context = managedObjectContext,
			let tags = relationships?.tags.map(\.self),
			let rawTagsMatchType = relationships?.tagsMatchType?.rawValue
		else {
			self.tags = nil
			self.rawTagsMatchType = nil
			return
		}

		let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
		request.predicate = NSPredicate(format: "ANY uuid in %@", argumentArray: [tags])

		guard let entities = try? context.fetch(request) else {
			return
		}
		self.tags = NSSet(array: entities)
		self.rawTagsMatchType = NSNumber(value: rawTagsMatchType)
	}

	var object: Object<Properties, Relationships> {
		let properties = Properties(name: title ?? "", icon: icon, itemOptions: itemOptions)
		let relationships = Relationships(
			tagsMatchType: .init(rawValue: rawTagsMatchType?.int64Value ?? 0),
			tags: Set((tags as? Set<TagEntity>)?.map(\.id) ?? [])
		)
		return Object(id: id, properties: properties, relationships: relationships)
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
				itemOptions: itemOptions
			),
			tags: Set((tags as? Set<TagEntity>)?.map(\.id) ?? [])
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

	var tagsFilter: TagsFilter? {
		get {
			guard
				let tags = self.tags as? Set<TagEntity>, let rawMatchType = rawTagsMatchType?.int64Value,
				let matchType = TagsFilter.MatchType(rawValue: rawMatchType)
			else {
				return nil
			}
			return TagsFilter(matchType: matchType, tags: tags.map(\.id))
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

	var properties: Filter.Properties {
		get {
			Filter.Properties(
				name: title ?? "",
				icon: icon,
				itemOptions: itemOptions
			)
		}
		set {
			self.title = newValue.name
			self.icon = newValue.icon
			self.itemOptions = newValue.itemOptions
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
