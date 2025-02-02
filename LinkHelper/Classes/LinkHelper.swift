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

import Foundation

class LinkHelper: NSObject {

  static var version: Version = {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      return Version(version)
    }
    return Version("?.?.?")
  }()

  // MARK Private Properties

  lazy var listener: NSXPCListener = {
    let listener = NSXPCListener(machServiceName:Identifiers.helper.rawValue)
    listener.delegate = self
    return listener
  }()

  var shouldQuit = false

  // MARK Instance Methods

  func listen(){
    Log.debug("Helper \(LinkHelper.version.formatted) says hello")
    listener.resume() // Tell the XPC listener to start processing requests.

    while !shouldQuit {
      RunLoop.current.run(until: Date.init(timeIntervalSinceNow: 1))
    }
    Log.debug("Helper shutting down now.")
  }

}

// MARK: - HelperProtocol
extension LinkHelper: HelperProtocol {

  func version(reply: (String) -> Void) {
    reply(LinkHelper.version.formatted)
  }

  func install(pristineDaemonExecutablePath: String, reply: (Bool) -> Void) {
    ConfigDirectory.create()
    UninstallDaemon.perform()
    InstallDaemon.perform(pristineExecutablePath: pristineDaemonExecutablePath)
    reply(BootDaemon.bootstrap())
  }

  func uninstall(reply: (Bool) -> Void) {
    let _ = BootDaemon.bootout()
    UninstallDaemon.perform()
    ConfigDirectory.remove()
    UninstallHelper.perform()
    reply(true) // <- Famous last words
  }

  func createConfigDirectory(reply: (Bool) -> Void) {
    ConfigDirectory.create()
    reply(true)
  }

  func removeConfigDirectory(reply: (Bool) -> Void) {
    ConfigDirectory.remove()
    reply(true)
  }

  func installDaemon(pristineDaemonExecutablePath: String, reply: (Bool) -> Void) {
    Log.debug("Going to prophylactically uninstall and then install daemon...")
    UninstallDaemon.perform()
    InstallDaemon.perform(pristineExecutablePath: pristineDaemonExecutablePath)
    reply(BootDaemon.bootstrap())
  }

  func activateDaemon(reply: (Bool) -> Void) {
    reply(BootDaemon.bootstrap())
  }

  func deactivateDaemon(reply: (Bool) -> Void) {
    reply(BootDaemon.bootout())
  }

  func uninstallDaemon(reply: (Bool) -> Void) {
    let success = BootDaemon.bootout()
    UninstallDaemon.perform()
    reply(success)
  }

  func uninstallHelper(reply: (Bool) -> Void) {
    UninstallHelper.perform()
    reply(true)
  }

}

// MARK: - NSXPCListenerDelegate
extension LinkHelper: NSXPCListenerDelegate {

  func listener(_ listener:NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
    newConnection.exportedInterface = NSXPCInterface(with: HelperProtocol.self)
    newConnection.exportedObject = self;
    newConnection.invalidationHandler = (() -> Void)? {
      Log.debug("Helper lost connection, queuing up for shutdown...")
      self.shouldQuit = true
    }
    newConnection.resume()
    return true
  }

}
