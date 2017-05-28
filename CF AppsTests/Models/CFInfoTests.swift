import Foundation
import XCTest
import SwiftyJSON

@testable import CF_Apps

class CFInfoTests: XCTestCase {
    var info: CFInfo?

    override func setUp() {
        let path = Bundle(for: type(of: self)).path(forResource: "info", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        let json = JSON(data: data! as Data)

        self.info = CFInfo(json: json)
    }

    func testProperties() {
        if let info = self.info {
            XCTAssertEqual(info.apiVersion, "2.57.0")
            XCTAssertEqual(info.support, "http://support.cloudfoundry.com")
            XCTAssertEqual(info.description, "Cloud Foundry")
            XCTAssertEqual(info.authEndpoint, "https://login.test.io")
            XCTAssertEqual(info.tokenEndpoint, "https://uaa.test.io")
            XCTAssertEqual(info.apiVersion, "2.57.0")
            XCTAssertEqual(info.appSSHEndpoint, "ssh.test.io:2222")
            XCTAssertEqual(info.appSSHHostKeyFingerprint, "11:22:33:44:55:66:77:88:99:00:a1:a2:a3")
            XCTAssertEqual(info.appSSHOAuthClient, "ssh-proxy")
            XCTAssertEqual(info.loggingEndpoint, "wss://loggregator.test.io:443")
            XCTAssertEqual(info.dopplerLoggingEndpoint, "wss://doppler.test.io:443")
        } else {
            XCTFail()
        }
    }

    func testSerialize() {
        if let info = self.info {
            XCTAssertEqual(info.serialize(), [
                "support" : "http://support.cloudfoundry.com",
                "description" : "Cloud Foundry",
                "authorization_endpoint" : "https://login.test.io",
                "token_endpoint" : "https://uaa.test.io",
                "api_version" : "2.57.0",
                "app_ssh_endpoint" : "ssh.test.io:2222",
                "app_ssh_host_key_fingerprint" : "11:22:33:44:55:66:77:88:99:00:a1:a2:a3",
                "app_ssh_oauth_client" : "ssh-proxy",
                "logging_endpoint" : "wss://loggregator.test.io:443",
                "doppler_logging_endpoint" : "wss://doppler.test.io:443"
            ])
        } else {
            XCTFail()
        }
    }
}
