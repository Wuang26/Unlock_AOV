#!/system/bin/sh

[ -z "$MODPATH" ] && MODPATH="/data/adb/modules_update/aov_unlock/"

method_patch="hex"
#method_patch="lib"
RESOURCE_VER="/data/user/0/com.garena.game.kgvn/files/Resources/"
KOUSEI_VN2="/data/adb/modules/aov_unlock/module.prop"
KOUSEI_VN2_DIR="$MODPATH/module.prop"
KOUSEI_VN2_UP="/data/adb/modules_update/aov_unlock/module.prop"
SERVICES_SCRIPT_UP="/data/adb/modules_update/aov_unlock/service.sh"
SERVICES_SCRIPT_DIR="$MODPATH/service.sh"
SERVICES_SCRIPT="/data/adb/modules/aov_unlock/service.sh"
UNINSTALL_SCRIPT_UP="/data/adb/modules_update/aov_unlock/uninstall.sh"
UNINSTALL_SCRIPT_DIR="$MODPATH/uninstall.sh"
UNINSTALL_SCRIPT="/data/adb/modules/aov_unlock/uninstall.sh"
tools_kousei="/data/local/tmp/tools/kousei"
required_tools="echo sleep sed rm mkdir ls head grep cut curl cp chmod basename am id chcon install getenforce printf setenforce awk stat chown getevent touch"

# Hàm chung cho cả hai phương thức
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

check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "❌ Yêu cầu quyền root để tiếp tục!" >&2
        exit 1
    fi
}

check_tools() {
  for tool in $required_tools; do
    tool_path=$(get_tool_path "$tool")
    
    if [ "$tool_path" = "$tool" ]; then
      echo "⚠️ Không tìm thấy công cụ: $tool, sử dụng công cụ hệ thống mặc định."
    fi
  done
  echo " "
  echo "✅ Tất cả các công cụ đã sẵn sàng!"
}

update_module_prop() {
    local version_resources="$1"
    local description="$2"
    local method_patch="$3"

    if $grep_kousei -q "version=" "$KOUSEI_VN2_DIR" 2>/dev/null; then
        $sed_kousei -i "s/^version=.*/$version_resources/g" "$KOUSEI_VN2_DIR"
    fi

    if $grep_kousei -q "version=" "$KOUSEI_VN2_UP" 2>/dev/null; then
        $sed_kousei -i "s/^version=.*/$version_resources/g" "$KOUSEI_VN2_UP"
    fi

    if $grep_kousei -q "version=" "$KOUSEI_VN2" 2>/dev/null; then
        $sed_kousei -i "s/^version=.*/$version_resources/g" "$KOUSEI_VN2"
    fi

    if $grep_kousei -q "description=" "$KOUSEI_VN2_DIR" 2>/dev/null; then
        $sed_kousei -i "s/^description=.*/$description/g" "$KOUSEI_VN2_DIR"
    fi

    if $grep_kousei -q "description=" "$KOUSEI_VN2_UP" 2>/dev/null; then
        $sed_kousei -i "s/^description=.*/$description/g" "$KOUSEI_VN2_UP"
    fi

    if $grep_kousei -q "description=" "$KOUSEI_VN2" 2>/dev/null; then
        $sed_kousei -i "s/^description=.*/$description/g" "$KOUSEI_VN2"
    fi

    if $grep_kousei -q "methodpatch=" "$KOUSEI_VN2_DIR" 2>/dev/null; then
        $sed_kousei -i "s/^methodpatch=.*/methodpatch=$method_patch/g" "$KOUSEI_VN2_DIR"
    fi

    if $grep_kousei -q "methodpatch=" "$KOUSEI_VN2_UP" 2>/dev/null; then
        $sed_kousei -i "s/^methodpatch=.*/methodpatch=$method_patch/g" "$KOUSEI_VN2_UP"
    fi

    if $grep_kousei -q "methodpatch=" "$KOUSEI_VN2" 2>/dev/null; then
        $sed_kousei -i "s/^methodpatch=.*/methodpatch=$method_patch/g" "$KOUSEI_VN2"
    fi
}

select_method() {
    $echo_kousei "🔊 Sử dụng nút ÂM LƯỢNG để chọn:"
    $echo_kousei "  - TĂNG ÂM: Chọn phương thức LIB"
    $echo_kousei "  - GIẢM ÂM: Chọn phương thức HEX"
    $echo_kousei "⏳ Đang chờ nhấn phím..."

    timeout=7
    start_time=$(date +%s)
    time_count=0
    selected=""
    
    while [ $(($(date +%s) - start_time)) -lt $timeout ] && [ -z "$selected" ]; do
        key_event=$(timeout 0.1 $getevent_kousei -qlc 1 2>/dev/null | $awk_kousei '{print $3}')
        
        case "$key_event" in
            "KEY_VOLUMEUP")
                method_patch="lib"
                selected=1
                $echo_kousei "✅ Đã chọn: LIB (Thay thế thư viện)"
                ;;
            "KEY_VOLUMEDOWN")
                method_patch="hex"
                selected=1
                $echo_kousei "✅ Đã chọn: HEX (Patch mã máy)"
                ;;
            "KEY_POWER")
                $echo_kousei "❗ Đã hủy lựa chọn"
                exit 1
                ;;
            *)
                time_count=$((time_count + 1))
                sleep 0.1
                ;;
        esac
    done

    if [ -z "$selected" ]; then
        MODULE_PROP="$MODPATH/module.prop"
        if [ ! -f "$MODULE_PROP" ]; then
            MODULE_PROP="/data/adb/modules/aov_unlock/module.prop"
            if [ ! -f "$MODULE_PROP" ]; then
                $echo_kousei "⏰ Hết thời gian và không tìm thấy file module.prop"
                $echo_kousei "ℹ️ Sử dụng phương thức mặc định: hex"
                method_patch="hex"
            fi
        fi
        if [ -f "$MODULE_PROP" ]; then
            method_patch=$($grep_kousei -E '^methodpatch=' "$MODULE_PROP" | $cut_kousei -d= -f2)
            case "$method_patch" in
                "hex"|"lib") 
                    $echo_kousei "⏰ Hết thời gian, sử dụng phương thức từ module.prop: $method_patch"
                    ;;
                *) 
                    method_patch="hex"
                    $echo_kousei "⏰ Hết thời gian, giá trị không hợp lệ trong module.prop, mặc định: hex"
                    ;;
            esac
        fi
    fi
}

ask_open_release_page() {
    $echo_kousei ""
    $echo_kousei "❌ Vui lòng kiểm tra lại phiên bản của Game hoặc Module."
    $echo_kousei ""
    $echo_kousei "❓Bạn có muốn mở trang phát hành module không?:"
    $echo_kousei "  - TĂNG ÂM: Mở trang phát hành module"
    $echo_kousei "  - GIẢM ÂM: Thoát"

    while true; do
        key_event=$($getevent_kousei -qlc 1 2>/dev/null | $awk_kousei '{print $3}')
        case "$key_event" in
            "KEY_VOLUMEUP")
                $echo_kousei "🔗 Đang mở trang phát hành module..."
                $am_kousei start -a android.intent.action.VIEW -d "https://github.com/Wuang26/Unlock_AOV/releases" >/dev/null 2>&1
                return 0
                ;;
            "KEY_VOLUMEDOWN")
                $echo_kousei "🚪 Thoát."
                exit 1
                ;;
        esac
        $sleep_kousei 0.1
    done
}

# Khởi tạo các công cụ
getevent_kousei=$(get_tool_path "getevent")
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

# Phương thức patch lib
patch_lib() {
    $echo_kousei "🔄 Bắt đầu phương thức patch lib..."
    
KOUSEI_BACKUP=0

GITHUB_USER="Wuang26"
GITHUB_REPO="Unlock_AOV"
LATEST_DIR=$($ls_kousei -1t "$RESOURCE_VER" 2>/dev/null | $head_kousei -n 1)
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

if [ ! -d "$DEST_FOLDER" ]; then
  $echo_kousei "❌ Thư mục không tồn tại: $DEST_FOLDER"
  $rm_kousei -rf "/data/user/0/com.garena.game.kgvn/files/Resources/*"

  $echo_kousei "⚠️ Thư mục data game hiện không đúng."
  $echo_kousei "▶️ Vui lòng đừng đóng ứng dụng này mà vào Game và đợi load đến sảnh chính."
  $echo_kousei "▶️ Sau đó quay lại đây và bấm phím bất kỳ để tiếp tục..."
  $sleep_kousei 15
  while true; do
      key_event=$($getevent_kousei -qlc 1 2>/dev/null | $awk_kousei '{print $3}')
      if [ "$key_event" = "KEY_VOLUMEUP" ] || [ "$key_event" = "KEY_VOLUMEDOWN" ]; then
          break
      fi
      $sleep_kousei 0.1
  done

$echo_kousei " "
$echo_kousei "🔃 Đang kiểm tra lại thư mục resources..."
$sleep_kousei 3

  if [ -d "$DEST_FOLDER" ]; then
      $echo_kousei "✅ Tiếp tục..."
  else
      ask_open_release_page
  fi
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

if [ -z "$LATEST_DIR" ]; then
    description="description=❌! Không tìm thấy thư mục Resources!"
else
    RESOURCE_PATH="${RESOURCE_VER}${LATEST_DIR}"
    description="description=✅ Resources Hiện tại: $LATEST_DIR"
fi

update_module_prop "$version_resources" "$description" "lib"

$rm_kousei -rf $TMP_FILE
$echo_kousei "✅ Đã xong!"
}

# Phương thức patch hex
patch_hex() {
    $echo_kousei "🔵 Script by Kousei"
    $echo_kousei "========================================"
    $echo_kousei " "
    $echo_kousei "🔄 Bắt đầu phương thức patch hex..."
    
    MODULE_PROP_URL="https://raw.githubusercontent.com/Wuang26/Unlock_AOV/refs/heads/main/module.prop"
TMP_DIR=$(mktemp -d)
MODULE_PROP="$TMP_DIR/module.prop"

if ! $curl_kousei -sLo "$MODULE_PROP" "$MODULE_PROP_URL"; then
    $echo_kousei "Không thể tải file module.prop" >&2
    $rm_kousei -rf "$TMP_DIR"
    exit 1
fi
get_value() {
    key="$1"
    $grep_kousei "^$key=" "$MODULE_PROP" | cut -d= -f2-
}

rv_60=$(get_value "supported60fpsmode")
rv_90=$(get_value "supported90fpsmode")
rv_120=$(get_value "supported120fpsmode")
rv_both=$(get_value "supportedboth60fps")
rv_ipad=$(get_value "isipaddevice")
rv_host=$(get_value "ishostprofile")
resources=$(get_value "resources")
hex_data=$(get_value "arm64")

if [[ -z "$resources" || -z "$hex_data" ]]; then
    $echo_kousei " "
    $echo_kousei "❌ File module.prop thiếu resources hoặc arm64" >&2
    $rm_kousei -rf "$TMP_DIR"
    exit 1
fi

RESOURCE_DIR="/data/user/0/com.garena.game.kgvn/files/Resources/$resources/arm64-v8a"
LATEST_DIR=$($ls_kousei -1t "$RESOURCE_VER" 2>/dev/null | $head_kousei -n 1)
TARGET_FILE="$RESOURCE_DIR/libil2cpp.so"

if [ ! -d "$RESOURCE_DIR" ]; then
  $echo_kousei "❌ Thư mục không tồn tại: $RESOURCE_DIR"
  $rm_kousei -rf "/data/user/0/com.garena.game.kgvn/files/Resources/*"

  $echo_kousei "⚠️ Thư mục data game hiện không đúng."
  $echo_kousei "▶️ Vui lòng đừng đóng ứng dụng này mà vào Game và đợi load đến sảnh chính."
  $echo_kousei "▶️ Sau đó quay lại đây và bấm phím bất kỳ để tiếp tục..."
  $sleep_kousei 15
  while true; do
      key_event=$($getevent_kousei -qlc 1 2>/dev/null | $awk_kousei '{print $3}')
      if [ "$key_event" = "KEY_VOLUMEUP" ] || [ "$key_event" = "KEY_VOLUMEDOWN" ]; then
          break
      fi
      $sleep_kousei 0.1
  done

$echo_kousei " "
$echo_kousei "🔃 Đang kiểm tra lại thư mục resources..."
$sleep_kousei 3

  if [ -d "$RESOURCE_DIR" ]; then
      $echo_kousei "✅ Tiếp tục..."
  else
      ask_open_release_page
  fi
fi

if [ ! -f "$TARGET_FILE" ]; then
    $echo_kousei " "
    $echo_kousei "❌ File đích không tồn tại: $TARGET_FILE" >&2
    $rm_kousei -rf "$TMP_DIR"
    exit 1
fi

original_owner=$($stat_kousei -c %u:%g "$TARGET_FILE")
original_perms=$($stat_kousei -c %a "$TARGET_FILE")
original_timestamp=$($stat_kousei -c %y "$TARGET_FILE")

hex_bytes=$($echo_kousei "$hex_data" | $sed_kousei -E 's/../\\x&/g')

patch_file() {
    rva_hex="$1"

    if [ -z "$rva_hex" ]; then
        return 0
    fi

    offset=$((rva_hex))

    if ! $printf_kousei "$hex_bytes" | dd of="$TARGET_FILE" bs=1 seek="$offset" conv=notrunc status=none; then
        $echo_kousei " "
        $echo_kousei "❌ Lỗi khi ghi patch tại RVA $rva_hex" >&2
        return 1
    fi
}

errors=0
for rva in "$rv_60" "$rv_90" "$rv_120" "$rv_both" "$rv_ipad" "$rv_host"; do
    patch_file "$rva" || ((errors++))
done

$chown_kousei "$original_owner" "$TARGET_FILE"
$chmod_kousei "$original_perms" "$TARGET_FILE"
$touch_kousei -d "$original_timestamp" "$TARGET_FILE"

$rm_kousei -rf "$TMP_DIR"

if [ "$errors" -ne 0 ]; then
    $echo_kousei " "
    $echo_kousei "⚠️ Hoàn thành với $errors lỗi" >&2
    exit 1
else
    $echo_kousei " "
    $echo_kousei "✅ Patch thành công!"
fi

version_resources="version=$resources"
FOLDER_NAME="$resources"

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

if [ -z "$LATEST_DIR" ]; then
    description="description=❌! Không tìm thấy thư mục Resources!"
else
    RESOURCE_PATH="${RESOURCE_VER}${LATEST_DIR}"
    description="description=✅ Resources Hiện tại: $LATEST_DIR"
fi

update_module_prop "$version_resources" "$description" "hex"
}

check_root
check_tools
select_method

CURRENT_SELINUX=$($getenforce_kousei)
[ "$CURRENT_SELINUX" = "Enforcing" ] && $setenforce_kousei 0

case "$method_patch" in
    "lib") patch_lib ;;
    "hex") patch_hex ;;
    *) $echo_kousei "❌ Lựa chọn không hợp lệ!"; exit 1 ;;
esac

[ "$CURRENT_SELINUX" = "Enforcing" ] && $setenforce_kousei 1

$echo_kousei " "
$echo_kousei "✅ Đã hoàn thành tất cả thao tác!"
exit 0