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


extension Configuration {
  struct KnownInterface {

    // MARK: Initialization

    init(dictionary: [String:Any]) {
      self.dictionary = dictionary
    }

    // MARK: Public Instance Properties

    var dictionary: [String:Any]

    var defaultAction: Interface.Action {
      return UnknownInterface(dictionary: dictionary).action
    }

    // MARK: Public Instance Methods

    /**
     * Looks up which action has been defined.
     *
     * Returns `nil` if no valid action was defined.
     *
     * - returns: An `Interface.Action`.
     */
    func action(_ hardMAC: MACAddress) -> Interface.Action? {
      guard let interfaceDictionary = dictionary[hardMAC.formatted] as? [String: String] else { return nil }
      guard let actionName = interfaceDictionary["action"] else { return nil }

      return Interface.Action(rawValue: actionName) ?? nil
    }

    /**
     * Looks up which action has been defined.
     *
     * If no valid action was defined, it returns `Interface.Action.default` as fallback.
     *
     * - returns: An `Interface.Action`.
     */
    func calculatedAction(_ hardMAC: MACAddress) -> Interface.Action {
      guard let interfaceDictionary = dictionary[hardMAC.formatted] as? [String: String] else { return defaultAction }
      guard let actionName = interfaceDictionary["action"] else { return defaultAction }

      return Interface.Action(rawValue: actionName) ?? defaultAction
    }

    /**
     * Looks up which MAC address has been defined.
     * This is only useful if the action is "specify".
     *
     * - returns: A valid `MACAddress` or `nil` if no valid address was specified.
     */
    func address(_ hardMAC: MACAddress) -> MACAddress? {
      guard let defaultDictionary = dictionary[hardMAC.formatted] as? [String: String] else { return nil }
      guard let rawAddress = defaultDictionary["address"] else { return nil }

      let address = MACAddress(rawAddress)
      return address.isValid ? address : nil
    }

    /**
     * Looks up which MAC address has been defined.
     * If none has been defined, returns the default specified address.
     *
     * - returns: A valid `MACAddress` or `nil` if no valid address was specified.
     */
    func calculatedAddress(_ hardMAC: MACAddress) -> MACAddress? {
      guard let address = self.address(hardMAC) else {
        return UnknownInterface(dictionary: dictionary).address
      }

      return address
    }

    /**
     * Looks up the defined exceptioning MAC address for an Interface.
     * This is useful to enforce re-randomization. Because the deamon
     * would usually not re-randomize and already random Interface.
     *
     * - parameter hardMAC: The hardware MAC address of an Interface.
     *
     * - returns: A valid `MACAddress` or `nil` if no valid address was specified.
     */
    func exceptionAddress(_ hardMAC: MACAddress) -> MACAddress? {
      guard let interfaceDictionary = dictionary[hardMAC.formatted] as? [String: String] else { return nil }
      guard let rawAddress = interfaceDictionary["except"] else { return nil }

      let address = MACAddress(rawAddress)
      return address.isValid ? address : nil
    }

  }
}
