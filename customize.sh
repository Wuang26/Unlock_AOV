#!/system/bin/sh
[ -z "$MODPATH" ] && MODPATH="/data/adb/modules_update/aov_unlock/"
TOOLS_SRC="$MODPATH/tools"
TOOLS_KOUSEI="$MODPATH/tools/kousei"
TOOLS_DEST="/data/local/tmp/tools/kousei"

mkdir -p "$TOOLS_DEST"

rm -rf "$TOOLS_DEST/"*

cp -af "$TOOLS_SRC/"* "$TOOLS_DEST/"

for tool_name in echo sleep sed rm mkdir ls head grep chown touch cut cp chmod basename printf id chcon install getenforce setenforce stat; do
    cp -af "$TOOLS_KOUSEI" "$TOOLS_DEST/$tool_name"
    chmod +x "$TOOLS_DEST/$tool_name"
done

chmod +x "$TOOLS_DEST/"*

for tool in "$TOOLS_DEST/"*; do
    if [ -f "$tool" ] && [ -x "$tool" ]; then
        sleep 0
    else
        ui_print "❌ Công cụ $(basename "$tool") bị lỗi hoặc không thể thực thi!"
    fi
done

chmod +x "$MODPATH/service.sh"
chmod +x "$MODPATH/action.sh"
cp "$MODPATH/action.sh" "/data/local/tmp/tools/kousei/"
sh "$MODPATH/action.sh"