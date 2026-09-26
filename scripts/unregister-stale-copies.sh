#!/bin/sh
# Keeps a single SadeBlock entry in Safari → Settings → Extensions.
#
# macOS registers the Safari extension separately for every copy of
# SadeBlock.app on disk (Xcode DerivedData, the README's build/ folder,
# /Applications, archives…). Each copy shows up as its own "SadeBlock" row.
# This script unregisters every copy except the current one.
#
# Xcode runs it after each build of the SadeBlock target. It can also be run
# by hand; pass the path of the SadeBlock.app to keep:
#   scripts/unregister-stale-copies.sh /Applications/SadeBlock.app

EXTENSION_ID="local.halil.SadeBlock.Blocker"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

if [ -n "$1" ]; then
    KEEP_APP="$1"
elif [ -n "$CODESIGNING_FOLDER_PATH" ]; then
    # Archives are built in a temporary folder; the copy in use stays put.
    [ "$ACTION" = "install" ] && exit 0
    # CI runners have no Safari registrations worth touching.
    [ -n "$CI" ] && exit 0
    KEEP_APP="$CODESIGNING_FOLDER_PATH"
else
    echo "usage: $0 /path/to/SadeBlock.app" >&2
    exit 64
fi

command -v pluginkit >/dev/null 2>&1 || exit 0
KEEP_APP="$(cd "$KEEP_APP" 2>/dev/null && pwd -P)" || {
    echo "warning: $1 not found; nothing unregistered." >&2
    exit 0
}

# -A and -D list every registered copy, including ones pluginkit considers
# superseded. The bundle path is the last tab-separated field.
pluginkit -m -A -D -v -i "$EXTENSION_ID" 2>/dev/null \
    | awk -F '\t' '{ print $NF }' \
    | grep '^/.*\.appex$' \
    | sort -u \
    | while IFS= read -r appex; do
        app="${appex%/Contents/PlugIns/*}"
        resolved="$(cd "$app" 2>/dev/null && pwd -P || echo "$app")"
        [ "$resolved" = "$KEEP_APP" ] && continue
        echo "Unregistering stale SadeBlock copy: $app"
        pluginkit -r "$appex" 2>/dev/null || true
        [ -x "$LSREGISTER" ] && "$LSREGISTER" -u "$app" 2>/dev/null || true
    done

exit 0
