# 💰 Sổ Thu Chi (Personal Expense Manager)

Ứng dụng quản lý tài chính cá nhân thông minh, giúp người dùng theo dõi thu chi hàng ngày, quản lý ngân sách và xem báo cáo thống kê trực quan. Ứng dụng được xây dựng bằng **Flutter** và sử dụng **SQLite** để lưu trữ dữ liệu offline.

## 📸 Demo Giao Diện

*( vào đây nếu có)*

| Dashboard | Thêm GiaChèn ảnh chụp màn hình ứng dụng vào thư mục `screenshots` và dẫn linko Dịch | Báo Cáo |
|:---:|:---:|:---:|
| ![Dashboard](https://via.placeholder.com/200x400?text=Dashboard) | ![Add Transaction](https://via.placeholder.com/200x400?text=Add+Form) | ![Report](https://via.placeholder.com/200x400?text=Report) |

## ✨ Tính Năng Chính

* **Quản lý Giao dịch:** Thêm, Sửa, Xóa các khoản Thu/Chi.
* **Danh mục Động:** Người dùng có thể tự tạo danh mục mới với Icon và Màu sắc tùy ý ngay trong lúc nhập liệu.
* **Dashboard Trực quan:** Hiển thị tổng số dư, danh sách giao dịch gần nhất.
* **Báo cáo Thống kê:**
    * Biểu đồ tròn (Pie Chart) phân tích cơ cấu chi tiêu.
* **Lưu trữ Offline:** Dữ liệu được lưu an toàn trong máy người dùng (SQLite), không cần Internet.

## 🛠️ Công Nghệ Sử Dụng

* **Ngôn ngữ:** Dart
* **Framework:** Flutter
* **Database:** SQLite (`sqflite`)
* **Thư viện hỗ trợ:**
    * `intl`: Định dạng tiền tệ và ngày tháng.
    * `fl_chart`: Vẽ biểu đồ báo cáo.
    * `path`: Xử lý đường dẫn hệ thống.

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy (Installation)

Để chạy dự án này trên máy của bạn, hãy làm theo các bước sau:

### 1. Yêu cầu hệ thống (Prerequisites)
* Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install).
* Đã cài đặt VS Code hoặc Android Studio.
* Máy ảo Android (Emulator) hoặc thiết bị thật kết nối qua USB.

### 2. Clone dự án
Mở Terminal (hoặc Git Bash) và chạy lệnh:

```bash
git clone <https://github.com/1-ITer7Nghiep/Flutter_CK_Quanlychitieu>
cd quan_ly_chi_tieu
flutter pub get
flutter run

