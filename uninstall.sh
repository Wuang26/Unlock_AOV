#!/system/bin/sh

if [ "$(id -u)" != "0" ]; then
  echo "❌ Cần chạy với quyền root!"
  exit 1
fi

BACKUP_FOLDER="/data/local/tmp/kousei_backup"

if [ ! -d "$BACKUP_FOLDER" ]; then
  echo "❌ Thư mục backup không tồn tại!"
  exit 1
fi

LATEST_BACKUP=$(ls -t "$BACKUP_FOLDER"/libil2cpp_*.so 2>/dev/null | head -n 1)


if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ Không tìm thấy file backup!"
  exit 1
fi

GAME_BASE_PATH="/data/user/0/com.garena.game.kgvn/files/Resources"

LATEST_FOLDER=$(ls -d "$GAME_BASE_PATH"/*/ 2>/dev/null | sort -r | head -n 1)

if [ -z "$LATEST_FOLDER" ]; then
  echo "❌ Không tìm thấy thư mục game hợp lệ trong: $GAME_BASE_PATH"
  exit 1
fi

LATEST_FOLDER_NAME=$(basename "$LATEST_FOLDER")

DEST_FOLDER="$GAME_BASE_PATH/$LATEST_FOLDER_NAME/arm64-v8a"

if [ ! -d "$DEST_FOLDER" ]; then
  echo "❌ Không tìm thấy thư mục game: $DEST_FOLDER"
  exit 1
fi

DEST_FILE="$DEST_FOLDER/libil2cpp.so"

echo "🔄 Đang khôi phục file từ: $LATEST_BACKUP vào $DEST_FILE"

if [ -f "$DEST_FILE" ]; then
  rm "$DEST_FILE"
  echo "🗑️ Đã xóa file hiện tại: $DEST_FILE"
fi

cp "$LATEST_BACKUP" "$DEST_FILE"

chmod 755 "$DEST_FILE"

echo "✅ Đã khôi phục file thành công vào: $DEST_FILE"