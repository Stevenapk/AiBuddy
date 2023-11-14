////
////  UIImageExtensionTests.swift
////  AiBuddyTests
////
////  Created by Steven Sullivan on 11/9/23.
////
//
//import XCTest
//@testable import AiBuddy
//
//class UIImageExtensionsTests: XCTestCase {
//
//    func testResizeToContactIconSize() {
//        let bundle = Bundle(for: type(of: self))
//        guard let url = bundle.url(forResource: "AppIcon", withExtension: "jpg") else {
//            XCTFail("Could not find test image resource")
//            return
//        }
//        guard let image = UIImage(contentsOfFile: url.path) else {
//            XCTFail("Could not load test image")
//            return
//        }
//
//        let resizedImage = image.resizeToContactIconSize
//        XCTAssertNotNil(resizedImage, "Resized image should not be nil")
//        XCTAssertEqual(resizedImage?.size, CGSize(width: 240, height: 240), "Resized image should have correct dimensions")
//    }
//
//    func testToCompressedData() {
//        let bundle = Bundle(for: type(of: self))
//        guard let url = bundle.url(forResource: "AppIcon", withExtension: "jpg") else {
//            XCTFail("Could not find test image resource")
//            return
//        }
//        guard let image = UIImage(contentsOfFile: url.path) else {
//            XCTFail("Could not load test image")
//            return
//        }
//
//        let compressedData = image.toCompressedData
//        XCTAssertNotNil(compressedData, "Compressed data should not be nil")
//        XCTAssertTrue(compressedData!.count < 100 * 1024, "Compressed data should be below 100KB")
//    }
//}
//
