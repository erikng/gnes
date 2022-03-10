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
     gnes -debug [-identifier identifier] [-type type] output

DESCRIPTION
     The gnes command is used to read and print network extension status

OPTIONS
     The options are as follows:

     -debug
             Optional: Returns all found bundle identifiers and type if passed identifier is not found

     -identifier
             Required: The bundle identifier of the network extension to query

     -type
             Required: The type of network extension you are querying. Needed when an application installs multiple network extensions with the same bundle identifier
                "contentFilter", "dnsProxy", "vpn"

     output
            Optional: Specific output formats:
                -stdout-xml -stdout-json -stdout-enabled -stdout-raw
```

# Examples
sample output (json)
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

sample output (profile)
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

sample output (enabled)
```shell
gnes -identifier "com.crowdstrike.falcon.App" -type contentFilter -stdout-enabled
true
```

Did not find extension
```shell
gnes -identifier "com.example.fake.contentFilter" -type contentFilter -debug
Did not find network extension!
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
