//
//  ListEntity+CoreDataClass.swift
//  
//
//  Created by Anton Cherkasov on 19.10.2025.
//
//

public import Foundation
public import CoreData

public typealias ListEntityCoreDataClassSet = NSSet
public typealias ListEntityCoreDataPropertiesSet = NSSet

@objc(ListEntity)
public class ListEntity: NSManagedObject {

	@NSManaged public var name: String?
	@NSManaged public var uuid: UUID?
	@NSManaged public var rawIcon: Int64
	@NSManaged public var creationDate: Date?
	@NSManaged public var items: NSSet?

	@NSManaged public var offset: Int64
	@NSManaged public var rawOptions: Int64

	public override func awakeFromInsert() {
		super.awakeFromInsert()

		self.name = ""
		self.uuid = UUID()
		self.rawIcon = 0
		self.creationDate = .now
		self.offset = 0
		self.rawOptions = 0
	}
}

// MARK: - Identifiable
extension ListEntity: Identifiable {

	public var id: UUID {
		uuid!
	}
}

extension ListEntity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<ListEntity> {
		return NSFetchRequest<ListEntity>(entityName: "ListEntity")
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
