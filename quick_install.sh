#!/bin/bash

# 部門文件分享系統 - 快速安裝腳本
# 使用方法：bash install.sh

set -e  # 遇到錯誤即停止

echo "=========================================="
echo "  部門文件分享系統 - 快速安裝"
echo "=========================================="
echo ""

# 檢查是否為 root
if [ "$EUID" -eq 0 ]; then 
   echo "⚠️  請不要使用 root 執行此腳本"
   exit 1
fi

# 檢查 Python 版本
echo "檢查 Python 版本..."
if ! command -v python3 &> /dev/null; then
    echo "❌ 找不到 Python3，正在安裝..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "✅ Python 版本: $PYTHON_VERSION"

# 檢查是否在專案目錄
if [ ! -f "app.py" ]; then
    echo "❌ 找不到 app.py，請確認您在正確的目錄中"
    exit 1
fi

echo ""
echo "步驟 1/5: 建立目錄結構..."
mkdir -p templates
mkdir -p uploaded_files
mkdir -p logs
echo "✅ 目錄建立完成"

echo ""
echo "步驟 2/5: 建立 Python 虛擬環境..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "✅ 虛擬環境建立完成"
else
    echo "✅ 虛擬環境已存在"
fi

echo ""
echo "步驟 3/5: 安裝 Python 套件..."
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt

echo "✅ 套件安裝完成"

echo ""
echo "步驟 4/5: 檢查檔案完整性..."

# 檢查必要檔案
REQUIRED_FILES=(
    "app.py"
    "start.sh"
    "stop.sh"
    "status.sh"
    "requirements.txt"
    "templates/home.html"
    "templates/files.html"
    "templates/bookmarks.html"
    "templates/excel_viewer.html"
    "templates/word_viewer.html"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ 缺少檔案: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -gt 0 ]; then
    echo ""
    echo "⚠️  發現 $MISSING_FILES 個缺少的檔案"
    echo "請參考 INSTALL.md 手動建立這些檔案"
    exit 1
fi

echo "✅ 所有必要檔案都存在"

echo ""
echo "步驟 5/5: 設定執行權限..."
chmod +x start.sh stop.sh status.sh
echo "✅ 權限設定完成"

echo ""
echo "=========================================="
echo "  🎉 安裝完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "1. 啟動系統: ./start.sh"
echo "2. 檢查狀態: ./status.sh"
echo "3. 訪問網站: http://localhost:5000"
echo ""
echo "查看完整文件: cat INSTALL.md"
echo ""

# 詢問是否立即啟動
read -p "是否要立即啟動系統？ (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "正在啟動系統..."
    ./start.sh
    sleep 2
    ./status.sh
fi