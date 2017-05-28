import UIKit
import XCTest
import CoreData
import DATAStack

@testable import CF_Apps

class CFAppsTests: XCTestCase {
    var dataStack: DATAStack?
    
    override func setUp() {
        super.setUp()
        
        self.dataStack = DATAStack(modelName: "CFStore", bundle: Bundle(for: CFAppsTests.self), storeType: DATAStackStoreType.inMemory)
    }
    
    override func tearDown() {
        super.tearDown()
        
        try! self.dataStack?.drop()
    }
    
    func makeApp() -> CFApp {
        let moc = dataStack!.mainContext
        let entity = NSEntityDescription.entity(forEntityName: "CFApp", in: moc)
        return CFApp(entity: entity!, insertInto: moc)
    }
    
    func testBuildPack() {
        let cfApp = makeApp()
        cfApp.buildpack = "moo"

        XCTAssertEqual(cfApp.buildpack!, "moo", "Something")
    }
    
    func testGuidType() {
        let cfApp = makeApp()
        
        XCTAssert((cfApp.guid as Any) is String, "GUID is a String")
    }
    
    func testNameType() {
        let cfApp = makeApp()
        
        XCTAssert((cfApp.name as Any?) is String, "Name is a String")
    }
    
    func testPackageStateType() {
        let cfApp = makeApp()
        
        XCTAssert((cfApp.packageState as Any) is String, "Package state is a String")
    }
    
    func testStateType() {
        let cfApp = makeApp()
        
        XCTAssert((cfApp.state as Any) is String, "State is a String")
    }
    
    func testDiskQuotaType() {
        let cfApp = makeApp()

        XCTAssert((cfApp.diskQuota as Any) is Int32, "Disk quota is an Int32")
    }
    
    func testMemoryType() {
        let cfApp = makeApp()
        
        XCTAssert((cfApp.memory as Any) is Int32, "Disk quota is an Int32")
    }
    
    func testEmptyActiveBuildpack() {
        let cfApp = makeApp()
        
        XCTAssertEqual(cfApp.activeBuildpack(), "", "Active buildpack is empty when there is no buildpack information")
    }
    
    func testActiveBuildpackViaBuildpack() {
        let cfApp = makeApp()
        cfApp.buildpack = "someBuildpack"
        
        XCTAssertEqual(cfApp.activeBuildpack(), "someBuildpack", "Active buildpack is buildpack when provided and there is no detected buildpack")
    }
    
    func testActiveBuildpackViaDetectedBuildpack() {
        let cfApp = makeApp()
        cfApp.buildpack = "someBuildpack"
        cfApp.detectedBuildpack = "someDetectedBuildpack"
        
        XCTAssertEqual(cfApp.activeBuildpack(), "someDetectedBuildpack", "Active buildpack is detected buildpack when provided")
    }
    
    func testStatusImageNameError() {
        let cfApp = makeApp()
        cfApp.state = "STARTED"
        cfApp.packageState = "FAILED"
        
        XCTAssertEqual(cfApp.statusImageName(), "errored", "Status name should be error if app state started and the package state is failed.")
    }
    
    func testStatusImageNameStarted() {
        let cfApp = makeApp()
        cfApp.state = "STARTED"
        cfApp.packageState = "NOFAIL"
        
        XCTAssertEqual(cfApp.statusImageName(), "started", "Status name should be error if app state started and the package state is not failed")
    }
    
    func testStatusImageNameStopped() {
        let cfApp = makeApp()
        cfApp.state = "NOSTART"
        
        XCTAssertEqual(cfApp.statusImageName(), "stopped", "Status name should be stopped if state is not started")
    }
}
