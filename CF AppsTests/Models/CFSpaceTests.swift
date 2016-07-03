import Foundation
import XCTest
import DATAStack

@testable import CF_Apps

class CFSpaceTests: XCTestCase {
    var dataStack: DATAStack?
    
    override func setUp() {
        super.setUp()
        
        dataStack = DATAStack(modelName: "CFStore", bundle: NSBundle(forClass: CFAppsTests.self), storeType: DATAStackStoreType.InMemory)
    }
    
    func makeSpace() -> CFSpace {
        let moc = dataStack!.mainContext
        let entity = NSEntityDescription.entityForName("CFSpace", inManagedObjectContext: moc)
        return CFSpace(entity: entity!, insertIntoManagedObjectContext: moc)
    }
    
    func testGuidType() {
        let cfSpace = makeSpace()
        
        XCTAssert((cfSpace.guid as Any) is String, "GUID is a String")
    }
    
    func testNameType() {
        let cfSpace = makeSpace()
        
        XCTAssert((cfSpace.name as Any) is String, "GUID is a String")
    }
}