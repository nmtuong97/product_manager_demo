# Product Manager Demo / Ứng dụng Quản lý Sản phẩm

<!-- Badges -->
[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)](https://flutter.dev)

> 🇺🇸 English | 🇻🇳 [Tiếng Việt](README.vi.md)

## 📖 Overview

A Flutter mobile application for product management with offline-first architecture, real-time synchronization, and modern UI/UX. Built with Clean Architecture principles and industry best practices.

## ✨ Features by Screen

### 🏠 **Home Page**
- Product list display (grid/list view toggle)
- Real-time search with category filtering
- Pull-to-refresh functionality
- Generate random sample products
- Navigate to category management
- Add new product via floating action button

### 📱 **Product Detail Page**
- Full-screen image gallery with zoom and Hero animations
- Complete product information display
- Edit and delete product actions
- Category name resolution
- Responsive layout with custom scroll view

### ✏️ **Product Management Page**
- Add new products or edit existing ones
- Form validation for all fields
- Multi-image picker (camera/gallery)
- Category dropdown selection
- Auto-generate sample product data
- Price formatting with thousand separators

### 📂 **Category Management**
- View and manage product categories
- Category-based product filtering

## 🚀 Detailed Features

### 📂 **Categories**
- **List View**: Display all categories
- **Pull to Refresh**: Refresh category data
- **Add New**: Create new product categories
- **Edit**: Modify existing category information
- **Delete**: Remove categories with confirmation

### 📦 **Products**
- **List View**: Display products in list or grid format
- **Pull to Refresh**: Refresh product data
- **Image Caching**: Optimized image loading and caching
- **Detail View**: Complete product information display
- **Full-screen Images**: View product images in full-screen mode
- **Add New**: Create new products with form validation
- **Edit**: Modify existing product information
- **Delete**: Remove products with confirmation

### 🔍 **Search Features**
- **Keyword Search**: Search products by name or description
- **Category Filter**: Filter products by category
- **Search Results**: Display "Found <total> products for <keyword>" message
- **Real-time Search**: Instant search results as you type

### 🛠️ **Utility Features**
- **Bulk Product Generation**: Create 10 random sample products
- **Random Product Data**: Generate random product information
- **Data Reset**: Clear and regenerate sample data

### 🌐 **Mock API**

Built-in REST API simulation with interceptor-based request/response handling:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/products` | Get product list (filters: `q`, `categoryId`) |
| GET    | `/products/{id}` | Get product details |
| POST   | `/products` | Create new product |
| PUT    | `/products/{id}` | Update product |
| DELETE | `/products/{id}` | Delete product |
| POST   | `/products/{id}/images` | Upload product images |
| GET    | `/categories` | Get category list |

### 📸 **Image Upload Features**
- **Local Preview**: Display selected/captured images immediately
- **Smart Upload**: 
  - Local file paths → Generate random URLs → Update product
  - Existing URLs → Preserve during edit operations
- **Multi-image Support**: Handle multiple images per product
- **Camera/Gallery Integration**: Choose from camera or photo library

## 🛠️ Tech Stack & Usage

| Package | Version | Usage in Project |
|---------|---------|------------------|
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

Built with **Clean Architecture** principles:

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

### 💾 **Data Storage Architecture**

#### Local Database
- **SQLite**: Primary local storage for offline-first functionality
- **Tables**: Products, Categories, Images
- **Relationships**: Foreign key constraints between entities

#### Mock API Data Storage
- **JSON Files**: Mock API stores data in app directory JSON files
  - `products.json`: Product list and details
  - `categories.json`: Category list and metadata
- **File Location**: Application documents directory
- **Persistence**: Data persists between app sessions
- **Sync Strategy**: Local SQLite ↔ Mock API JSON files

#### Image Storage
- **Local Images**: Stored in app's documents directory
- **Remote URLs**: Generated mock URLs for uploaded images
- **Caching**: Advanced image caching with `flutter_cache_manager`
- **Preview**: Immediate local preview before upload

### 🚀 Getting Started

#### Prerequisites

- **Flutter SDK** `3.7.2` or higher
- **Dart SDK** `3.0` or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)

#### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/product_manager_demo.git
   cd product_manager_demo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (for dependency injection)
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   # Debug mode
   flutter run
   ```

### 📱 Screenshots

| Product List | Product Detail | Add/Edit Product |
|--------------|----------------|------------------|
| ![Product List](screenshots/product_list.png) | ![Product Detail](screenshots/product_detail.png) | ![Add Product](screenshots/add_product.png) |

### 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

📘 [Tiếng Việt](README.vi.md) – Click here to view the Vietnamese documentation