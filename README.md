# gnes (G Ness)
Get Network Extension Status

# Use Case
System Extensions have some data available at. `/Library/SystemExtensions/db.plist`. Unfortunately for Network System Extensions, much of the data, including if it's enabled is not available in this location. For example, a network extension can be loaded in memory, but not enabled.

`/Library/Preferences/com.apple.networkextension.plist` exposes much of this data, but the plist is not in a standard format, which means that CFPreferences cannot adequately handle this data.

This tool uses private headers to expose all of the required data and put it into an easily parsible format.

# Usage
```
NAME
     gnes – Get Network Extension Status

SYNOPSIS
     gnes -dump [-all -identifiers -raw] [-identifier %identifier%] [-type %type%] %output%

DESCRIPTION
     The gnes command is used to read and print network extension status

OPTIONS
     The options are as follows:

     -dump
             Optional: Returns requested data. Must be combined with sub-option. Can be combined with some optional outputs
                -all: Returns all found bundle identifier and their data. Can be combined with -stdout-json, -stdout-raw, -stdout-xml and None
                -identifiers: Returns all found bundle identifier. Can be combined with -stdout-json, -stdout-raw, -stdout-xml and None
                -raw: Returns all found data directly from NEConfiguration. Can be combined with -stdout-raw and None

     -identifier
             Required: The bundle identifier of the network extension to query

     -type
             Required: The type of the network extension to query. Needed due to multiple network extensions utilizing the same bundle identifier
                Allowed values: "contentFilter", "dnsProxy", "vpn"

     output
            Optional: Specific output formats:
                -stdout-enabled: Returns Network Extensions enabled status
                -stdout-json: Returns Network Extension(s) data in JSON format
                -stdout-raw: Returns Network Extension(s) data in raw Swift format
                -stdout-xml: Returns Network Extension(s) data in PLIST format
                None passed: Returns standard Network Extension(s) data in Swift printed format
```

# Examples

## sample output (json)
`gnes -identifier "com.crowdstrike.falcon.App" -type contentFilter -stdout-json`
```json
{
  "application" : "com.crowdstrike.falcon.App",
  "applicationName" : "Falcon",
  "contentFilter" : {
    "enabled" : true,
    "filterGrade" : 1,
    "provider" : {
      "dataProviderBundleIdentifier" : "com.crowdstrike.falcon.Agent",
      "dataProviderDesignatedRequirement" : "identifier \"com.crowdstrike.falcon.Agent\" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] \/* exists *\/ and certificate leaf[field.1.2.840.113635.100.6.1.13] \/* exists *\/ and certificate leaf[subject.OU] = X9E956P446",
      "filterPackets" : false,
      "filterSockets" : true,
      "organization" : "CrowdStrike",
      "packetProviderBundleIdentifier" : "com.crowdstrike.falcon.Agent",
      "pluginType" : "com.crowdstrike.falcon.App",
      "preserveExistingConnections" : false
    }
  },
  "grade" : 1,
  "identifier" : "CD150001-EE65-447B-9251-B32D6CF828B7",
  "name" : "Falcon",
  "payloadInfo" : {
    "isSetAside" : false,
    "payloadOrganization" : "GitHub",
    "payloadUUID" : "8EF5C132-BEB4-499E-BEE3-07CF4361780F",
    "profileIdentifier" : "10D24B0A-2F2A-4F96-80FA-7A435D65981A",
    "profileIngestionDate" : "2022-03-08 00:00:00 -0000",
    "profileSource" : "mdm",
    "profileUUID" : "58417554-8EAB-4DF5-A2FB-D13AF9DC4042",
    "systemVersion" : "Version 12.2.1 (Build 21D62)"
  },
  "type" : "contentFilter"
}
```

## sample output (plist)
`./gnes -identifier "com.crowdstrike.falcon.App" -type contentFilter -stdout-xml`
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>application</key>
        <string>com.crowdstrike.falcon.App</string>
        <key>applicationName</key>
        <string>Falcon</string>
        <key>contentFilter</key>
        <dict>
            <key>enabled</key>
            <true/>
            <key>filterGrade</key>
            <integer>1</integer>
            <key>provider</key>
            <dict>
                <key>dataProviderBundleIdentifier</key>
                <string>com.crowdstrike.falcon.Agent</string>
                <key>dataProviderDesignatedRequirement</key>
                <string>identifier "com.crowdstrike.falcon.Agent" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = X9E956P446</string>
                <key>filterPackets</key>
                <false/>
                <key>filterSockets</key>
                <true/>
                <key>organization</key>
                <string>CrowdStrike</string>
                <key>packetProviderBundleIdentifier</key>
                <string>com.crowdstrike.falcon.Agent</string>
                <key>pluginType</key>
                <string>com.crowdstrike.falcon.App</string>
                <key>preserveExistingConnections</key>
                <false/>
            </dict>
        </dict>
        <key>grade</key>
        <integer>1</integer>
        <key>identifier</key>
        <string>F5CF37FF-AD81-478A-BC44-158E0C098F9B</string>
        <key>name</key>
        <string>Falcon</string>
        <key>payloadInfo</key>
        <dict>
            <key>isSetAside</key>
            <false/>
            <key>payloadOrganization</key>
            <string>GitHub</string>
            <key>payloadUUID</key>
            <string>B477FCD3-BB72-4C65-9C81-CB54913C8D2B</string>
            <key>profileIdentifier</key>
            <string>40EC65F4-D642-44E7-89A8-B7F84D25BD79</string>
            <key>profileIngestionDate</key>
            <string>2022-03-08 00:00:00 -0000</string>
            <key>profileSource</key>
            <string>mdm</string>
            <key>profileUUID</key>
            <string>6A26A255-51BF-493C-8BC9-4DA9F01CEF6D</string>
            <key>systemVersion</key>
            <string>Version 12.2.1 (Build 21D62)</string>
        </dict>
        <key>type</key>
        <string>contentFilter</string>
    </dict>
</plist>
```

## sample output (enabled)
```shell
gnes -identifier "com.crowdstrike.falcon.App" -type contentFilter -stdout-enabled
true
```

## sample output (dump identifiers with json)
You can also pass `-stdout-xml`, `-stdout-raw` or none
```shell
gnes -dump -identifiers -stdout-json
```

```json
{
  "contentFilter" : [
    "com.crowdstrike.falcon.App",
    "com.cisco.anyconnect.macos.acsock"
  ],
  "dnsProxy" : [
    "com.cisco.anyconnect.macos.acsock"
  ],
  "unknown" : [

  ],
  "vpn" : [
    "com.cisco.anyconnect.macos.acsock"
  ]
}
```

## sample output (dump with json)
You can also pass `-stdout-xml`, `-stdout-raw` or none
```shell
gnes -dump -stdout-json
```

```json
{
  "1DD0808A-EB5C-490B-B5FF-65E246B0C3CC" : {
    "application" : "com.crowdstrike.falcon.App",
    "applicationName" : "Falcon",
    "contentFilter" : {
      "enabled" : true,
      "filterGrade" : 1,
      "provider" : {
        "dataProviderBundleIdentifier" : "com.crowdstrike.falcon.Agent",
        "dataProviderDesignatedRequirement" : "identifier \"com.crowdstrike.falcon.Agent\" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] \/* exists *\/ and certificate leaf[field.1.2.840.113635.100.6.1.13] \/* exists *\/ and certificate leaf[subject.OU] = X9E956P446",
        "filterPackets" : false,
        "filterSockets" : true,
        "organization" : "CrowdStrike",
        "packetProviderBundleIdentifier" : "com.crowdstrike.falcon.Agent",
        "pluginType" : "com.crowdstrike.falcon.App",
        "preserveExistingConnections" : false
      }
    },
    "grade" : 1,
    "identifier" : "1DD0808A-EB5C-490B-B5FF-65E246B0C3CC",
    "name" : "Falcon",
    "payloadInfo" : {
      "isSetAside" : false,
      "payloadOrganization" : "GitHub",
      "payloadUUID" : "8EF5C132-BEB4-499E-BEE3-07CF4361780F",
      "profileIdentifier" : "10D24B0A-2F2A-4F96-80FA-7A435D65981A",
      "profileIngestionDate" : "2022-03-08 00:00:00 -0000",
      "profileSource" : "mdm",
      "profileUUID" : "58417554-8EAB-4DF5-A2FB-D13AF9DC4042",
      "systemVersion" : "Version 12.2.1 (Build 21D62)"
    }
  }
}
```

## sample output (dump raw data with -stdout-raw)
You can also pass without -stdout-raw
```shell
gnes -dump -raw -stdout-raw
```

```swift
["1DD0808A-EB5C-490B-B5FF-65E246B0C3CC": {
    name = Falcon
    identifier = 1DD0808A-EB5C-490B-B5FF-65E246B0C3CC
    applicationName = Falcon
    application = com.crowdstrike.falcon.App
    grade = 1
    contentFilter = {
        enabled = YES
        provider = {
            pluginType = com.crowdstrike.falcon.App
            dataProviderDesignatedRequirement = identifier "com.crowdstrike.falcon.Agent" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = X9E956P446
            dataProviderBundleIdentifier = com.crowdstrike.falcon.Agent
            packetProviderBundleIdentifier = com.crowdstrike.falcon.Agent
            organization = CrowdStrike
            filterPackets = NO
            filterSockets = YES
            preserveExistingConnections = NO
        }
        filter-grade = 1
    }
    payloadInfo = {
        payloadUUID = 9E2ED1D9-EEFE-42CD-936D-A495B6351C8D
        payloadOrganization = GitHub
        profileUUID = AFC41A7E-CBC2-4A3F-A778-90D075767560
        profileIdentifier = C20ACDFB-440C-491F-A93A-2A9492F776BA
        isSetAside = NO
        profileIngestionDate = 2022-03-08 00:00:00 +0000
        systemVersion = Version 12.2.1 (Build 21D62)
        profileSource = mdm
    }
}, "51E6E1B4-FF69-44E3-8803-DFB9DE62FD50": {
    name = Cisco AnyConnect Socket Filter
    identifier = 51E6E1B4-FF69-44E3-8803-DFB9DE62FD50
    applicationName = Cisco AnyConnect Socket Filter
    application = com.cisco.anyconnect.macos.acsock
    grade = 1
    dnsProxy = {
        enabled = YES
        protocol = {
            type = dnsProxy
            identifier = EF72DA8C-912F-421F-887A-2C447E8F2AB5
            identityDataImported = NO
            disconnectOnSleep = NO
            disconnectOnIdle = NO
            disconnectOnIdleTimeout = 0
            disconnectOnWake = NO
            disconnectOnWakeTimeout = 0
            disconnectOnUserSwitch = NO
            disconnectOnLogout = NO
            includeAllNetworks = NO
            excludeLocalNetworks = NO
            enforceRoutes = NO
            pluginType = com.cisco.anyconnect.macos.acsock
            providerBundleIdentifier = com.cisco.anyconnect.macos.acsockext
            designatedRequirement = anchor apple generic and identifier "com.cisco.anyconnect.macos.acsockext" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = DE8Y96K9QP)
        }
    }
}, "42772299-C226-4F45-A90C-E16B220CD24D": {
    name = Cisco AnyConnect Content Filter
    identifier = 42772299-C226-4F45-A90C-E16B220CD24D
    applicationName = Cisco AnyConnect Socket Filter
    application = com.cisco.anyconnect.macos.acsock
    grade = 1
    contentFilter = {
        enabled = YES
        provider = {
            pluginType = com.cisco.anyconnect.macos.acsock
            dataProviderDesignatedRequirement = anchor apple generic and identifier "com.cisco.anyconnect.macos.acsockext" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = DE8Y96K9QP)
            dataProviderBundleIdentifier = com.cisco.anyconnect.macos.acsockext
            filterPackets = NO
            filterSockets = YES
            preserveExistingConnections = NO
        }
        filter-grade = 1
    }
    payloadInfo = {
        payloadUUID = 2EB09447-29D0-49E0-8D4A-D83D653F1938
        payloadOrganization = GitHub
        profileUUID = 23811CFC-CEFE-4E24-B060-48BB1350B670
        profileIdentifier = DD83CAC6-3069-4EA2-8F24-F04F4220ABA2
        isSetAside = NO
        profileIngestionDate = 2022-03-08 00:00:00 +0000
        systemVersion = Version 12.2.1 (Build 21D62)
        profileSource = mdm
    }
}, "49495CDF-F590-4AAA-BA1D-3EE71C1E6C9C": {
    name = Cisco AnyConnect Socket Filter
    identifier = 49495CDF-F590-4AAA-BA1D-3EE71C1E6C9C
    applicationName = Cisco AnyConnect Socket Filter
    application = com.cisco.anyconnect.macos.acsock
    grade = 1
    VPN = {
        enabled = YES
        onDemandEnabled = NO
        disconnectOnDemandEnabled = NO
        onDemandUserOverrideDisabled = NO
        protocol = {
            type = plugin
            identifier = 95FF85F6-28D9-47B9-A7E8-8809622C78C0
            serverAddress = Connection managed by Cisco AnyConnect Socket Filter
            identityDataImported = NO
            disconnectOnSleep = NO
            disconnectOnIdle = NO
            disconnectOnIdleTimeout = 0
            disconnectOnWake = NO
            disconnectOnWakeTimeout = 0
            disconnectOnUserSwitch = NO
            disconnectOnLogout = NO
            includeAllNetworks = NO
            excludeLocalNetworks = NO
            enforceRoutes = NO
            pluginType = com.cisco.anyconnect.macos.acsock
            authenticationMethod = 0
            reassertTimeout = 0
            providerBundleIdentifier = com.cisco.anyconnect.macos.acsockext
            designatedRequirement = anchor apple generic and identifier "com.cisco.anyconnect.macos.acsockext" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = DE8Y96K9QP)
        }
        tunnelType = app-proxy
    }
}]
```
