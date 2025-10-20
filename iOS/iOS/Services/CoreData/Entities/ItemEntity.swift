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
	@NSManaged public var list: ListEntity?

	public override func awakeFromInsert() {
		super.awakeFromInsert()

		self.uuid = UUID()
		self.text = ""
		self.creationDate = .now
		self.list = nil
	}
}

extension ItemEntity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<ItemEntity> {
		return NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
	}
}
