# BẢNG THỐNG KÊ – PHÂN CÔNG CÔNG VIỆC

**⚠️ Sinh viên KHÔNG XÓA những dòng hướng dẫn bên dưới khi in ấn.**
Đây là phần quan trọng để GV có cơ sở vấn đáp và đánh giá trên mỗi sinh viên. Sinh viên viết trung thực, đúng những gì mình đã làm, đã đóng góp.

## Hướng dẫn điền thông tin vào Bảng:
- Một số công việc không cần đề cập trong bảng phân công này: Soạn slide, viết báo cáo, đặc tả yêu cầu, thiết kế cơ sở dữ liệu,... (đây là việc chung, mỗi thành viên đều đóng góp xây dựng, nhóm tự phân chia phù hợp và không đưa vào thống kê).
- **Cột Chức năng**: điền tên các chức năng mỗi thành viên thực hiện > là cơ sở để GV vấn đáp. Ví dụ: "Thêm Giao Dịch"; "Xóa Giao Dịch"; "Sửa Giao Dịch"…
- **Cột Loại nhiệm vụ (NV)**: thể hiện các loại nhiệm vụ. Mỗi nhiệm vụ có quy ước tính điểm khác nhau. Cụ thể:
  - **BE**: Lập trình Back-end: tính 1 điểm / 1 chức năng.
  - **FE**: Lập trình Front-end: tính 1 điểm / 1 chức năng.
  - **Full**: Lập trình Fullstack: tính 2 điểm / 1 chức năng.

---

## I. THỐNG KÊ TỔNG THỂ TOÀN DỰ ÁN
**Tổng số chức năng đã thực hiện: 10 chức năng**

| STT | Tên chức năng | Full stack | Front-end | Back-end |
|-----|---------------|-----------|-----------|----------|
| 1 | Thêm Giao Dịch | Thành viên 1 | | |
| 2 | Xóa Giao Dịch | Thành viên 1 | | |
| 3 | Sửa Giao Dịch | Thành viên 1 | | |
| 4 | Hiển Thị Danh Sách Giao Dịch | Thành viên 2 | | |
| 5 | Tìm Kiếm Giao Dịch | Thành viên 2 | | |
| 6 | Thêm Danh Mục | Thành viên 1 | | |
| 7 | Xóa Danh Mục | Thành viên 1 | | |
| 8 | Sửa Danh Mục | Thành viên 1 | | |
| 9 | Hiển Thị Báo Cáo Chi Tiêu (Biểu Đồ Tròn) | Thành viên 2 | | |
| 10 | Hiển Thị Bảng Cân Đối Chi/Thu | Thành viên 2 | | |

---

## II. CHI TIẾT ĐÓNG GÓP TỪNG THÀNH VIÊN

| STT | MSSV | Họ và tên | Chức năng | Loại nhiệm vụ | Điểm | Tổng điểm |
|-----|------|----------|-----------|----------------|------|-----------|
| 1 | [MSSV] | **Thành Viên 1** | Thêm Giao Dịch<br/>Xóa Giao Dịch<br/>Sửa Giao Dịch<br/>Thêm Danh Mục<br/>Xóa Danh Mục<br/>Sửa Danh Mục | Full<br/>Full<br/>Full<br/>Full<br/>Full<br/>Full | 2<br/>2<br/>2<br/>2<br/>2<br/>2 | **12** |
| 2 | [MSSV] | **Thành Viên 2** | Hiển Thị Danh Sách Giao Dịch<br/>Tìm Kiếm Giao Dịch<br/>Hiển Thị Báo Cáo Chi Tiêu<br/>Hiển Thị Bảng Cân Đối Chi/Thu | Full<br/>Full<br/>Full<br/>Full | 2<br/>2<br/>2<br/>2 | **8** |
| | | | | **TỔNG CỘNG** | | **20** |

---

## Ghi chú:
- Dự án sử dụng **Flutter** với SQLite (AppDatabase) để quản lý dữ liệu
- Các chức năng được thiết kế theo mô hình Full-stack (cả UI và Logic xử lý dữ liệu)
- Thành viên 1 tập trung vào quản lý Giao Dịch và Danh Mục (CRUD operations)
- Thành viên 2 tập trung vào hiển thị, báo cáo và thống kê dữ liệu

### Chi tiết các chức năng:

**Thành Viên 1 - Quản lý Giao Dịch & Danh Mục:**
1. **Thêm Giao Dịch** - Tạo form nhập liệu, validate dữ liệu, lưu vào DB
2. **Xóa Giao Dịch** - Xóa giao dịch khỏi cơ sở dữ liệu
3. **Sửa Giao Dịch** - Chỉnh sửa thông tin giao dịch đã lưu
4. **Thêm Danh Mục** - Tạo danh mục chi/thu mới với icon và màu sắc
5. **Xóa Danh Mục** - Xóa danh mục khỏi hệ thống
6. **Sửa Danh Mục** - Chỉnh sửa tên, icon, màu sắc danh mục

**Thành Viên 2 - Hiển thị & Báo cáo:**
1. **Hiển Thị Danh Sách Giao Dịch** - Lấy dữ liệu từ DB, hiển thị list view
2. **Tìm Kiếm Giao Dịch** - Filter giao dịch theo tiêu chí
3. **Hiển Thị Báo Cáo Chi Tiêu** - Vẽ biểu đồ tròn thống kê chi theo danh mục
4. **Hiển Thị Bảng Cân Đối Chi/Thu** - Tính toán và hiển thị tổng chi/thu
