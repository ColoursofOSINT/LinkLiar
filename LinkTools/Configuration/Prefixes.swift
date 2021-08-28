
extension Configuration {
  struct Prefixes {

    // MARK: Public Instance Properties

    var dictionary: [String: Any]

    // MARK: Initialization

    init(dictionary: [String: Any]) {
      self.dictionary = dictionary
    }

    // MARK: Public Instance Methods

    /**
     * Looks up which custom prefixes are specified as default.
     *
     * - returns: An Array of valid `MACPrefix`es or an empty Array if there are none.
     */
    var prefixesForDefaultInterface: [MACPrefix] {
      return prefixesForKey("default")
    }

    /**
     * Looks up which vendors are specified as default.
     * If there are absolutely no prefixes defined as default (neither vendors nor custom)
     * then the fallback Vendor (Apple) is returned.
     * Because we need always some prefix to use for randomization.
     * Also, this makes upgrading LinkLiar simpler (i.e. no vendors and no prefixes
     * defined in settings file means use some default and persist that as new setting)
     *
     * - returns: An Array of valid `Vendor`s or an empty Array if there are none.
     */
    var vendorsForDefaultInterface: [Vendor] {
      let vendors = vendorsForKey("default")
      let prefixes = prefixesForDefaultInterface

      guard (!prefixes.isEmpty || !vendors.isEmpty) else { return defaultVendors }

      return vendors
    }

    /**
     * Looks up which prefixes are specified for an Interface.
     *
     * - parameter hardMAC: The hardware MAC address of an Interface.
     *
     * - returns: An Array of valid `MACPrefix`es or an empty Array if there are none.
     */
    func prefixesForInterface(_ hardMAC: MACAddress) -> [MACPrefix] {
      return prefixesForKey(hardMAC.formatted)
    }

    /**
     * Looks up which vendors are specified for an Interface.
     *
     * - parameter hardMAC: The hardware MAC address of an Interface.
     *
     * - returns: An Array of valid `Vendor`s or an empty Array if there are none.
     */
    func vendorsForInterface(_ hardMAC: MACAddress) -> [Vendor] {
      let vendors = vendorsForKey(hardMAC.formatted)
      let prefixes = prefixesForInterface(hardMAC)

      guard (!prefixes.isEmpty || !vendors.isEmpty) else { return vendorsForDefaultInterface }

      return vendors
    }

    /**
     * Gathers all default prefixes that can be used for randomization.
     *
     * - parameter hardMAC: The hardware MAC address of an Interface.
     *
     * - returns: An Array of valid `MacPrefix`es that is never empty.
     */
    var calculatedPrefixesForDefaultInterface: [MACPrefix] {
      let customPrefixes = prefixesForDefaultInterface
      let vendorPrefixes = vendorsForDefaultInterface.flatMap { $0.prefixes }

      return customPrefixes + vendorPrefixes
    }

    /**
     * Gathers all prefixes for this Interface that can be used for randomization.
     * Falls back to the default if none are specified.
     *
     * - parameter hardMAC: The hardware MAC address of an Interface.
     *
     * - returns: An Array of valid `MacPrefix`es that is never empty.
     */

    func calculatedPrefixesForInterface(_ hardMAC: MACAddress) -> [MACPrefix] {
      let customPrefixes = prefixesForInterface(hardMAC)
      let vendorPrefixes = vendorsForInterface(hardMAC).flatMap { $0.prefixes }

      guard (!customPrefixes.isEmpty || !vendorPrefixes.isEmpty) else { return calculatedPrefixesForDefaultInterface }

      return customPrefixes + vendorPrefixes
    }

    // Internal Helper Methods

    private var defaultVendors: [Vendor] {
      // This `!` could probably only fail during development if no vendor is defined.
      return [Vendors.find("apple")!]
    }

    private func prefixesForKey(_ key: String) -> [MACPrefix] {
      guard let baseDictionary = dictionary[key] as? [String: String] else { return [] }
      guard let rawAddressesString = baseDictionary["prefixes"] else { return [] }
      let rawAddresses = rawAddressesString.split(separator: ",")

      let addresses = rawAddresses.compactMap { string -> MACPrefix? in
        let address = MACPrefix(String(string))
        return address.isValid ? address : nil
      }

      return addresses
    }

    private func vendorsForKey(_ key: String) -> [Vendor] {
      guard let baseDictionary = dictionary[key] as? [String: String] else { return [] }
      guard let rawVendorIDsString = baseDictionary["vendors"] else { return [] }
      let rawVendorIDs = rawVendorIDsString.split(separator: ",")

      let vendors = rawVendorIDs.compactMap { string -> Vendor? in
        return Vendors.find(String(string))
      }

      return vendors
    }
  }
}
