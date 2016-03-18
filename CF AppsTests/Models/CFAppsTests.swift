//
//  CFAppsTests.swift
//  CF Apps
//
//  Created by Dwayne Forde on 2015-07-23.
//  Copyright (c) 2015 Dwayne Forde. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import DATAStack

@testable import CF_Apps

class CFAppsTests: XCTestCase {
    var dataStack: DATAStack?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        self.dataStack = DATAStack(modelName: "CFStore", bundle: NSBundle(forClass: CFAppsTests.self), storeType: DATAStackStoreType.InMemory)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.dataStack?.drop()
    }
    
    func makeApp() -> CFApp {
        let moc = dataStack!.mainContext
        let entity = NSEntityDescription.entityForName("CFApp", inManagedObjectContext: moc)
        return CFApp(entity: entity!, insertIntoManagedObjectContext: moc)
    }
    
    func testBuildPack() {
        let cfApp = makeApp()
        cfApp.buildpack = "moo"

        XCTAssertEqual(cfApp.buildpack!, "moo", "Something")
    }
    
    func testGuidType() {
        let cfApp = makeApp()
        cfApp.guid = ""
        
        XCTAssert((cfApp.guid as Any) is String, "GUID is a String")
    }
    
    func testNameType() {
        let cfApp = makeApp()
        cfApp.name = ""
        
        XCTAssert((cfApp.name as Any?) is String, "Name is a String")
    }
    
    func testPackageStateType() {
        let cfApp = makeApp()
        cfApp.packageState = ""
        
        XCTAssert((cfApp.packageState as Any) is String, "Package state is a String")
    }
    
    func testStateType() {
        let cfApp = makeApp()
        cfApp.state = ""
        
        XCTAssert((cfApp.state as Any) is String, "State is a String")
    }
    
    func testDiskQuotaType() {
        let cfApp = makeApp()
        cfApp.diskQuota = 0
        
        XCTAssert((cfApp.diskQuota as Any) is Int32, "Disk quota is an Int32")
    }
    
    func testMemoryType() {
        let cfApp = makeApp()
        cfApp.memory = 0
        
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
        
        XCTAssertEqual(cfApp.statusImageName(), "error", "Status name should be error if app state started and the package state is failed.")
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
