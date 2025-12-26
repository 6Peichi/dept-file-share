#!/bin/bash

# 部門文件分享系統 - 一鍵安裝腳本
# 此腳本會自動完成所有安裝步驟
# 使用方式：curl -fsSL https://your-url/one-click-install.sh | bash

set -e  # 遇到錯誤即停止

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函數：印出帶顏色的訊息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 函數：檢查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 顯示歡迎訊息
clear
echo "=========================================="
echo "  部門文件分享系統 - 一鍵安裝"
echo "  版本: v1.0"
echo "=========================================="
echo ""

# 檢查是否為 root
if [ "$EUID" -eq 0 ]; then 
    print_error "請不要使用 root 執行此腳本"
    exit 1
fi

# 檢查作業系統
print_info "檢查作業系統..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    print_success "作業系統: $OS $VER"
else
    print_error "無法識別作業系統"
    exit 1
fi

# 步驟 1: 安裝系統套件
echo ""
print_info "步驟 1/7: 安裝系統基礎套件..."

if ! command_exists python3; then
    print_info "安裝 Python3..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv python3-dev
fi

if ! command_exists git; then
    print_info "安裝 Git..."
    sudo apt install -y git
fi

# 安裝其他必要工具
sudo apt install -y \
    build-essential \
    curl \
    wget \
    nano \
    net-tools \
    ufw \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libffi-dev \
    libssl-dev

print_success "系統套件安裝完成"

# 步驟 2: 建立專案目錄
echo ""
print_info "步驟 2/7: 建立專案目錄..."

INSTALL_DIR="$HOME/dept-file-share"

if [ -d "$INSTALL_DIR" ]; then
    print_warning "目錄已存在: $INSTALL_DIR"
    read -p "是否要刪除並重新安裝？ (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "備份舊資料..."
        if [ -d "$INSTALL_DIR/uploaded_files" ]; then
            tar -czf "$HOME/dept-file-share-backup-$(date +%Y%m%d%H%M%S).tar.gz" \
                -C "$INSTALL_DIR" uploaded_files bookmarks.json 2>/dev/null || true
            print_success "備份已儲存到: $HOME/dept-file-share-backup-*.tar.gz"
        fi
        rm -rf "$INSTALL_DIR"
    else
        print_error "安裝已取消"
        exit 1
    fi
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

print_success "目錄建立完成: $INSTALL_DIR"

# 步驟 3: 下載或建立檔案
echo ""
print_info "步驟 3/7: 下載專案檔案..."

# 嘗試從 GitHub 下載
GITHUB_REPO="https://github.com/your-repo/dept-file-share"
GIT_AVAILABLE=false

if command_exists git; then
    print_info "嘗試從 GitHub 克隆..."
    if git clone "$GITHUB_REPO.git" "$INSTALL_DIR" 2>/dev/null; then
        GIT_AVAILABLE=true
        print_success "從 GitHub 下載完成"
    else
        print_warning "無法從 GitHub 下載，將使用手動方式"
    fi
fi

# 如果無法從 Git 下載，建立基本檔案結構
if [ "$GIT_AVAILABLE" = false ]; then
    print_info "建立基本檔案結構..."
    
    mkdir -p templates
    
    # 建立 requirements.txt
    cat > requirements.txt << 'EOF'
Flask==3.0.0
openpyxl==3.1.2
python-docx==1.1.0
pandas==2.1.4
Werkzeug==3.0.1
EOF

    # 建立 README.md
    cat > README.md << 'EOF'
# 部門文件分享系統

請參考 INSTALL.md 完成安裝配置。

安裝完成後，執行：
- 啟動: ./start.sh
- 停止: ./stop.sh
- 狀態: ./status.sh
EOF

    print_warning "基本檔案已建立，請手動完成其他檔案的配置"
    print_warning "詳細步驟請參考: https://github.com/your-repo/dept-file-share"
fi

# 步驟 4: 建立 Python 虛擬環境
echo ""
print_info "步驟 4/7: 建立 Python 虛擬環境..."

python3 -m venv venv
source venv/bin/activate

print_success "虛擬環境建立完成"

# 步驟 5: 安裝 Python 套件
echo ""
print_info "步驟 5/7: 安裝 Python 套件..."

if [ -f requirements.txt ]; then
    pip install --upgrade pip -q
    pip install -r requirements.txt
    print_success "Python 套件安裝完成"
else
    print_error "找不到 requirements.txt"
    exit 1
fi

# 步驟 6: 設定執行權限
echo ""
print_info "步驟 6/7: 設定執行權限..."

if [ -f start.sh ]; then
    chmod +x start.sh stop.sh status.sh
    print_success "執行權限設定完成"
fi

# 步驟 7: 設定防火牆
echo ""
print_info "步驟 7/7: 設定防火牆..."

if command_exists ufw; then
    sudo ufw status | grep -q "Status: active" && UFW_ACTIVE=true || UFW_ACTIVE=false
    
    if [ "$UFW_ACTIVE" = true ]; then
        print_info "開放端口 5000..."
        sudo ufw allow 5000/tcp
        print_success "防火牆設定完成"
    else
        print_warning "防火牆未啟用，跳過此步驟"
    fi
else
    print_warning "未安裝 ufw，跳過防火牆設定"
fi

# 獲取 IP 位址
echo ""
print_info "獲取本機 IP 位址..."
IP_ADDR=$(hostname -I | awk '{print $1}')

# 安裝完成
echo ""
echo "=========================================="
echo -e "${GREEN}  🎉 安裝完成！${NC}"
echo "=========================================="
echo ""
echo "專案目錄: $INSTALL_DIR"
echo "本機 IP: $IP_ADDR"
echo ""
echo "下一步："
echo "  1. 進入目錄: cd $INSTALL_DIR"
echo "  2. 檢查檔案: ls -la"
echo ""

if [ -f app.py ]; then
    echo "  3. 啟動系統: ./start.sh"
    echo "  4. 檢查狀態: ./status.sh"
    echo "  5. 訪問網站:"
    echo "     - 本機: http://localhost:5000"
    echo "     - 遠端: http://$IP_ADDR:5000"
else
    echo -e "${YELLOW}注意：主程式 app.py 不存在${NC}"
    echo ""
    echo "請按照以下步驟完成配置："
    echo "  1. 訪問: https://github.com/your-repo/dept-file-share"
    echo "  2. 下載所有必要檔案到: $INSTALL_DIR"
    echo "  3. 或參考 INSTALL.md 手動建立檔案"
fi

echo ""
echo "查看完整文件:"
echo "  - README.md - 快速開始"
echo "  - INSTALL.md - 詳細安裝手冊"
echo ""

# 詢問是否立即啟動
if [ -f start.sh ] && [ -f app.py ]; then
    read -p "是否要立即啟動系統？ (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        print_info "正在啟動系統..."
        ./start.sh
        sleep 3
        ./status.sh
        
        echo ""
        print_success "系統已啟動！"
        echo ""
        echo "訪問: http://localhost:5000"
        echo "或從其他電腦訪問: http://$IP_ADDR:5000"
    fi
fi

echo ""
print_info "感謝使用部門文件分享系統！"
echo ""
