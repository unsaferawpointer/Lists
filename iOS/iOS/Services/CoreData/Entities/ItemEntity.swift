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
	@NSManaged public var list: ListEntity?

	@NSManaged public var offset: Int64

	public override func awakeFromInsert() {
		super.awakeFromInsert()

		self.uuid = UUID()
		self.text = ""
		self.creationDate = .now
		self.list = nil
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

// MARK: - Calculated Properties
extension ItemEntity {

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
}

extension ItemEntity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<ItemEntity> {
		return NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
	}
}
