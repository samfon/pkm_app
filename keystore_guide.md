# Hướng dẫn tạo Release Keystore và GitHub Secrets

Để GitHub Actions có thể build và ký tự động file APK mà không bị xung đột chữ ký với lần phát hành sau, bạn cần tạo **Release Keystore** và cấu hình vào Github Secrets thay vì dùng file debug-keystore mặc định của Flutter.

## Bước 1: Tạo tệp Keystore (.jks) bằng Keytool
Mở terminal/command prompt và chạy lệnh sau (yêu cầu máy có cài sẵn Java JDK):

```bash
keytool -genkey -v -keystore pkm_release_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pkm_alias
```
- Khi được hỏi mật khẩu (Password), hãy nhập và ghi nhớ nó (Ví dụ: `pkm_password_123`).
- Trả lời các thông tin cá nhân (không bắt buộc chính xác).
- Lúc này, bạn sẽ nhận được một file `pkm_release_key.jks`.

## Bước 2: Chuyển đổi Keystore sang Base64
Để GitHub có thể lưu an toàn file `.jks` dưới dạng Text, bạn cần convert nó sang Base64:

```bash
# Windows (Powershell)
[convert]::ToBase64String((Get-Content -Path "pkm_release_key.jks" -Encoding byte)) > keystore_base64.txt
```

## Bước 3: Đưa thông tin lên GitHub Secrets
Vào kho lưu trữ (Repository) của bạn trên GitHub -> **Settings** -> **Secrets and variables** -> **Actions** -> **New repository secret**.

Tạo 4 key sau đây:
1. `KEYSTORE_BASE64`: Paste toàn bộ nội dung trong file `keystore_base64.txt`.
2. `KEY_ALIAS`: Nhập `pkm_alias`
3. `KEY_PASSWORD`: Nhập mật khẩu bạn vừa tạo.
4. `STORE_PASSWORD`: Nhập lại mật khẩu bạn vừa tạo.

Chỉ như vậy workflow `.github/workflows/build.yml` mới có thể chạy thành công và Build ra tệp Signed APK Release OTA.
