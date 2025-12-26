# 部門文件分享系統

一個輕量級的內部文件管理與分享系統，支援 Excel/Word 線上檢視編輯。

## ✨ 主要功能

### 📁 檔案管理
- 上傳/下載檔案（最大 500MB）
- 建立多層級資料夾
- 支援中文檔名
- Excel (.xlsx) 線上檢視與編輯
- Word (.docx) 線上檢視與編輯
- PDF/圖片直接預覽

### 🔖 網址書籤
- 收藏常用網站
- 資料夾分類管理
- 快速訪問連結

### 🔧 系統功能
- 背景執行
- 自動日誌分檔（按日期）
- 檔案自動備份
- 簡單的管理介面

## 🚀 快速開始

### 方法一：使用安裝腳本（推薦）

```bash
# 1. 確保所有檔案都已建立
# 2. 執行安裝腳本
chmod +x install.sh
./install.sh

# 3. 訪問網站
# 瀏覽器開啟: http://localhost:5000
```

### 方法二：手動安裝

```bash
# 1. 建立虛擬環境
python3 -m venv venv
source venv/bin/activate

# 2. 安裝套件
pip install -r requirements.txt

# 3. 啟動系統
./start.sh

# 4. 訪問網站
# 瀏覽器開啟: http://localhost:5000
```

## 📋 系統需求

- Ubuntu 22.04 LTS（或其他 Linux）
- Python 3.8+
- 4GB RAM（建議 8GB）
- 50GB 硬碟空間

## 📖 完整文件

詳細的安裝和使用說明，請參考：
- **INSTALL.md** - 完整安裝手冊
- **logs/app.log** - 系統日誌

## 🎯 使用方式

### 基本操作

```bash
# 啟動系統
./start.sh

# 停止系統
./stop.sh

# 檢查狀態
./status.sh

# 查看日誌
tail -f logs/app.log
```

### 訪問系統

- **本機訪問**: http://localhost:5000
- **區域網路**: http://你的IP:5000

查詢 IP 位址：
```bash
hostname -I
```

## 📂 目錄結構

```
dept-file-share/
├── app.py                 # 主程式
├── start.sh              # 啟動腳本
├── stop.sh               # 停止腳本
├── status.sh             # 狀態檢查
├── install.sh            # 安裝腳本
├── requirements.txt      # Python 套件
├── README.md            # 本檔案
├── INSTALL.md           # 完整安裝手冊
├── templates/           # 網頁模板
│   ├── home.html
│   ├── files.html
│   ├── bookmarks.html
│   ├── excel_viewer.html
│   └── word_viewer.html
├── uploaded_files/      # 上傳檔案
├── logs/               # 日誌檔案
└── venv/              # Python 虛擬環境
```

## 🔒 安全建議

1. **修改密鑰**：編輯 app.py 中的 `secret_key`
2. **限制訪問**：使用防火牆限制 IP 範圍
3. **定期備份**：設定自動備份腳本
4. **更新系統**：定期更新套件

## ⚠️ 功能限制

### Excel
- 不支援舊格式 .xls（需轉 .xlsx）
- 圖表、公式會遺失
- 複雜格式不保留

### Word
- 不支援舊格式 .doc（需轉 .docx）
- 圖片不顯示
- 複雜格式不保留

### 一般
- 單檔最大 500MB
- 無多人同時編輯
- 刪除無法復原

## 🐛 故障排除

### 無法啟動
```bash
# 查看錯誤
cat logs/console.log

# 檢查端口
netstat -tlnp | grep 5000
```

### 無法訪問
```bash
# 檢查防火牆
sudo ufw allow 5000/tcp

# 檢查系統狀態
./status.sh
```

### Excel/Word 無法開啟
- 確認檔案格式（需要 .xlsx, .docx）
- 移除密碼保護
- 用 Office 重新儲存

更多問題請參考 **INSTALL.md** 的故障排除章節。

## 📊 技術棧

- **後端**: Python Flask
- **前端**: HTML + CSS + JavaScript
- **Excel 解析**: openpyxl, pandas
- **Word 解析**: python-docx

## 📝 版本

**當前版本**: v1.0  
**發布日期**: 2024-12-17

## 📄 授權

內部使用工具，請遵守公司資料安全政策。

## 🙏 致謝

感謝使用本系統！如有問題或建議，請查看 INSTALL.md 或聯繫管理員。
