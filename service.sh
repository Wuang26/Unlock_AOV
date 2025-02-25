#!/bin/sh

KOUSEI_VN2="/data/adb/modules/aov_unlock/module.prop"

RESOURCE_DIR="/data/data/com.garena.game.kgvn/files/Resources/"
LATEST_DIR=$(ls -1t "$RESOURCE_DIR" 2>/dev/null | head -n 1)

if [ -z "$LATEST_DIR" ]; then
    description="description=❌! Không tìm thấy thư mục Resources!"
else
    RESOURCE_PATH="${RESOURCE_DIR}${LATEST_DIR}"
    description="description=✅ Resources Hiện tại: $LATEST_DIR"
fi

sed -i "s/^description=.*/$description/g" "$KOUSEI_VN2"