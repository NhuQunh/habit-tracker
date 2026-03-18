# Habit Tracker

Ứng dụng theo dõi thói quen hiện đại viết bằng Flutter, hỗ trợ đăng nhập Google,
đồng bộ Firebase, luồng dữ liệu offline-first, thông báo cục bộ, thống kê và
giao diện song ngữ (Tiếng Việt/Tiếng Anh).

## Mục lục

- [Tổng quan](#tổng-quan)
- [Tính năng nổi bật](#tính-năng-nổi-bật)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Cấu trúc dự án](#cấu-trúc-dự-án)
- [Ghi chú kiến trúc](#ghi-chú-kiến-trúc)
- [Bắt đầu nhanh](#bắt-đầu-nhanh)
- [Thiết lập Firebase](#thiết-lập-firebase)
- [Chạy và build](#chạy-và-build)
- [Kiểm thử](#kiểm-thử)
- [Roadmap](#roadmap)

## Tổng quan

Habit Tracker giúp người dùng tạo, theo dõi và duy trì thói quen hằng ngày.

Mục tiêu chính:

- Giữ trải nghiệm theo dõi thói quen đơn giản và nhanh.
- Đồng bộ dữ liệu theo từng tài khoản Google bằng Firestore.
- Hoạt động ổn định khi offline với cơ chế fallback local.
- Hỗ trợ đổi ngôn ngữ toàn bộ ứng dụng trong màn hình Settings.

## Tính năng nổi bật

- Đăng nhập Google với Firebase Authentication.
- Lưu dữ liệu theo từng tài khoản trong Firestore theo đường dẫn riêng theo user.
- Hành vi offline-first:
	- Dùng cache local khi mất mạng.
	- Tự đồng bộ cloud <-> local khi có kết nối.
- Quản lý thói quen:
	- Thêm thói quen mới.
	- Đánh dấu hoàn thành.
	- Cập nhật chi tiết (tên, icon, giờ nhắc).
	- Xóa thói quen.
- Thông báo nhắc hằng ngày và báo cáo tổng kết tuần.
- Màn hình thống kê với chỉ số hoàn thành và biểu đồ.
- Chuyển đổi giao diện sáng/tối.
- Đổi ngôn ngữ toàn app (Tiếng Việt/Tiếng Anh).

## Công nghệ sử dụng

- Framework: Flutter (Dart SDK ^3.10.7)
- Quản lý state: Provider
- Backend: Firebase
	- Firebase Auth
	- Cloud Firestore
- Lưu trữ local: SharedPreferences
- Thông báo: flutter_local_notifications
- Biểu đồ: fl_chart

## Cấu trúc dự án

```text
lib/
	controllers/        # State và business logic
	models/             # Data models (Habit, ...)
	screens/            # Các màn hình giao diện
	services/           # Firebase, local storage, notifications, localization
	widgets/            # UI component tái sử dụng
	firebase_options.dart
	main.dart
```

## Ghi chú kiến trúc

- App state được quản lý bằng ChangeNotifier + Provider.
- Trạng thái xác thực quyết định điều hướng:
	- Đã đăng nhập -> vào app shell chính
	- Chưa đăng nhập -> vào màn hình đăng nhập
- Luồng dữ liệu habit:
	- Firestore là nguồn cloud theo từng tài khoản
	- SharedPreferences là cache local và fallback
	- Cơ chế sync giữ UI phản hồi tốt khi mạng không ổn định
- Localization:
	- Ngôn ngữ được lưu trong SharedPreferences
	- Đổi ngôn ngữ từ Settings sẽ cập nhật toàn app

## Bắt đầu nhanh

### Yêu cầu

- Đã cài Flutter SDK
- Android Studio / VS Code có Flutter extension
- Có Firebase project được cấu hình cho app này

### Cài đặt

1. Clone repository.
2. Cài dependencies:

```bash
flutter pub get
```

3. Chạy ứng dụng:

```bash
flutter run
```

## Thiết lập Firebase

Dự án sử dụng Firebase Auth + Firestore.

Checklist:

1. Tạo Firebase project.
2. Bật Google Sign-In trong Authentication.
3. Tạo Firestore Database.
4. Thêm app theo từng nền tảng (Android/iOS/web nếu cần).
5. Đặt file cấu hình Android tại:

```text
android/app/google-services.json
```

6. Đảm bảo file Flutter Firebase options được tạo tại:

```text
lib/firebase_options.dart
```

Đường dẫn dữ liệu Firestore khuyến nghị:

```text
users/{uid}/habits/{habitId}
```

Mẫu Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
	match /databases/{database}/documents {
		match /users/{userId}/habits/{habitId} {
			allow read, write: if request.auth != null && request.auth.uid == userId;
		}
	}
}
```

## Chạy và build

Chạy debug:

```bash
flutter run
```

Build APK:

```bash
flutter build apk
```

Build App Bundle:

```bash
flutter build appbundle
```

## Kiểm thử

Chạy test:

```bash
flutter test
```

## Roadmap

- Bổ sung chiến lược xử lý conflict cloud khi chỉnh sửa đa thiết bị.
- Bổ sung trang hồ sơ tài khoản và cơ chế sign-out an toàn hơn.
- Mở rộng thống kê (xu hướng theo tuần/tháng).
- Thêm widget test cho các luồng quan trọng (auth, thêm habit, sync fallback).

---

Nếu dự án hữu ích với bạn, hãy để lại một star và mở issue khi có đề xuất
hoặc phát hiện lỗi.
