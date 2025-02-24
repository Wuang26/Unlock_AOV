#!/system/bin/sh

# Kiểm tra quyền root
if [ "$(id -u)" != "0" ]; then
  echo "❌ Cần chạy với quyền root!"
  exit 1
fi

# Đường dẫn thư mục backup
BACKUP_FOLDER="/data/local/tmp/kousei_backup"

# Kiểm tra nếu thư mục backup tồn tại
if [ ! -d "$BACKUP_FOLDER" ]; then
  echo "❌ Thư mục backup không tồn tại!"
  exit 1
fi

# Tìm file backup mới nhất
LATEST_BACKUP=$(ls -t "$BACKUP_FOLDER"/libil2cpp_*.so 2>/dev/null | head -n 1)

# Kiểm tra nếu không có file backup nào
if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ Không tìm thấy file backup!"
  exit 1
fi

# Đường dẫn gốc thư mục game
GAME_BASE_PATH="/data/user/0/com.garena.game.kgvn/files/Resources"

# Tìm thư mục game mới nhất (vì tên thư mục thay đổi mỗi lần update)
LATEST_FOLDER=$(ls -d "$GAME_BASE_PATH"/*/ 2>/dev/null | sort -r | head -n 1)

# Kiểm tra nếu không có thư mục nào
if [ -z "$LATEST_FOLDER" ]; then
  echo "❌ Không tìm thấy thư mục game hợp lệ trong: $GAME_BASE_PATH"
  exit 1
fi

# Lấy đúng tên thư mục game
LATEST_FOLDER_NAME=$(basename "$LATEST_FOLDER")

# Đường dẫn chính xác đến thư mục game
DEST_FOLDER="$GAME_BASE_PATH/$LATEST_FOLDER_NAME/arm64-v8a"

# Kiểm tra nếu thư mục game tồn tại
if [ ! -d "$DEST_FOLDER" ]; then
  echo "❌ Không tìm thấy thư mục game: $DEST_FOLDER"
  exit 1
fi

# Đường dẫn file đích
DEST_FILE="$DEST_FOLDER/libil2cpp.so"

echo "🔄 Đang khôi phục file từ: $LATEST_BACKUP vào $DEST_FILE"

# Xóa file hiện tại nếu tồn tại
if [ -f "$DEST_FILE" ]; then
  rm "$DEST_FILE"
  echo "🗑️ Đã xóa file hiện tại: $DEST_FILE"
fi

# Sao chép file backup vào thư mục game
cp "$LATEST_BACKUP" "$DEST_FILE"

# Cấp quyền cho file mới
chmod 755 "$DEST_FILE"

echo "✅ Đã khôi phục file thành công vào: $DEST_FILE"