import Foundation
import XCTest
import DATAStack

@testable import CF_Apps

class CFOrgTests: XCTestCase {
    var dataStack: DATAStack?
    
    override func setUp() {
        super.setUp()
        dataStack = DATAStack(modelName: "CFStore", bundle: NSBundle(forClass: CFAppsTests.self), storeType: DATAStackStoreType.InMemory)
    }
    
    func makeOrg() -> CFOrg {
        let moc = dataStack!.mainContext
        let entity = NSEntityDescription.entityForName("CFOrg", inManagedObjectContext: moc)
        return CFOrg(entity: entity!, insertIntoManagedObjectContext: moc)
    }
    
    func testGuidType() {
        let cfOrg = makeOrg()
        
        XCTAssert((cfOrg.guid as Any) is String, "GUID is a String")
    }
    
    func testNameType() {
        let cfOrg = makeOrg()
        
        XCTAssert((cfOrg.name as Any) is String, "GUID is a String")
    }
}