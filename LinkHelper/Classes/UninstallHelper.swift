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

struct UninstallHelper {

  static func perform() {
    removePlist()
    removeExecutable()
    bootout()
  }

  private static func removePlist() {
    do {
      try FileManager.default.removeItem(atPath: Paths.helperPlistFile)
    } catch let error as NSError {
      Log.error("Could not delete Helper plist at \(Paths.helperPlistFile) is it there? \(error.localizedDescription)")
    }
  }

  private static func removeExecutable() {
    do {
      try FileManager.default.removeItem(atPath: Paths.helperExecutable)
    } catch let error as NSError {
      Log.info("Could not delete Helper executable at \(Paths.helperExecutable) is it there? \(error.localizedDescription)")
    }
  }

  private static func bootout() {
    let task = Process()
    task.launchPath = "/usr/bin/sudo"
    task.arguments = ["/bin/launchctl", "bootout", "system/\(Identifiers.helper.rawValue)"]
    Log.info("Booting out Privileged Helper...")
    task.launch()
  }

}
