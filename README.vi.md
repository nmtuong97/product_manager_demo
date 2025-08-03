# Product Manager Demo / Ứng dụng Quản lý Sản phẩm

<!-- Badges -->
[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)](https://flutter.dev)

> 🇺🇸 [English](README.md) | 🇻🇳 Tiếng Việt

## 📖 Tổng quan

Ứng dụng Flutter quản lý sản phẩm với kiến trúc offline-first, real-time synchronization và UI/UX hiện đại. Được phát triển theo nguyên tắc Clean Architecture và industry best practices.

## ✨ Tính năng theo từng màn hình

### 🏠 **Home Page**
- Hiển thị danh sách sản phẩm (chuyển đổi grid/list view)
- Real-time search với category filtering
- Pull-to-refresh functionality
- Generate random sample products
- Navigate đến category management
- Thêm sản phẩm mới qua floating action button

### 📱 **Product Detail Page**
- Full-screen image gallery với zoom và Hero animations
- Hiển thị thông tin sản phẩm đầy đủ
- Chức năng edit và delete sản phẩm
- Category name resolution
- Responsive layout với custom scroll view

### ✏️ **Product Management Page**
- Thêm sản phẩm mới hoặc chỉnh sửa sản phẩm hiện có
- Form validation cho tất cả fields
- Multi-image picker (camera/gallery)
- Category dropdown selection
- Auto-generate sample product data
- Price formatting với thousand separators

### 📂 **Category Management**
- Xem và quản lý product categories
- Category-based product filtering

## 🚀 Các tính năng chi tiết

### 📂 **Danh mục**
- **Danh sách**: Hiển thị tất cả danh mục
- **Pull to refresh**: Làm mới dữ liệu danh mục
- **Thêm mới**: Tạo danh mục sản phẩm mới
- **Chỉnh sửa**: Sửa đổi thông tin danh mục hiện có
- **Xóa**: Xóa danh mục với xác nhận

### 📦 **Sản phẩm**
- **Danh sách**: Hiển thị sản phẩm dạng list hoặc grid
- **Pull to refresh**: Làm mới dữ liệu sản phẩm
- **Cache image**: Tối ưu hóa tải và cache hình ảnh
- **Chi tiết**: Hiển thị thông tin sản phẩm đầy đủ
- **View full screen images**: Xem ảnh sản phẩm toàn màn hình
- **Thêm mới**: Tạo sản phẩm mới với form validation
- **Chỉnh sửa**: Sửa đổi thông tin sản phẩm hiện có
- **Xóa**: Xóa sản phẩm với xác nhận

### 🔍 **Tính năng tìm kiếm**
- **Search by keyword**: Tìm kiếm sản phẩm theo tên hoặc mô tả
- **Search by category**: Lọc sản phẩm theo danh mục
- **Search result**: Hiển thị "Found <total> products for <keyword>" mỗi khi search
- **Real-time search**: Kết quả tìm kiếm tức thì khi gõ

### 🛠️ **Tính năng tiện ích**
- **Tạo mới ngẫu nhiên 10 sản phẩm**: Sinh dữ liệu mẫu hàng loạt
- **Tạo ngẫu nhiên thông tin của 1 sản phẩm**: Sinh thông tin sản phẩm ngẫu nhiên
- **Reset dữ liệu**: Xóa và tạo lại dữ liệu mẫu

### 🌐 **Mock API**

Tạo một client mock giả lập API trực tiếp ở thiết bị và xử lý request/response thông qua interceptor:

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET    | `/products` | Danh sách sản phẩm (lọc: `q`, `categoryId`) |
| GET    | `/products/{id}` | Chi tiết sản phẩm |
| POST   | `/products` | Tạo mới sản phẩm |
| PUT    | `/products/{id}` | Cập nhật sản phẩm |
| DELETE | `/products/{id}` | Xóa sản phẩm |
| POST   | `/products/{id}/images` | Upload ảnh |
| GET    | `/categories` | Danh sách danh mục |

### 📸 **Tính năng upload image**
- **Khi chọn/chụp ảnh**: Hiển thị preview ảnh local ngay lập tức
- **Khi upload sẽ gửi đường dẫn của file lên mock API**:
  - Nếu trong danh sách có đường dẫn local → gen URL ngẫu nhiên → cập nhật vào product
  - Nếu trong danh sách có URL → giữ nguyên các index là URL (sử dụng trong tính năng edit)
- **Multi-image support**: Xử lý nhiều ảnh cho mỗi sản phẩm
- **Camera/Gallery integration**: Chọn từ camera hoặc thư viện ảnh

## 🛠️ Tech Stack & Sử dụng

| Package | Version | Sử dụng trong dự án |
|---------|---------|---------------------|
| **flutter_bloc** | `^9.1.1` | State management cho ProductBloc, CategoryBloc |
| **get_it** | `^8.1.0` | Dependency injection container |
| **injectable** | `^2.3.2` | Code generation cho DI setup |
| **dio** | `^5.8.0+1` | HTTP client cho mock API calls |
| **sqflite** | `^2.4.2` | Local SQLite database storage |
| **flutter_screenutil** | `^5.9.0` | Responsive UI sizing (w, h, sp, r) |
| **cached_network_image** | `^3.4.1` | Image caching và loading |
| **flutter_cache_manager** | `^3.4.1` | Advanced image cache management |
| **image_picker** | `^1.0.4` | Camera/gallery image selection |
| **http_mock_adapter** | `^0.6.1` | Mock REST API responses |
| **shared_preferences** | `^2.5.3` | Simple key-value storage |
| **intl** | `^0.20.2` | Date formatting và localization |
| **equatable** | `^2.0.7` | Value equality cho Bloc states |

## 🏗️ Architecture

Được xây dựng theo nguyên tắc **Clean Architecture**:

```
lib/
├── domain/          # Business logic layer
├── data/            # Data access layer
├── presentation/    # UI layer
└── core/            # Shared utilities
```

- **Domain**: Entities, use cases, repository contracts
- **Data**: Models, repository implementations, data sources
- **Presentation**: UI screens, state management (Bloc), widgets
- **Core**: Services, utilities, mock interceptors

### 💾 **Kiến trúc lưu trữ dữ liệu**

#### Local Database
- **SQLite**: Lưu trữ chính cho chức năng offline-first
- **Tables**: Products, Categories, Images
- **Relationships**: Ràng buộc khóa ngoại giữa các entities

#### Mock API Data Storage
- **File JSON**: Mock API lưu dữ liệu trong file JSON của thư mục app
  - `products.json`: Lưu danh sách sản phẩm
  - `categories.json`: Lưu danh sách category
- **Vị trí file**: Thư mục documents của ứng dụng
- **Persistence**: Dữ liệu được lưu giữ giữa các phiên app
- **Sync Strategy**: Local SQLite ↔ Mock API JSON files

#### Image Storage
- **Local Images**: Lưu trong thư mục documents của app
- **Remote URLs**: Tạo mock URLs cho ảnh đã upload
- **Caching**: Cache ảnh nâng cao với `flutter_cache_manager`
- **Preview**: Preview local ngay lập tức trước khi upload

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Generate code (cho dependency injection)
flutter packages pub run build_runner build

# Run application
flutter run
```

## 📱 Screenshots

| Product List | Product Detail | Add/Edit Product |
|--------------|----------------|------------------|
| ![Product List](screenshots/product_list.png) | ![Product Detail](screenshots/product_detail.png) | ![Add Product](screenshots/add_product.png) |

## 📚 Documentation

- [Image Cache Guide](docs/IMAGE_CACHE_GUIDE.md) - Advanced image caching implementation

## 📄 License

Dự án này được license theo MIT License - xem file [LICENSE](LICENSE) để biết chi tiết.

---

📘 [English](README.md) – Click here to view the English documentation
