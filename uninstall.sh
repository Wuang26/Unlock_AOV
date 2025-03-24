#!/system/bin/sh

KOUSEI_BACKUP=0

tools_kousei="/data/local/tmp/tools/kousei"
required_tools="echo sleep sed rm mkdir ls head grep cut curl cp chmod basename am id chcon install getenforce setenforce awk stat"

get_tool_path() {
    tool="$1"
    kousei_tool="$tools_kousei/$tool"
    
    if [ -f "$kousei_tool" ] && [ -x "$kousei_tool" ]; then
        $echo_kousei "$kousei_tool"
    else
        system_tool=$(command -v "$tool")
        if [ -n "$system_tool" ]; then
            $echo_kousei "$system_tool"
        else
            $echo_kousei "$tool"
        fi
    fi
}

stat_kousei=$(get_tool_path "stat")
awk_kousei=$(get_tool_path "awk")
setenforce_kousei=$(get_tool_path "setenforce")
install_kousei=$(get_tool_path "install")
getenforce_kousei=$(get_tool_path "getenforce")
chcon_kousei=$(get_tool_path "chcon")
$echo_kousei=$(get_tool_path "echo")
sleep_kousei=$(get_tool_path "sleep")
sed_kousei=$(get_tool_path "sed")
$rm_kousei=$(get_tool_path "rm")
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

CURRENT_SELINUX=$($getenforce_kousei)
KOUSEI_VN1="/data/user/0/com.garena.game.kgvn/files/Resources"
KOUSEI_VN2="/data/data/com.garena.game.kgvn/files/Resources"
KOUSEI_VN3="/data/system/package_cache/"

if [ "$KOUSEI_BACKUP" -ne 1 ]; then
  $echo_kousei "Backup mode: $KOUSEI_BACKUP"
    $rm_kousei -rf $KOUSEI_VN1
    $rm_kousei -rf $KOUSEI_VN2
    $rm_kousei -rf $KOUSEI_VN3
  exit 0
fi

if [ "$CURRENT_SELINUX" = "Enforcing" ]; then
    $setenforce_kousei 0
fi

BACKUP_FOLDER="/data/local/tmp/kousei_backup"

if [ ! -d "$BACKUP_FOLDER" ]; then
  $echo_kousei "❌ Thư mục backup không tồn tại!"
  exit 1
fi

LATEST_BACKUP=$($ls_kousei -t "$BACKUP_FOLDER"/libil2cpp_*.so 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  $echo_kousei "❌ Không tìm thấy file backup!"
  exit 1
fi

GAME_BASE_PATH="/data/user/0/com.garena.game.kgvn/files/Resources"

LATEST_FOLDER=$($ls_kousei -d "$GAME_BASE_PATH"/*/ 2>/dev/null | sort -r | head -n 1)

if [ -z "$LATEST_FOLDER" ]; then
  $echo_kousei "❌ Không tìm thấy thư mục game hợp lệ trong: $GAME_BASE_PATH"
  exit 1
fi

LATEST_FOLDER_NAME=$($basename_kousei "$LATEST_FOLDER")

DEST_FOLDER="$GAME_BASE_PATH/$LATEST_FOLDER_NAME/arm64-v8a"

if [ ! -d "$DEST_FOLDER" ]; then
  $echo_kousei "❌ Không tìm thấy thư mục game: $DEST_FOLDER"
  exit 1
fi

DEST_FILE="$DEST_FOLDER/libil2cpp.so"

$echo_kousei "🔄 Đang khôi phục file từ: $LATEST_BACKUP vào $DEST_FILE"

if [ -f "$DEST_FILE" ]; then
  $rm_kousei "$DEST_FILE"
  $echo_kousei "🗑️ Đã xóa file hiện tại: $DEST_FILE"
fi

FILE_MODE=$($stat_kousei -c %a "$DEST_FILE")
FILE_OWNER=$($stat_kousei -c %U "$DEST_FILE")
FILE_GROUP=$($stat_kousei -c %G "$DEST_FILE")
FILE_CONTEXT=$($ls_kousei -Z "$DEST_FILE" | $awk_kousei '{print $1}')

$install_kousei -m "$FILE_MODE" -o "$FILE_OWNER" -g "$FILE_GROUP" "$LATEST_BACKUP" "$DEST_FILE"
$chcon_kousei "$FILE_CONTEXT" "$DEST_FILE"

if [ "$CURRENT_SELINUX" = "Enforcing" ]; then
    $setenforce_kousei 1
fi

$echo_kousei "✅ Đã khôi phục file thành công vào: $DEST_FILE"