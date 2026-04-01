# Script tự động hóa khởi tạo Git và Push tới GitHub
# Hướng dẫn:
# 1. Tạo một Repository mới trên GitHub của bạn.
# 2. Thay URL repo của bạn vào biến $REPO_URL dưới đây.
# 3. Mở Terminal (PowerShell) tại thư mục pkm_app và chạy lệnh: .\deploy_automate.ps1

$REPO_URL = "https://github.com/YOUR_USER/your-pkm-repo.git"

Write-Host "--- Bắt đầu khởi tạo Deployment PKM App ---" -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Lỗi: Git chưa được cài đặt trên máy của bạn. Vui lòng cài đặt Git tại git-scm.com"
    exit
}

# 1. Khởi tạo Git
git init

# 2. Add files
git add .

# 3. Commit
git commit -m "🚀 Initial commit - PKM App Full Source A-Z"

# 4. Kiểm tra brand (mặc định là main)
git branch -M main

# 5. Add remote
git remote add origin $REPO_URL

# 6. Push
Write-Host "--- Đang đẩy mã nguồn lên GitHub... ---" -ForegroundColor Yellow
git push -u origin main

Write-Host "--- Deployment Hoàn Tất! ---" -ForegroundColor Green
Write-Host "Bây giờ bạn hãy vào GitHub UI -> Settings -> Secrets để cấu hình Keystore theo hướng dẫn trong keystore_guide.md"
