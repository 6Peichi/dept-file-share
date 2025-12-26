#!/bin/bash

# 部門文件分享系統 - 打包腳本
# 用於製作發布版本的壓縮包
# 使用方式：./package.sh

set -e

VERSION="v1.0"
PACKAGE_NAME="dept-file-share-$VERSION"
OUTPUT_DIR="dist"

echo "=========================================="
echo "  部門文件分享系統 - 打包工具"
echo "  版本: $VERSION"
echo "=========================================="
echo ""

# 檢查必要檔案
echo "檢查必要檔案..."

REQUIRED_FILES=(
    "app.py"
    "requirements.txt"
    "start.sh"
    "stop.sh"
    "status.sh"
    "install.sh"
    "README.md"
    "INSTALL.md"
    "CHECKLIST.md"
    "DOWNLOAD.md"
    "templates/home.html"
    "templates/files.html"
    "templates/bookmarks.html"
    "templates/excel_viewer.html"
    "templates/word_viewer.html"
)

MISSING=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ 缺少: $file"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -gt 0 ]; then
    echo ""
    echo "錯誤: 缺少 $MISSING 個必要檔案"
    echo "請確保所有檔案都已建立"
    exit 1
fi

echo "✅ 所有必要檔案都存在"
echo ""

# 建立輸出目錄
mkdir -p "$OUTPUT_DIR"

# 建立臨時目錄
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TEMP_DIR/$PACKAGE_NAME"
mkdir -p "$PACKAGE_DIR"

echo "建立發布包..."

# 複製檔案
cp -r \
    app.py \
    requirements.txt \
    start.sh \
    stop.sh \
    status.sh \
    install.sh \
    README.md \
    INSTALL.md \
    CHECKLIST.md \
    DOWNLOAD.md \
    templates \
    "$PACKAGE_DIR/"

# 建立空目錄
mkdir -p "$PACKAGE_DIR/uploaded_files"
mkdir -p "$PACKAGE_DIR/logs"

# 建立 .gitignore
cat > "$PACKAGE_DIR/.gitignore" << 'EOF'
# Python
venv/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python

# 應用資料
uploaded_files/*
!uploaded_files/.gitkeep
logs/*
!logs/.gitkeep
bookmarks.json
*.pid
*.backup

# 編輯器
.vscode/
.idea/
*.swp
*.swo
*~

# 系統檔案
.DS_Store
Thumbs.db
EOF

# 建立 .gitkeep
touch "$PACKAGE_DIR/uploaded_files/.gitkeep"
touch "$PACKAGE_DIR/logs/.gitkeep"

# 建立版本資訊
cat > "$PACKAGE_DIR/VERSION" << EOF
版本: $VERSION
發布日期: $(date +%Y-%m-%d)
描述: 部門文件分享系統 - 完整安裝包
EOF

# 建立 CHANGELOG.md
cat > "$PACKAGE_DIR/CHANGELOG.md" << 'EOF'
# 更新日誌

## v1.0 (2024-12-17)

### 新功能
- ✨ 檔案上傳下載功能
- ✨ 資料夾管理（支援多層級）
- ✨ Excel (.xlsx) 線上檢視與編輯
- ✨ Word (.docx) 線上檢視與編輯
- ✨ PDF/圖片瀏覽器內預覽
- ✨ 網址書籤管理
- ✨ 支援中文檔名

### 技術特性
- 🔧 背景執行模式
- 🔧 自動日誌分檔（按日期）
- 🔧 檔案自動備份機制
- 🔧 簡單的管理腳本

### 系統支援
- Ubuntu 22.04 LTS
- Python 3.8+
- 最大檔案上傳 500MB
EOF

# 打包完整版（含所有檔案）
echo "正在打包完整版..."
cd "$TEMP_DIR"
tar -czf "$PACKAGE_NAME-full.tar.gz" "$PACKAGE_NAME/"
mv "$PACKAGE_NAME-full.tar.gz" "$OLDPWD/$OUTPUT_DIR/"

# 打包精簡版（不含文件）
echo "正在打包精簡版..."
cd "$PACKAGE_DIR"
rm README.md INSTALL.md CHECKLIST.md DOWNLOAD.md CHANGELOG.md VERSION
cd "$TEMP_DIR"
tar -czf "$PACKAGE_NAME-lite.tar.gz" "$PACKAGE_NAME/"
mv "$PACKAGE_NAME-lite.tar.gz" "$OLDPWD/$OUTPUT_DIR/"

# 建立 ZIP 版本（Windows 友好）
echo "正在建立 ZIP 版本..."
cd "$OLDPWD/$OUTPUT_DIR"
tar -xzf "$PACKAGE_NAME-full.tar.gz"
zip -r "$PACKAGE_NAME-full.zip" "$PACKAGE_NAME/" > /dev/null
rm -rf "$PACKAGE_NAME"

# 清理臨時檔案
rm -rf "$TEMP_DIR"

# 計算檔案大小和 MD5
echo ""
echo "=========================================="
echo "  打包完成！"
echo "=========================================="
echo ""
echo "輸出目錄: $OUTPUT_DIR/"
echo ""

cd "$OUTPUT_DIR"
for file in *; do
    SIZE=$(du -h "$file" | cut -f1)
    MD5=$(md5sum "$file" | cut -d' ' -f1)
    echo "檔案: $file"
    echo "  大小: $SIZE"
    echo "  MD5: $MD5"
    echo ""
done

# 建立發布說明
cat > RELEASE.md << EOF
# 部門文件分享系統 $VERSION 發布

## 下載

### 完整版（推薦）
包含所有檔案和文件，適合新手使用。

- **TAR.GZ**: $PACKAGE_NAME-full.tar.gz
- **ZIP**: $PACKAGE_NAME-full.zip

### 精簡版
只包含必要的程式檔案，適合進階使用者。

- **TAR.GZ**: $PACKAGE_NAME-lite.tar.gz

## 安裝方式

### 方法一：解壓後安裝

\`\`\`bash
# 下載並解壓
tar -xzf $PACKAGE_NAME-full.tar.gz
cd $PACKAGE_NAME

# 執行安裝
chmod +x install.sh
./install.sh
\`\`\`

### 方法二：一鍵安裝

\`\`\`bash
curl -fsSL https://your-url/one-click-install.sh | bash
\`\`\`

## 系統需求

- Ubuntu 22.04 LTS（或其他 Linux）
- Python 3.8+
- 4GB RAM（建議 8GB）
- 50GB 硬碟空間

## 主要功能

- 檔案上傳/下載
- Excel/Word 線上編輯
- 網址書籤管理
- 支援中文檔名
- 背景執行

## 更新說明

請參考 CHANGELOG.md 查看完整更新內容。

## 技術支援

- 文件: 請參考 README.md 和 INSTALL.md
- 問題: 請在 GitHub Issues 提問
- Email: support@your-domain.com

---

發布日期: $(date +%Y-%m-%d)
EOF

echo "發布說明: $OUTPUT_DIR/RELEASE.md"
echo ""
echo "下一步："
echo "1. 測試安裝包"
echo "2. 上傳到 GitHub Releases"
echo "3. 更新下載連結"
echo "4. 發布公告"
echo ""
