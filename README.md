# gnes
Get Network Extension Status

```
NAME
     gnes – Get Network Extension Status

SYNOPSIS
     gnes [-identifier identifier] [-type type] output

DESCRIPTION
     The codesign command is used to read and print network extension status

OPTIONS
     The options are as follows:

     -identifier
             Required: The bundle identifier of the network extension to query

     -type
             Required: The type of network extension you are querying. Needed when an application installs multiple network extensions with the same bundle identifier
                "contentFilter", "dnsProxy", "vpn"

     output
            Optional: Specific output formats:
                -stdout-xml -stdout-json -stdout-enabled
```
