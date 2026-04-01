# PKM App - Personal Knowledge Management

Ứng dụng quản lý tri thức cá nhân đa nền tảng (Android & Web) được xây dựng bằng Flutter.

## 🚀 Tính năng chính

- **Offline-First**: Hoạt động mượt mà khi không có mạng với cơ sở dữ liệu Hive.
- **Cấu trúc Thư mục 3 tầng**: Tổ chức kiến thức chuyên nghiệp, trực quan.
- **Đồng bộ Google Drive**: Sao lưu và khôi phục dữ liệu an toàn trên đám mây cá nhân.
- **AI Command Center (Gemini)**: Tích hợp trí tuệ nhân tạo Gemini để phân tích, tóm tắt và hỏi đáp dựa trên kho kiến thức của bạn.
- **OTA Updates (Android)**: Tự động kiểm tra và cập nhật ứng dụng thông qua GitHub Releases.
- **CI/CD**: Tự động build và phát hành APK thông qua GitHub Actions.

## 🛠 Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Database**: Hive (NoSQL)
- **Cloud**: Google Drive API v3
- **AI**: Google Gemini API
- **CI/CD**: GitHub Actions

## 📦 Cấu hình & Deploy

### 1. Cấu hình Google Drive
- Tạo project trên [Google Cloud Console](https://console.cloud.google.com/).
- Bật **Drive API**.
- Tạo **OAuth 2.0 Client ID** cho Android và Web.

### 2. Cấu hình Gemini AI
- Lấy API Key tại [Google AI Studio](https://aistudio.google.com/).
- Nhập Key vào mục **Settings** trong ứng dụng.

### 3. CI/CD & OTA (GitHub)
- Làm theo hướng dẫn trong `keystore_guide.md` để tạo Keystore.
- Thêm các Secrets vào GitHub Repository:
    - `KEYSTORE_BASE64`
    - `KEY_ALIAS`
    - `KEY_PASSWORD`
    - `STORE_PASSWORD`

## 👨‍💻 Tác giả
Phát triển bởi Antigravity.
