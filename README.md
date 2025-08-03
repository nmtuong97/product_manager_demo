# Product Manager Demo

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge)](https://flutter.dev)

> 🇺🇸 [English](README.md) | 🇻🇳 [Tiếng Việt](README.vi.md)

## 🎥 Demos

<img src="gifs/category_demo.gif" width="320" height="621" alt="Category Management">

<img src="gifs/product_add.gif" width="320" height="621" alt="Add Product">

<img src="gifs/product_detail.gif" width="320" height="621" alt="Product Detail">

<img src="gifs/products_filter.gif" width="320" height="621" alt="Products Filter">

<img src="gifs/products_search.gif" width="320" height="621" alt="Products Search">

## 📖 Overview

Flutter app for product management with offline-first architecture, real-time sync, and modern UI/UX, following Clean Architecture.

## ✨ Key Features

- **Category Management**: View, add, edit, delete categories; filter products by category.
- **Product Management**: List (grid/list), details, add/edit/delete; generate sample data.
- **Search**: By keyword, category; real-time results with notifications.
- **Image Upload**: Multi-image support from camera/gallery; preview, generate mock URLs.
- **Utilities**: Pull-to-refresh, view toggle, offline support, user-friendly error handling.
- **Mock API**: GET/POST/PUT/DELETE endpoints for products and categories via interceptor.

## 🛠️ Tech Stack

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | ^9.1.1 | State management |
| get_it | ^8.1.0 | Dependency injection |
| injectable | ^2.3.2 | DI code generation |
| dio | ^5.8.0+1 | HTTP client |
| sqflite | ^2.4.2 | Local SQLite |
| flutter_screenutil | ^5.9.0 | Responsive UI |
| cached_network_image | ^3.4.1 | Image caching |
| flutter_cache_manager | ^3.4.1 | Cache management for cached_network_image |
| image_picker | ^1.0.4 | Image selection |
| http_mock_adapter | ^0.6.1 | Mock API with dio |
| intl | ^0.20.2 | Localization, currency formatting |
| equatable | ^2.0.7 | Value comparison |

## 🏗️ Architecture

```
lib/
├── domain/   # Entities, usecases, repository contracts
├── data/     # Models, repository impl, datasources
├── presentation/ # UI, Blocs, widgets
└── core/     # Services, utilities, interceptors
```

## 💾 Data Storage

- **SQLite**: Tables for Products, Categories.
- **JSON Files**: Mock API data: products.json, categories.json in app directory; sync with SQLite.
- **Images**: Local storage, mock URL generation, caching with flutter_cache_manager.

## 🚀 Getting Started

### Installation

1. Clone: `git clone https://github.com/nmtuong97/product_manager_demo.git && cd product_manager_demo`
2. Dependencies: `flutter pub get`
3. Generate code: `flutter packages pub run build_runner build`
4. Run: `flutter run`

## 📱 Screenshots

| List | Detail | Add/Edit |
|------|--------|----------|
| ![List](screenshots/product_list.png) | ![Detail](screenshots/product_detail.png) | ![Add](screenshots/add_product.png) |

## 📄 License

MIT License - see [LICENSE](LICENSE).

---
📘 [Tiếng Việt](README.vi.md)