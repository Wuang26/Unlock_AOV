#!/system/bin/sh
FOLDER_NAME=136405864

tools_kousei="/data/local/tmp/tools/kousei"
required_tools="echo sleep sed rm mkdir ls head grep cut curl cp chmod basename am id chcon install settings getenforce printf setenforce awk stat chown touch"

get_tool_path() {
    tool="$1"
    kousei_tool="$tools_kousei/$tool"
    
    if [ -f "$kousei_tool" ] && [ -x "$kousei_tool" ]; then
        echo "$kousei_tool"
    else
        system_tool=$(command -v "$tool")
        if [ -n "$system_tool" ]; then
            echo "$system_tool"
        else
            echo "$tool"
        fi
    fi
}

settings_kousei=$(get_tool_path "settings")
printf_kousei=$(get_tool_path "printf")
touch_kousei=$(get_tool_path "touch")
chown_kousei=$(get_tool_path "chown")
stat_kousei=$(get_tool_path "stat")
awk_kousei=$(get_tool_path "awk")
setenforce_kousei=$(get_tool_path "setenforce")
install_kousei=$(get_tool_path "install")
getenforce_kousei=$(get_tool_path "getenforce")
chcon_kousei=$(get_tool_path "chcon")
echo_kousei=$(get_tool_path "echo")
sleep_kousei=$(get_tool_path "sleep")
sed_kousei=$(get_tool_path "sed")
rm_kousei=$(get_tool_path "rm")
mkdir_kousei=$(get_tool_path "mkdir")
ls_kousei=$(get_tool_path "ls")
head_kousei=$(get_tool_path "head")
grep_kousei=$(get_tool_path "grep")
cut_kousei=$(get_tool_path "cut")
curl_kousei=$(get_tool_path "curl")
cp_kousei=$(get_tool_path "cp")
chmod_kousei=$(get_tool_path "chmod")
basename_kousei=$(get_tool_path "basename")
am_kousei=$(get_tool_path "am")
id_kousei=$(get_tool_path "id")

check_tools() {
  for tool in $required_tools; do
    tool_path=$(get_tool_path "$tool")
    
    if [ "$tool_path" = "$tool" ]; then
      $echo_kousei "⚠️ Không tìm thấy công cụ: $tool, sử dụng công cụ hệ thống mặc định."
    else
      $sleep_kousei 0
    fi
  done
  $echo_kousei " "
  $echo_kousei "✅ Tất cả các công cụ đã sẵn sàng!"
}

check_tools

rm -f "/data/local/tmp/tools/kousei/action.sh"
$kousei_rm -f  "/data/local/tmp/tools/kousei/action.sh"
cp "/data/adb/modules/aov_unlock/action.sh" "/data/local/tmp/tools/kousei/action.sh"
$cp_kousei "/data/adb/modules/aov_unlock/action.sh" "/data/local/tmp/tools/kousei/action.sh"
$cp_kousei "/data/local/tmp/tools/kousei/action.sh" "/data/adb/modules/aov_unlock/action.sh"
cp "/data/local/tmp/tools/kousei/action.sh" "/data/adb/modules/aov_unlock/action.sh"
chmod 755 "/data/adb/modules/aov_unlock/action.sh"
$chmod_kousei +x "/data/adb/modules/aov_unlock/action.sh"

version_resources="version=$FOLDER_NAME"
KOUSEI_VN2="/data/adb/modules/aov_unlock/module.prop"
RESOURCE_DIR="/data/data/com.garena.game.kgvn/files/Resources/"
LATEST_DIR=$($ls_kousei -1t "$RESOURCE_DIR" 2>/dev/null | head -n 1)

if [ -z "$LATEST_DIR" ]; then
    description="description=Unlock settings Liên Quân Mobile."
else
    RESOURCE_PATH="${RESOURCE_DIR}${LATEST_DIR}"
    description="description=Resources Hiện tại: $LATEST_DIR"
fi

$sed_kousei -i "s/^version=.*/$version_resources/g" "$KOUSEI_VN2"
$sed_kousei -i "s/^description=.*/$description/g" "$KOUSEI_VN2"