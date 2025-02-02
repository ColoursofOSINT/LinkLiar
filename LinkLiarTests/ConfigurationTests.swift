/*
 * Copyright (C) 2012-2021 halo https://io.github.com/halo/LinkLiar
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
@testable import LinkLiar

class ConfigurationTests: XCTestCase {

  func testDictionary() {
    let dictionary = ["one": 1]
    let configuration = Configuration(dictionary: dictionary)
    XCTAssertEqual(["one": 1], configuration.dictionary as! [String: Int])
  }

  func testRestrictDaemonWhenNothingSpecified() {
    let configuration = Configuration(dictionary: [:])
    XCTAssertFalse(configuration.settings.isRestrictedDaemon)
  }

  func testRestrictDaemonWhenTrue() {
    let dictionary = ["restrict_daemon": true]
    let configuration = Configuration(dictionary: dictionary)
    XCTAssertTrue(configuration.settings.isRestrictedDaemon)
  }

  func testRestrictDaemonWhenTruthyString() {
    let dictionary = ["restrict_daemon": "true"]
    let configuration = Configuration(dictionary: dictionary)
    XCTAssertFalse(configuration.settings.isRestrictedDaemon)
  }

  func testRestrictDaemonWhenFalse() {
    let dictionary = ["restrict_daemon": false]
    let configuration = Configuration(dictionary: dictionary)
    XCTAssertFalse(configuration.settings.isRestrictedDaemon)
  }

  func testIsForbiddenToRerandomizeWhenNothingSpecified() {
    let configuration = Configuration(dictionary: [:])
    XCTAssertFalse(configuration.settings.isForbiddenToRerandomize)
  }

  func testIsForbiddenToRerandomizeWhenTrue() {
    let dictionary = ["skip_rerandom": true]
    let configuration = Configuration(dictionary: dictionary)
    XCTAssertTrue(configuration.settings.isForbiddenToRerandomize)
  }

  func testIsForbiddenToRerandomizeWhenTruthyString() {
    let dictionary = ["skip_rerandom": "true"]
    let configuration = Configuration(dictionary: dictionary)
    XCTAssertFalse(configuration.settings.isForbiddenToRerandomize)
  }

  func testIsForbiddenToRerandomizeWhenFalse() {
    let dictionary = ["skip_rerandom": false]
    let configuration = Configuration(dictionary: dictionary)
    XCTAssertFalse(configuration.settings.isForbiddenToRerandomize)
  }

}
