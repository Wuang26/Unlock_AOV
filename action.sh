#!/system/bin/sh

if [ "$(id -u)" != "0" ]; then
  echo "❌ Cần chạy với quyền root!"
  exit 1
fi

GITHUB_USER="Wuang26"
GITHUB_REPO="Unlock_AOV"

ASSET_URL=$(curl -s "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest" | grep "browser_download_url" | cut -d '"' -f 4 | head -n 1)

if [ -z "$ASSET_URL" ]; then
  echo "❌ Không tìm thấy file mới nhất!"
  exit 1
fi

FOLDER_NAME=$(basename "$ASSET_URL")

GAME_BASE_PATH="/data/user/0/com.garena.game.kgvn/files/Resources"

DEST_FOLDER="$GAME_BASE_PATH/$FOLDER_NAME/arm64-v8a"

if [ ! -d "$DEST_FOLDER" ]; then
  echo "❌ Thư mục không tồn tại: $DEST_FOLDER"
  exit 1
fi

DEST_FILE="$DEST_FOLDER/libil2cpp.so"

BACKUP_FOLDER="/data/local/tmp/kousei_backup"
BACKUP_FILE="$BACKUP_FOLDER/libil2cpp_$(date +%Y%m%d_%H%M%S).so"

if [ -f "$DEST_FILE" ]; then
  echo "🔄 Tìm thấy file hiện tại: $DEST_FILE"

  mkdir -p "$BACKUP_FOLDER"
  rm -rf $BACKUP_FOLDER/*

  cp "$DEST_FILE" "$BACKUP_FILE"

  echo "✅ Đã backup file cũ vào: $BACKUP_FILE"
else
  echo "ℹ️ Không tìm thấy file cũ, không cần backup."
fi

TMP_FILE="/data/local/tmp/$FOLDER_NAME"

echo "🔄 Đang tải file mới nhất từ: $ASSET_URL"

curl -L -o "$TMP_FILE" "$ASSET_URL"

if [ $? -eq 0 ]; then
  echo "✅ Tải file thành công!"

  if [ -f "$DEST_FILE" ]; then
    rm "$DEST_FILE"
    echo "🗑️ Đã xóa file cũ: $DEST_FILE"
  fi

  mv "$TMP_FILE" "$DEST_FILE"

  chmod 755 "$DEST_FILE"

  echo "✅ File đã được cập nhật thành công tại: $DEST_FILE"
else
  echo "❌ Lỗi tải file!"
  exit 1
fi

KOUSEI_VN2="/data/adb/modules/aov_unlock/module.prop"

RESOURCE_DIR="/data/user/0/com.garena.game.kgvn/files/Resources/"
LATEST_DIR=$(ls -1t "$RESOURCE_DIR" 2>/dev/null | head -n 1)

if [ -z "$LATEST_DIR" ]; then
    description="description=❌! Không tìm thấy thư mục Resources!"
else
    RESOURCE_PATH="${RESOURCE_DIR}${LATEST_DIR}"
    description="description=✅! Resources Hiện tại: $LATEST_DIR"
fi

sed -i "s/^description=.*/$description/g" "$KOUSEI_VN2"