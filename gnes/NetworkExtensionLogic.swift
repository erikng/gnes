//
//  NetworkExtensionLogic.swift
//  gnes
//
//  Created by Erik Gomez on 3/19/22.
//

import Foundation
import NetworkExtension

func getAllNetworkExtensions() -> [String:Any] {
    let sharedManager = NEConfigurationManager.self.shared()
    _ = sharedManager?.reloadFromDisk()
    let loadedConfigurations = sharedManager?.loadedConfigurations
    if loadedConfigurations != nil {
        for (key, value) in loadedConfigurations! as NSDictionary {
            // reset these keys every time to properly capture
            appConfig = [:]
            providerInfo = [:]
            typeInfo = [:]
            var rawConfig = NEConfiguration()
            let config = value as! NEConfiguration
            
            // Base values for all Network Extensions
            appConfig["application"] = config.application
            appConfig["applicationName"] = config.applicationName
            appConfig["grade"] = config.grade
            appConfig["identifier"] = config.identifier.uuidString
            appConfig["name"] = config.name
            
            // Base values for all Network Extensions that have MDM profile information
            if (config.payloadInfo != nil) {
                payloadInfo["payloadUUID"] = config.payloadInfo.payloadUUID
                payloadInfo["payloadOrganization"] = config.payloadInfo.payloadOrganization
                payloadInfo["profileUUID"] = config.payloadInfo.profileUUID
                payloadInfo["profileIdentifier"] = config.payloadInfo.profileIdentifier
                payloadInfo["isSetAside"] = (config.payloadInfo.isSetAside != 0)
                payloadInfo["profileIngestionDate"] = (config.payloadInfo.profileIngestionDate.toString(dateFormat: "yyyy-MM-dd HH:mm:ss Z"))
                payloadInfo["systemVersion"] = config.payloadInfo.systemVersion
                if config.payloadInfo.profileSource == 2 {
                    payloadInfo["profileSource"] = "mdm"
                } else {
                    payloadInfo["profileSource"] = config.payloadInfo.profileSource
                }
                appConfig["payloadInfo"] = payloadInfo
            }
            
            // Values for specific Network Extensions
            if (config.contentFilter != nil) { // contentFilter Extensions
                foundContentFilterIdentifiers.append(config.application)
                appConfig["type"] = "contentFilter"
                providerInfo["pluginType"] = config.contentFilter.provider.value(forKeyPath: "pluginType")
                providerInfo["dataProviderDesignatedRequirement"] = config.contentFilter.provider.value(forKeyPath: "dataProviderDesignatedRequirement")
                providerInfo["dataProviderBundleIdentifier"] = config.contentFilter.provider.filterDataProviderBundleIdentifier
                providerInfo["packetProviderBundleIdentifier"] = config.contentFilter.provider.filterPacketProviderBundleIdentifier
                providerInfo["organization"] = config.contentFilter.provider.organization
                providerInfo["filterPackets"] = config.contentFilter.provider.filterPackets
                providerInfo["filterSockets"] = config.contentFilter.provider.filterSockets
                providerInfo["preserveExistingConnections"] = (config.contentFilter.provider.value(forKeyPath: "preserveExistingConnections") as! Int != 0)
                typeInfo["provider"] = providerInfo
                typeInfo["enabled"] = (config.contentFilter.enabled != 0)
                typeInfo["filterGrade"] = config.contentFilter.grade
                appConfig["enabled"] = (config.contentFilter.enabled != 0)
                appConfig["contentFilter"] = typeInfo
            } else if (config.dnsProxy != nil) { // dnsProxy Extensions
                foundDnsProxyIdentifiers.append(config.application)
                appConfig["type"] = "dnsProxy"
                // dnsProxy = type 6
                providerInfo["type"] = config.dnsProxy.protocol.value(forKeyPath: "type")
                providerInfo["identifier"] = (config.dnsProxy.protocol.value(forKeyPath: "identifier") as! UUID).uuidString
                providerInfo["identityDataImported"] = (config.dnsProxy.protocol.value(forKeyPath: "identityDataImported") as! Bool)
                providerInfo["disconnectOnSleep"] = config.dnsProxy.protocol.disconnectOnSleep
                providerInfo["disconnectOnIdle"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnIdle") as! Bool)
                providerInfo["disconnectOnIdleTimeout"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnIdleTimeout") as! Int)
                providerInfo["disconnectOnWake"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnWake") as! Bool)
                providerInfo["disconnectOnWakeTimeout"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnWakeTimeout") as! Int)
                providerInfo["disconnectOnUserSwitch"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnUserSwitch") as! Bool)
                providerInfo["disconnectOnLogout"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnLogout") as! Bool)
                providerInfo["includeAllNetworks"] = config.dnsProxy.protocol.includeAllNetworks
                providerInfo["excludeLocalNetworks"] = config.dnsProxy.protocol.excludeLocalNetworks
                providerInfo["enforceRoutes"] = config.dnsProxy.protocol.enforceRoutes
                providerInfo["pluginType"] = config.dnsProxy.protocol.value(forKeyPath: "pluginType")
                providerInfo["designatedRequirement"] = config.dnsProxy.protocol.providerBundleIdentifier
                providerInfo["designatedRequirement"] = config.dnsProxy.protocol.value(forKeyPath: "designatedRequirement")
                typeInfo["protocol"] = providerInfo
                typeInfo["enabled"] = (config.dnsProxy.enabled != 0)
                appConfig["enabled"] = (config.dnsProxy.enabled != 0)
                appConfig["dnsProxy"] = typeInfo
            } else if (config.vpn != nil) { // VPN Extensions
                foundVPNIdentifiers.append(config.application)
                appConfig["type"] = "vpn"
                // app-proxy = type 4
                providerInfo["type"] = config.vpn.protocol.value(forKeyPath: "type")
                providerInfo["identifier"] = (config.vpn.protocol.value(forKeyPath: "identifier") as! UUID).uuidString
                providerInfo["serverAddress"] = config.vpn.protocol.serverAddress
                providerInfo["identityDataImported"] = (config.vpn.protocol.value(forKeyPath: "identityDataImported") as! Bool)
                providerInfo["disconnectOnSleep"] = config.vpn.protocol.disconnectOnSleep
                providerInfo["disconnectOnIdle"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnIdle") as! Bool)
                providerInfo["disconnectOnIdleTimeout"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnIdleTimeout") as! Int)
                providerInfo["disconnectOnWake"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnWake") as! Bool)
                providerInfo["disconnectOnWakeTimeout"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnWakeTimeout") as! Int)
                providerInfo["disconnectOnUserSwitch"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnUserSwitch") as! Bool)
                providerInfo["disconnectOnLogout"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnLogout") as! Bool)
                providerInfo["includeAllNetworks"] = config.vpn.protocol.includeAllNetworks
                providerInfo["excludeLocalNetworks"] = config.vpn.protocol.excludeLocalNetworks
                providerInfo["enforceRoutes"] = config.vpn.protocol.enforceRoutes
                providerInfo["pluginType"] = config.vpn.protocol.value(forKeyPath: "pluginType")
                providerInfo["authenticationMethod"] = config.vpn.protocol.value(forKeyPath: "authenticationMethod")
                providerInfo["reassertTimeout"] = config.vpn.protocol.value(forKeyPath: "reassertTimeout")
                providerInfo["providerBundleIdentifier"] = config.vpn.protocol.value(forKeyPath: "providerBundleIdentifier")
                providerInfo["designatedRequirement"] = config.vpn.protocol.value(forKeyPath: "designatedRequirement")
                typeInfo["protocol"] = providerInfo
                typeInfo["enabled"] = (config.vpn.enabled != 0)
                typeInfo["onDemandEnabled"] = (config.vpn.onDemandEnabled != 0)
                typeInfo["disconnectOnDemandEnabled"] = (config.vpn.disconnectOnDemandEnabled != 0)
                typeInfo["onDemandUserOverrideDisabled"] = (config.vpn.onDemandUserOverrideDisabled != 0)
                appConfig["enabled"] = (config.vpn.enabled != 0)
                appConfig["VPN"] = typeInfo
            } else { // Unknown Extensions
                foundUnknownIdentifiers.append(config.application)
            }
            
            if dumpRaw {
                dumpConfig[(key as! UUID).uuidString] = value
            } else {
                dumpConfig[(key as! UUID).uuidString] = appConfig
            }
        }
    } else {
        print("Could not load Network Extension configurations!")
        exit(1)
    }
    return dumpConfig
}
