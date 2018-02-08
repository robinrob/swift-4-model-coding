import Foundation
import CoreData


let context = getBackgroundContextForTesting(forModelType: PersonModel.self)

@objc(PersonModel)
final class PersonModel: NSManagedObject, Encodable, Decodable {
    init(from decoder: Decoder) {
        super.init(entity: NSEntityDescription.entity(forEntityName: "PersonModel", in: context)!, insertInto: context)
        
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(type(of: self.name), forKey: .name)
            self.age = try container.decode(type(of: self.age), forKey: .age)
        } catch {
            print("decoding error: \(error)")
        }
    }
    
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.age, forKey: .age)
    }
    
    enum CodingKeys: CodingKey {
        case name
        case age
    }
}

public class CodableTest {
    class CodableClass: Codable {
        var name: String
        var age: Int
        
        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }
    
    struct CodableStruct: Codable {
        var name: String
        var age: Int
    }
    
    static func encodeClassAsJSON() {
        let obj = CodableClass(name: "Robin", age: 30)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(obj)
            let json = String(data: data, encoding: .utf8)!
            print("json: \(json)")
        } catch {
            print("encoding error: \(error)")
        }
    }
    
    static func decodeClassFromJSON() {
        let json = "{\"name\":\"Robin\",\"age\":30}"
        
        do {
            let obj = try JSONDecoder().decode(CodableClass.self, from: json.data(using: .utf8)!)
            print("obj.name: \(obj.name)")
            print("person.age: \(String(obj.age))")
        } catch {
            print("decoding error: \(error)")
        }
    }
    
    static func encodeStructAsJSON() {
        let obj = CodableStruct(name: "Robin", age: 30)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(obj)
            let json = String(data: data, encoding: .utf8)!
            print("json: \(json)")
        } catch {
            print("encoding error: \(error)")
        }
    }
    
    static func decodeStructFromJSON() {
        let json = "{\"name\":\"Robin\",\"age\":30}"
        
        do {
            let obj = try JSONDecoder().decode(CodableStruct.self, from: json.data(using: .utf8)!)
            print("obj.name: \(obj.name)")
            print("person.age: \(String(obj.age))")
        } catch {
            print("encoding error: \(error)")
        }
    }
    
    static func encodeModelAsJSON() {
        let obj = NSEntityDescription.insertNewObject(
            forEntityName: "PersonModel",
            into: context
            ) as! PersonModel
        
        obj.name = "Robin"
        obj.age = 30
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(obj)
            let json = String(data: data, encoding: .utf8)!
            print("json: \(json)")
        } catch {
            print("encoding error: \(error)")
        }
    }
    
    static func decodeModelFromJSON() {
        let json = "{\"name\": \"Robin\",\"age\": 30}"
        do {
            let person = try JSONDecoder().decode(PersonModel.self, from: json.data(using: .utf8)!)
            try context.save()
            print("person.name: \(person.name!)")
            print("person.age: \(String(person.age))")
        } catch {
            print("decoding error: \(error)")
        }
    }

    static func run() {
        encodeClassAsJSON()
        print()
        decodeClassFromJSON()
        print()
        encodeStructAsJSON()
        print()
        decodeStructFromJSON()
        print()
        encodeModelAsJSON()
        print()
        decodeModelFromJSON()
    }
}

func getBackgroundContextForTesting(forModelType modelType: AnyClass) -> NSManagedObjectContext {
    let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: modelType)] )!
    
    let container = NSPersistentContainer(name: "PersonModel", managedObjectModel: managedObjectModel)
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { (description, error) in
        precondition( description.type == NSInMemoryStoreType )
        
        if let error = error {
            fatalError("Creating in-memory coordinator failed \(error)")
        }
    }
    return container.newBackgroundContext()
}

