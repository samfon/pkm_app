# Script tự động hóa khởi tạo Git và Push tới GitHub
# Hướng dẫn:
# 1. Tạo một Repository mới trên GitHub của bạn (tên: pkm_app).
# 2. Thay URL repo của bạn vào biến $REPO_URL dưới đây.
# 3. Mở Terminal (PowerShell) tại thư mục pkm_app và chạy lệnh: .\deploy_automate.ps1

$REPO_URL = "https://github.com/samfon/pkm_app.git"

Write-Host "--- Bat dau khoi tao Deployment PKM App ---" -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Loi: Git chua duoc cai dat. Vui long cai dat Git tai git-scm.com"
    exit
}

# 1. Khởi tạo Git (nếu chưa có)
if (-not (Test-Path ".git")) {
    git init
}

# 2. Add files
git add .

# 3. Commit
git commit -m "🚀 Full PKM App with Android + Web CI/CD"

# 4. Kiểm tra branch (mặc định là main)
git branch -M main

# 5. Add remote (nếu chưa có)
$remotes = git remote
if ($remotes -notcontains "origin") {
    git remote add origin $REPO_URL
} else {
    git remote set-url origin $REPO_URL
}

# 6. Push
Write-Host "--- Dang day ma nguon len GitHub... ---" -ForegroundColor Yellow
git push -u origin main

Write-Host ""
Write-Host "--- Deployment Hoan Tat! ---" -ForegroundColor Green
Write-Host ""
Write-Host "BUOC TIEP THEO:" -ForegroundColor Cyan
Write-Host "1. Vao GitHub repo -> Settings -> Secrets and variables -> Actions"
Write-Host "2. Tao 4 secrets theo huong dan trong keystore_guide.md:"
Write-Host "   - KEYSTORE_BASE64"
Write-Host "   - KEY_ALIAS"
Write-Host "   - KEY_PASSWORD"
Write-Host "   - STORE_PASSWORD"
Write-Host ""
Write-Host "3. De build APK: tao tag va push:"
Write-Host "   git tag v1.0.0"
Write-Host "   git push origin v1.0.0"
Write-Host ""
Write-Host "4. Web se tu dong deploy khi push len main branch."
