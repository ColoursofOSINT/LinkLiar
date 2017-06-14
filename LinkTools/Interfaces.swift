import SystemConfiguration

struct Interfaces {
  
  static func all(async: Bool) -> [Interface] {
    let interfaces = SCNetworkInterfaceCopyAll()
    var instances: [Interface] = []

    for interfaceRef in interfaces {
      guard let BSDName = SCNetworkInterfaceGetBSDName(interfaceRef as! SCNetworkInterface) else { continue }
      guard let displayName = SCNetworkInterfaceGetLocalizedDisplayName(interfaceRef as! SCNetworkInterface) else { continue }
      guard let hardMAC = SCNetworkInterfaceGetHardwareAddressString(interfaceRef as! SCNetworkInterface) else { continue }
      guard let type = SCNetworkInterfaceGetInterfaceType(interfaceRef as! SCNetworkInterface) else { continue }

      let interface = Interface(BSDName: BSDName as String, displayName: displayName as String, kind: type as String, hardMAC: hardMAC as String, async: async)
      if (interface.isSpoofable) { instances.append(interface) }
    }
    return instances
  }

}
