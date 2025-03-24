#!/system/bin/sh

[ -z "$MODPATH" ] && MODPATH="/data/adb/modules_update/aov_unlock/"

tools_kousei="/data/local/tmp/tools/kousei"
required_tools="echo sleep sed rm mkdir ls head grep cut curl cp chmod basename am id chcon install getenforce setenforce awk stat chown touch"

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

check_root() {
    if [ "$(id -u)" != "0" ]; then
        $echo_kousei "❌ Yêu cầu quyền root để tiếp tục!" >&2
        exit 1
    fi
}

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

check_root
check_tools

$echo_kousei ""
$echo_kousei "✅ Bắt đầu thực thi script..."
$echo_kousei ""

if [ -d "$tools_kousei" ]; then
    chmod +x "$tools_kousei/"*
else
    $sleep_kousei 0
fi

CURRENT_SELINUX=$($getenforce_kousei)

if [ "$CURRENT_SELINUX" = "Enforcing" ]; then
    $setenforce_kousei 0
fi

KOUSEI_BACKUP=0

GITHUB_USER="Wuang26"
GITHUB_REPO="Unlock_AOV"
KOUSEI_VN2="/data/adb/modules/aov_unlock/module.prop"
KOUSEI_VN2_DIR="$MODPATH/module.prop"
KOUSEI_VN2_UP="/data/adb/modules_update/aov_unlock/module.prop"

RESOURCE_DIR="/data/user/0/com.garena.game.kgvn/files/Resources/"
LATEST_DIR=$($ls_kousei -1t "$RESOURCE_DIR" 2>/dev/null | $head_kousei -n 1)
ASSET_URL=$($curl_kousei -s "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest" | $grep_kousei "browser_download_url" | $cut_kousei -d '"' -f 4 | $head_kousei -n 1)

if [ -z "$ASSET_URL" ]; then
  $echo_kousei "❌ Không tìm thấy file mới nhất!"
  $echo_kousei ""
  exit 1
fi

FOLDER_NAME=$($basename_kousei "$ASSET_URL")
GAME_BASE_PATH="/data/user/0/com.garena.game.kgvn/files/Resources"
DEST_FOLDER="$GAME_BASE_PATH/$FOLDER_NAME/arm64-v8a"
version_resources="version=$FOLDER_NAME"
SERVICES_SCRIPT_UP="/data/adb/modules_update/aov_unlock/service.sh"
SERVICES_SCRIPT_DIR="$MODPATH/service.sh"
SERVICES_SCRIPT="/data/adb/modules/aov_unlock/service.sh"

if $grep_kousei -q "FOLDER_NAME=" "$SERVICES_SCRIPT_UP" 2>/dev/null; then
  $sed_kousei -i "s/^FOLDER_NAME=.*/FOLDER_NAME=$FOLDER_NAME/g" "$SERVICES_SCRIPT_UP"
else
  $sleep_kousei 0
fi

if $grep_kousei -q "FOLDER_NAME=" "$SERVICES_SCRIPT_DIR" 2>/dev/null; then
  $sed_kousei -i "s/^FOLDER_NAME=.*/FOLDER_NAME=$FOLDER_NAME/g" "$SERVICES_SCRIPT_DIR"
else
  $sleep_kousei 0
fi

if $grep_kousei -q "FOLDER_NAME=" "$SERVICES_SCRIPT" 2>/dev/null; then
  $sed_kousei -i "s/^FOLDER_NAME=.*/FOLDER_NAME=$FOLDER_NAME/g" "$SERVICES_SCRIPT"
else
  $sleep_kousei 0
fi

if $grep_kousei -q "version=" "$KOUSEI_VN2_DIR" 2>/dev/null; then
  $sed_kousei -i "s/^version=.*/$version_resources/g" "$KOUSEI_VN2_DIR"
else
  $echo_kousei ""
fi

if $grep_kousei -q "version=" "$KOUSEI_VN2_UP" 2>/dev/null; then
  $sed_kousei -i "s/^version=.*/$version_resources/g" "$KOUSEI_VN2_UP"
else
  $sleep_kousei 0
fi

if $grep_kousei -q "version=" "$KOUSEI_VN2" 2>/dev/null; then
  $sed_kousei -i "s/^version=.*/$version_resources/g" "$KOUSEI_VN2"
else
  $sleep_kousei 0
fi

if [ ! -d "$DEST_FOLDER" ]; then
  $echo_kousei "❌ Thư mục không tồn tại: $DEST_FOLDER"
  $echo_kousei ""
  $echo_kousei "❌ Vui lòng kiểm tra lại phiên bản của Module hoặc Game.!"
  $echo_kousei ""
  $echo_kousei "⏩ Mở trang phát hành module sau 15 giây...!"
  $sleep_kousei 15
  $echo_kousei ""
  $echo_kousei "🔗 Tải xuống Module mới nhất tại:"
  $echo_kousei ""
  $echo_kousei "https://github.com/Wuang26/Unlock_AOV/releases"
  $am_kousei start -a android.intent.action.VIEW -d "https://github.com/Wuang26/Unlock_AOV/releases" >/dev/null 2>&1
  exit 1
fi

DEST_FILE="$DEST_FOLDER/libil2cpp.so"
BACKUP_FOLDER="/data/local/tmp/kousei_backup"
BACKUP_FILE="$BACKUP_FOLDER/libil2cpp_$(date +%Y%m%d_%H%M%S).so"
ORIGINAL_FILE="$DEST_FILE"
FILE_MODE=$($stat_kousei -c %a "$ORIGINAL_FILE")
FILE_OWNER=$($stat_kousei -c %U "$ORIGINAL_FILE")
FILE_GROUP=$($stat_kousei -c %G "$ORIGINAL_FILE")
FILE_CONTEXT=$($ls_kousei -Z "$ORIGINAL_FILE" | $awk_kousei '{print $1}')
FILE_TIMESTAMP="$ORIGINAL_FILE"
FILE_TIMESTAMP_1=$($stat_kousei -c %y "$ORIGINAL_FILE")

if [ "$KOUSEI_BACKUP" -eq 1 ]; then
  if [ -f "$DEST_FILE" ]; then
    $echo_kousei "🔵 Script by Kousei"
    $echo_kousei "========================================"
    $echo_kousei ""
    $echo_kousei "🔄 Tìm thấy file hiện tại: $DEST_FILE"

    $mkdir_kousei -p "$BACKUP_FOLDER"
    $rm_kousei -rf "$BACKUP_FOLDER"/*

    $install_kousei -m "$FILE_MODE" -o "$FILE_OWNER" -g "$FILE_GROUP" "$DEST_FILE" "$BACKUP_FILE"
    $chmod_kousei "$FILE_MODE" "$BACKUP_FILE" 2>/dev/null
    $chcon_kousei "$FILE_CONTEXT" "$BACKUP_FILE" 2>/dev/null
    $chown_kousei "$FILE_OWNER:$FILE_GROUP" "$BACKUP_FILE" 2>/dev/null
    $touch_kousei -r "$FILE_TIMESTAMP" "$BACKUP_FILE" 2>/dev/null
    $touch_kousei -d "$FILE_TIMESTAMP_1" "$BACKUP_FILE" 2>/dev/null
    
    $echo_kousei ""
    $echo_kousei "✅ Đã backup file cũ vào: $BACKUP_FILE"
  else
    $echo_kousei "ℹ️ Không tìm thấy file cũ, không cần backup."
    $echo_kousei ""
    $echo_kousei "❌ Vui lòng kiểm tra lại phiên bản của game.!"
    $echo_kousei ""
  fi
else
  $echo_kousei "🔵 Script by Kousei"
  $echo_kousei "========================================"
fi

UNINSTALL_SCRIPT_UP="/data/adb/modules_update/aov_unlock/uninstall.sh"
UNINSTALL_SCRIPT_DIR="$MODPATH/uninstall.sh"
UNINSTALL_SCRIPT="/data/adb/modules/aov_unlock/uninstall.sh"
if $grep_kousei -q "KOUSEI_BACKUP=" "$UNINSTALL_SCRIPT" 2>/dev/null; then
  $sed_kousei -i "s/^KOUSEI_BACKUP=.*/KOUSEI_BACKUP=$KOUSEI_BACKUP/g" "$UNINSTALL_SCRIPT"
else
  $sleep_kousei 0
fi

if $grep_kousei -q "KOUSEI_BACKUP=" "$UNINSTALL_SCRIPT_UP" 2>/dev/null; then
  $sed_kousei -i "s/^KOUSEI_BACKUP=.*/KOUSEI_BACKUP=$KOUSEI_BACKUP/g" "$UNINSTALL_SCRIPT_UP"
else
  $sleep_kousei 0
fi

if $grep_kousei -q "KOUSEI_BACKUP=" "$UNINSTALL_SCRIPT_DIR" 2>/dev/null; then
  $sed_kousei -i "s/^KOUSEI_BACKUP=.*/KOUSEI_BACKUP=$KOUSEI_BACKUP/g" "$UNINSTALL_SCRIPT_DIR"
else
  $sleep_kousei 0
fi

TMP_FILE="/data/local/tmp/$FOLDER_NAME"
$rm_kousei -rf $TMP_FILE
$echo_kousei ""
$echo_kousei "🔄 Đang tải file mới nhất từ: $ASSET_URL"
$echo_kousei ""
$echo_kousei "🔗 Đang tải xuống, vui lòng chờ..."

$curl_kousei -L -o "$TMP_FILE" "$ASSET_URL" --progress-bar

if [ $? -eq 0 ]; then
  $echo_kousei ""
  $echo_kousei "✅ Tải file thành công!"

    $rm_kousei -f "$ORIGINAL_FILE" || {
    $echo_kousei "❌ Không thể xóa file gốc!"
    exit 1
    }

    $install_kousei -m "$FILE_MODE" -o "$FILE_OWNER" -g "$FILE_GROUP" "$TMP_FILE" "$ORIGINAL_FILE" || {
    $echo_kousei "❌ Copy file mới thất bại!"
    exit 1
    }

    $chmod_kousei "$FILE_MODE" "$ORIGINAL_FILE" 2>/dev/null
    $chcon_kousei "$FILE_CONTEXT" "$ORIGINAL_FILE" 2>/dev/null
    $chown_kousei "$FILE_OWNER:$FILE_GROUP" "$ORIGINAL_FILE" 2>/dev/null
    $touch_kousei -r "$FILE_TIMESTAMP" "$ORIGINAL_FILE" 2>/dev/null
    $touch_kousei -d "$FILE_TIMESTAMP_1" "$ORIGINAL_FILE" 2>/dev/null

    if [ -f "$ORIGINAL_FILE" ]; then
    $echo_kousei ""
    $echo_kousei "✅ File đã được cập nhật thành công tại: $DEST_FILE"
    $echo_kousei ""
    else
    $echo_kousei "❌ File mới không tồn tại sau khi copy!"
    exit 1
    fi
else
  $echo_kousei "❌ Lỗi tải file!"
  exit 1
fi

if [ "$CURRENT_SELINUX" = "Enforcing" ]; then
    $setenforce_kousei 1
fi

if [ -z "$LATEST_DIR" ]; then
    description="description=❌! Không tìm thấy thư mục Resources!"
else
    RESOURCE_PATH="${RESOURCE_DIR}${LATEST_DIR}"
    description="description=✅ Resources Hiện tại: $LATEST_DIR"
fi

if $grep_kousei -q "description=" "$KOUSEI_VN2_DIR" 2>/dev/null; then
  $sed_kousei -i "s/^description=.*/$description/g" "$KOUSEI_VN2_DIR"
else
  $sleep_kousei 0
fi

if $grep_kousei -q "description=" "$KOUSEI_VN2_UP" 2>/dev/null; then
  $sed_kousei -i "s/^description=.*/$description/g" "$KOUSEI_VN2_UP"
else
  $sleep_kousei 0
fi

if $grep_kousei -q "description=" "$KOUSEI_VN2" 2>/dev/null; then
  $sed_kousei -i "s/^description=.*/$description/g" "$KOUSEI_VN2"
else
  $sleep_kousei 0
fi

$rm_kousei -rf $TMP_FILE
$echo_kousei "✅ Đã xong!"