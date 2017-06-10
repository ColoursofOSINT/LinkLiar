import Foundation

struct Version {
  var major: Int
  var minor: Int
  var patch: Int

  init(_ version: String) {
    var v = version.components(separatedBy: ".") as Array
    major = Int(v[0])!
    minor = Int(v[1])!
    patch = Int(v[2])!
  }

  func version() -> String {
    return "<Version \(major).\(minor).\(patch)>"
  }
}