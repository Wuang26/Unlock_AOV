#!/system/bin/sh
tools_kousei="/data/local/tmp/tools/kousei"
required_tools="echo sleep sed rm mkdir ls head grep cut curl cp chmod basename am id"

check_tools() {
  for tool in $required_tools; do
    tool_path="$tools_kousei/$tool"
    if [ ! -f "$tool_path" ] || [ ! -x "$tool_path" ]; then
      echo "❌ Công cụ thiếu hoặc không thực thi được: $tool_path"
      exit 1
    fi
  done
  echo "✅ Tất cả các công cụ đã sẵn sàng!"
}

# Kiểm tra quyền root
if [ "$($tools_kousei/id -u)" != "0" ]; then
  echo "❌ Cần chạy với quyền root!"
  exit 1
fi

check_tools

echo_kousei="$tools_kousei/echo"
sleep_kousei="$tools_kousei/sleep"
sed_kousei="$tools_kousei/sed"
rm_kousei="$tools_kousei/rm"
mkdir_kousei="$tools_kousei/mkdir"
ls_kousei="$tools_kousei/ls"
head_kousei="$tools_kousei/head"
grep_kousei="$tools_kousei/grep"
cut_kousei="$tools_kousei/cut"
curl_kousei="$tools_kousei/curl"
cp_kousei="$tools_kousei/cp"
chmod_kousei="$tools_kousei/chmod"
basename_kousei="$tools_kousei/basename"
am_kousei="$tools_kousei/am"
id_kousei="$tools_kousei/id"

$echo_kousei "✅ Bắt đầu thực thi script..."
$echo_kousei ""

chmod +x "$tools_kousei/"*

KOUSEI_BACKUP=0

GITHUB_USER="Wuang26"
GITHUB_REPO="Unlock_AOV"
KOUSEI_VN2="/data/adb/modules/aov_unlock/module.prop"
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
SERVICES_SCRIPT="/data/adb/modules/aov_unlock/service.sh"

if $grep_kousei -q "FOLDER_NAME=" "$SERVICES_SCRIPT"; then
  $sed_kousei -i "s/^FOLDER_NAME=.*/FOLDER_NAME=$FOLDER_NAME/g" "$SERVICES_SCRIPT"
else
  $echo_kousei ""
fi
$sed_kousei -i "s/^version=.*/$version_resources/g" "$KOUSEI_VN2"

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

if [ "$KOUSEI_BACKUP" -eq 1 ]; then
  if [ -f "$DEST_FILE" ]; then
    $echo_kousei "Script by Kousei"
    $echo_kousei ""
    $echo_kousei "🔄 Tìm thấy file hiện tại: $DEST_FILE"

    $mkdir_kousei -p "$BACKUP_FOLDER"
    $rm_kousei -rf "$BACKUP_FOLDER"/*

    $cp_kousei -p "$DEST_FILE" "$BACKUP_FILE"
    $echo_kousei ""
    $echo_kousei "✅ Đã backup file cũ vào: $BACKUP_FILE"
  else
    $echo_kousei "ℹ️ Không tìm thấy file cũ, không cần backup."
    $echo_kousei ""
    $echo_kousei "❌ Vui lòng kiểm tra lại phiên bản của game.!"
    $echo_kousei ""
  fi
else
  $echo_kousei "Script by Kousei"
fi

UNINSTALL_SCRIPT="/data/adb/modules/aov_unlock/uninstall.sh"
if $grep_kousei -q "KOUSEI_BACKUP=" "$UNINSTALL_SCRIPT"; then
  $sed_kousei -i "s/^KOUSEI_BACKUP=.*/KOUSEI_BACKUP=$KOUSEI_BACKUP/g" "$UNINSTALL_SCRIPT"
else
  $echo_kousei ""
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

  $cp_kousei -p "$TMP_FILE" "$DEST_FILE"

  $chmod_kousei 755 "$DEST_FILE"
  $echo_kousei ""
  $echo_kousei "✅ File đã được cập nhật thành công tại: $DEST_FILE"
  $echo_kousei ""
else
  $echo_kousei "❌ Lỗi tải file!"
  exit 1
fi

if [ -z "$LATEST_DIR" ]; then
    description="description=❌! Không tìm thấy thư mục Resources!"
else
    RESOURCE_PATH="${RESOURCE_DIR}${LATEST_DIR}"
    description="description=✅ Resources Hiện tại: $LATEST_DIR"
fi

$sed_kousei -i "s/^description=.*/$description/g" "$KOUSEI_VN2"
$rm_kousei -rf $TMP_FILE
$echo_kousei "✅ Đã xong!"
