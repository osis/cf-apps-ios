import Foundation
import XCTest
import DATAStack

@testable import CF_Apps

class CFStoreTests: XCTestCase {
    var dataStack: DATAStack?
    
    override func setUp() {
        super.setUp()
        
        dataStack = DATAStack(modelName: "CFStore", bundle: Bundle(for: CFAppsTests.self), storeType: DATAStackStoreType.inMemory)
        syncApps()
    }
    
    override func tearDown() {
        super.tearDown()
        
        try! self.dataStack?.drop()
    }
    
    func syncApps() {
        let exp = expectation(description: "Apps Sync")
        let data:[[String : Any]] = [
            ["name":"testApp", "guid":"testGuid", "created_at":"2016-06-08T16:41:45Z"],
            ["name":"testApp1", "guid":"testGuid1", "created_at":"2016-06-08T16:4:46Z"]
        ]
        CFStore(dataStack: self.dataStack!).syncApps(data as [[String : AnyObject]], clear: false, completion: { (error) in
            exp.fulfill()
        })
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testSyncApps() {
        let apps = CFStore(dataStack: self.dataStack!).fetchApps()
        
        XCTAssertEqual(apps.count, 2)
        XCTAssertEqual(apps[0].name, "testApp")
        XCTAssertEqual(apps[1].name, "testApp1")
    }
    
    func testSyncAppUpdate() {
        let exp = expectation(description: "Update App")
        let guid = "testGuid1"
        let data:[String : Any] = ["name":"testAppUpdated", "guid":guid]
        
        CFStore(dataStack: self.dataStack!).syncApp(data, guid: guid, completion: { (error) in
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        let apps = CFStore(dataStack: self.dataStack!).fetchApps()
        
        XCTAssertEqual(apps.count, 2)
        XCTAssertEqual(apps[1].name, "testAppUpdated")
    }
    
    func syncSpaces() {
        let exp = expectation(description: "Spaces Sync")
        let data:[[String : Any]] = [
            ["name":"testSpace", "guid":"testGuid", "created_at":"2016-06-08T16:41:45Z"],
            ["name":"testSpace1", "guid":"testGuid1", "created_at":"2016-06-08T16:41:46Z"]
        ]
        CFStore(dataStack: self.dataStack!).syncSpaces(data, completion: { (error) in
            exp.fulfill()
        })
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFetchSpaces() {
        syncSpaces()
        
        do {
            let space = try CFStore(dataStack: self.dataStack!).fetchSpace("testGuid1")
            XCTAssertEqual(space!.name, "testSpace1")
        } catch {
            XCTFail()
        }
    }
    
    func testFetchSpacesNil() {
        syncSpaces()
        
        do {
            let space = try CFStore(dataStack: self.dataStack!).fetchSpace("nil")
            XCTAssertNil(space)
        } catch {
            XCTFail()
        }
    }
}
