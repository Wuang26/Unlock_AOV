#!/system/bin/sh
TOOLS_SRC="$MODPATH/tools"
TOOLS_DEST="/data/local/tmp/tools/kousei"
mkdir -p "$TOOLS_DEST"
cp -af "$TOOLS_SRC/"* "$TOOLS_DEST/"
chmod +x "$TOOLS_DEST/"*

for tool in "$TOOLS_DEST/"*; do
    if [ -f "$tool" ] && [ -x "$tool" ]; then
        sleep 0
    else
        ui_print "❌ Công cụ $(basename "$tool") bị lỗi hoặc không thể thực thi!"
    fi
done

sh $MODPATH/action.sh