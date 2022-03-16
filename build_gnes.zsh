#!/bin/zsh
#
# Build script for gnes

# Variables
XCODE_PATH="/Applications/Xcode_13.2.1.app"
MP_SHA="71c57fcfdf43692adcd41fa7305be08f66bae3e5"
MP_BINDIR="/tmp/munki-pkg"
CONSOLEUSER=$(/usr/bin/stat -f "%Su" /dev/console)
TOOLSDIR=$(dirname $0)
BUILDSDIR="$TOOLSDIR/build"
OUTPUTSDIR="$TOOLSDIR/outputs"
MP_ZIP="/tmp/munki-pkg.zip"
XCODE_BUILD_PATH="$XCODE_PATH/Contents/Developer/usr/bin/xcodebuild"
SUBBUILD=$((80620 + $(git rev-parse HEAD~0 | xargs -I{} git rev-list --count {})))
DERIVED_DATA_DIR="${BUILDSDIR}/Release"


# automate the build version bump
AUTOMATED_GNES_BUILD="0.0.1.$SUBBUILD"

# Create files to use for build process info
echo "$AUTOMATED_GNES_BUILD" > $TOOLSDIR/build_info.txt

# Ensure Xcode is set to run-time
sudo xcode-select -s "$XCODE_PATH"

if [ -e $XCODE_BUILD_PATH ]; then
  XCODE_BUILD="$XCODE_BUILD_PATH"
else
  ls -la /Applications
  echo "Could not find required Xcode build. Exiting..."
  exit 1
fi

# build gnes
echo "Building gnes"
$XCODE_BUILD -project "$TOOLSDIR/gnes.xcodeproj" -scheme "gnes-release" -destination 'platform=macos' -derivedDataPath "$DERIVED_DATA_DIR"
XCB_RESULT="$?"
if [ "${XCB_RESULT}" != "0" ]; then
    echo "Error running xcodebuild: ${XCB_RESULT}" 1>&2
    exit 1
fi

# Create outputs folder
if [ -e $OUTPUTSDIR ]; then
  /bin/rm -rf $OUTPUTSDIR
fi
/bin/mkdir -p "$OUTPUTSDIR"

# move the binary to the payload folder
echo "Moving gnes to payload folder"
GNES_PKG_PATH="$TOOLSDIR/gnesPkg"
if [ -e $GNES_PKG_PATH ]; then
  /bin/rm -rf $GNES_PKG_PATH
fi
/bin/mkdir -p "$GNES_PKG_PATH/payload/usr/local/bin"
/usr/bin/sudo /usr/sbin/chown -R ${CONSOLEUSER}:wheel "$GNES_PKG_PATH"
/bin/mv "$DERIVED_DATA_DIR/Build/Products/Release/gnes" "$GNES_PKG_PATH/payload/usr/local/bin/gnes"

# Download specific version of munki-pkg
echo "Downloading munki-pkg tool from github..."
if [ -f "${MP_ZIP}" ]; then
    /usr/bin/sudo /bin/rm -rf ${MP_ZIP}
fi
/usr/bin/curl https://github.com/munki/munki-pkg/archive/${MP_SHA}.zip -L -o ${MP_ZIP}
if [ -d ${MP_BINDIR} ]; then
    /usr/bin/sudo /bin/rm -rf ${MP_BINDIR}
fi
/usr/bin/unzip ${MP_ZIP} -d ${MP_BINDIR}
DL_RESULT="$?"
if [ "${DL_RESULT}" != "0" ]; then
    echo "Error downloading munki-pkg tool: ${DL_RESULT}" 1>&2
    exit 1
fi

# Create the json file for munkipkg gnes pkg
/bin/cat << JSONFILE > "$GNES_PKG_PATH/build-info.json"
{
  "ownership": "recommended",
  "suppress_bundle_relocation": true,
  "identifier": "com.github.erikng.gnes",
  "postinstall_action": "none",
  "distribution_style": true,
  "version": "$AUTOMATED_GNES_BUILD",
  "name": "gnes-$AUTOMATED_GNES_BUILD.pkg",
  "install_location": "/",
}
JSONFILE

# Create the pkg
"${MP_BINDIR}/munki-pkg-${MP_SHA}/munkipkg" "$GNES_PKG_PATH"
PKG_RESULT="$?"
if [ "${PKG_RESULT}" != "0" ]; then
  echo "Could not sign package: ${PKG_RESULT}" 1>&2
else
  # Move the pkg
  /bin/mv "$GNES_PKG_PATH/build/gnes-$AUTOMATED_GNES_BUILD.pkg" "$OUTPUTSDIR"
fi
