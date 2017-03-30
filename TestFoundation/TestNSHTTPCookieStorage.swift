// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

#if DEPLOYMENT_RUNTIME_OBJC || os(Linux)
    import Foundation
    import XCTest
#else
    import SwiftFoundation
    import SwiftXCTest
#endif

class TestNSHTTPCookieStorage: XCTestCase {

    enum _StorageType {
        case shared
        case groupContainer(String)
    }

    static var allTests: [(String, (TestNSHTTPCookieStorage) -> () throws -> Void)] {
        return [
            ("test_BasicStorageAndRetrieval", test_BasicStorageAndRetrieval),
            ("test_deleteCookie", test_deleteCookie),
            ("test_removeCookies", test_removeCookies),
            ("test_setCookiesForURL", test_setCookiesForURL),
            ("test_getCookiesForURL", test_getCookiesForURL),
            ("test_setCookiesForURLWithMainDocumentURL", test_setCookiesForURLWithMainDocumentURL),
            ("test_xdgImpl", test_xdgImpl),
        ]
    }

    func test_BasicStorageAndRetrieval() {
        basicStorageAndRetrieval(with: .shared)
        basicStorageAndRetrieval(with: .groupContainer("test"))
    }

    func test_deleteCookie() {
        deleteCookie(with: .shared)
        deleteCookie(with: .groupContainer("test"))
    }

    func test_removeCookies() {
        removeCookies(with: .shared)
        removeCookies(with: .groupContainer("test"))
    }

    func test_setCookiesForURL() {
        setCookiesForURL(with: .shared)
        setCookiesForURL(with: .groupContainer("test"))
    }

    func test_getCookiesForURL() {
        getCookiesForURL(with: .shared)
        getCookiesForURL(with: .groupContainer("test"))
    }

    func test_setCookiesForURLWithMainDocumentURL() {
        setCookiesForURLWithMainDocumentURL(with: .shared)
        setCookiesForURLWithMainDocumentURL(with: .groupContainer("test"))
    }

    func getStorage(for type: _StorageType) -> HTTPCookieStorage {
        switch type {
        case .shared:
            return HTTPCookieStorage.shared
        case .groupContainer(let identifier):
            return HTTPCookieStorage.sharedCookieStorage(forGroupContainerIdentifier: identifier)
        }
    }

    func basicStorageAndRetrieval(with storageType: _StorageType) {
        let storage = getStorage(for: storageType)

        let simpleCookie = HTTPCookie(properties: [
           .name: "TestCookie1",
           .value: "Test value @#$%^$&*99",
           .path: "/",
           .domain: "swift.org",
           .expires: Date(timeIntervalSince1970: 1475767775) //expired cookie
        ])!

        storage.setCookie(simpleCookie)
        XCTAssertEqual(storage.cookies!.count, 0)

        let simpleCookie0 = HTTPCookie(properties: [   //no expiry date
           .name: "TestCookie1",
           .value: "Test @#$%^$&*99",
           .path: "/",
           .domain: "swift.org",
        ])!

        storage.setCookie(simpleCookie0)
        XCTAssertEqual(storage.cookies!.count, 1)

        let simpleCookie1 = HTTPCookie(properties: [
           .name: "TestCookie1",
           .value: "Test @#$%^$&*99",
           .path: "/",
           .domain: "swift.org",
        ])!

        storage.setCookie(simpleCookie1)
        XCTAssertEqual(storage.cookies!.count, 1) //test for replacement

        let simpleCookie2 = HTTPCookie(properties: [
           .name: "TestCookie1",
           .value: "Test @#$%^$&*99",
           .path: "/",
           .domain: "example.com",
        ])!

        storage.setCookie(simpleCookie2)
        XCTAssertEqual(storage.cookies!.count, 2)
    }

    func deleteCookie(with storageType: _StorageType) {
        let storage = getStorage(for: storageType)

        let simpleCookie2 = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test @#$%^$&*99",
            .path: "/",
            .domain: "example.com",
            ])!

        let simpleCookie = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test value @#$%^$&*99",
            .path: "/",
            .domain: "swift.org",
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 1000)
            ])!
        storage.setCookie(simpleCookie)
        XCTAssertEqual(storage.cookies!.count, 2)

        storage.deleteCookie(simpleCookie)
        storage.deleteCookie(simpleCookie2)
        XCTAssertEqual(storage.cookies!.count, 0)
    }

    func removeCookies(with storageType: _StorageType) {
        let storage = getStorage(for: storageType)
        let past = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate - 120)
        let future = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate + 120)
        let simpleCookie = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test value @#$%^$&*99",
            .path: "/",
            .domain: "swift.org",
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 1000)
            ])!
        storage.setCookie(simpleCookie)
        XCTAssertEqual(storage.cookies!.count, 1)
        storage.removeCookies(since: future)
        XCTAssertEqual(storage.cookies!.count, 1)
        storage.removeCookies(since: past)
        XCTAssertEqual(storage.cookies!.count, 0)
    }

    func setCookiesForURL(with storageType: _StorageType) {
        let storage = getStorage(for: storageType)
        let url = URL(string: "https://swift.org")
        let simpleCookie = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test @#$%^$&*99",
            .path: "/",
            .domain: "example.com",
            ])!

        let simpleCookie1 = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test value @#$%^$&*99",
            .path: "/",
            .domain: "swift.org",
            .expires: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 1000)
            ])!

        storage.setCookies([simpleCookie, simpleCookie1], for: url, mainDocumentURL: nil)
        XCTAssertEqual(storage.cookies!.count, 1)
    }

    func getCookiesForURL(with storageType: _StorageType) {
        let storage = getStorage(for: storageType)
        let url = URL(string: "https://swift.org")
        XCTAssertEqual(storage.cookies(for: url!)!.count, 1)
    }

    func setCookiesForURLWithMainDocumentURL(with storageType: _StorageType) {
        let storage = getStorage(for: storageType)
        storage.cookieAcceptPolicy = .onlyFromMainDocumentDomain
        let url = URL(string: "https://swift.org/downloads")
        let mainUrl = URL(string: "http://ci.swift.org")
        let simpleCookie = HTTPCookie(properties: [
            .name: "TestCookie1",
            .value: "Test@#$%^$&*99khnia",
            .path: "/",
            .domain: "swift.org",
        ])!
        storage.setCookies([simpleCookie], for: url, mainDocumentURL: mainUrl)
        XCTAssertEqual(storage.cookies(for: url!)!.count, 1)

        let url1 = URL(string: "https://dt.swift.org/downloads")
        let simpleCookie1 = HTTPCookie(properties: [
            .name: "TestCookie3",
            .value: "Test@#$%^$&*999189",
            .path: "/",
            .domain: "swift.org",
        ])!
        storage.setCookies([simpleCookie1], for: url1, mainDocumentURL: mainUrl)
        XCTAssertEqual(storage.cookies(for: url1!)!.count, 0)
    }
    
    func test_xdgImpl() {
        let expected = FileManager.default.currentDirectoryPath
        print("File: expected : \(expected)") 
        let bundle = Bundle.main
        print("Path: \(bundle.bundlePath)")
        print("executablePath: \(bundle.executablePath)")
        let url = bundle.url(forAuxiliaryExecutable: "xdgTestHelper")
        print("url: \(url)")
    let task = Process()

//    task.launchPath = "/root/mamatha/executable/TestXDG"
    task.launchPath = "/root/mamatha/swiftBuild/build/buildbot_linux/foundation-linux-x86_64/xdgTestHelper/xdgTestHelper"
    var dict = ProcessInfo.processInfo.environment
    dict["XDG_CONFIG_HOME"] =  "/root/mamatha"
    dict["XDG_DATA_HOME"] =  "/root/data"
   
    task.environment = dict
    // Create a Pipe and make the task
    // put all the output there
    let pipe = Pipe()
    task.standardOutput = pipe

    // Launch the task
    task.launch()
    task.waitUntilExit()
    let status = task.terminationStatus
    print("Status: \(status)")

    // Get the data
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

    print(output!)
    }
}
