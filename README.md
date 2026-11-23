# AutoClick Toolkit Pro (iOS Non-Jailbreak)

Ứng dụng **AutoClick Toolkit Pro** là bộ công cụ tự động hóa thao tác chuyên nghiệp dành riêng cho hệ điều hành iOS (hỗ trợ từ iOS 16.0 đến iOS 18+). Ứng dụng được viết hoàn toàn bằng **Swift và SwiftUI**, tuân thủ 100% các tiêu chuẩn chính thức của Apple, không yêu cầu Jailbreak và không sử dụng bất kỳ Private API nào.

---

## 1. CÁC TÍNH NĂNG CHÍNH

- **Auto Clicker Studio**:
  - Tần số nhấp tùy chỉnh từ 1 Hz đến 50 Hz (20ms – 1000ms mỗi nhịp).
  - Tích hợp động cơ xung nhịp cao `ContinuousClock` chống sai lệch thời gian (Drift).
  - Chế độ **Anti-Detection (Jitter)** ngẫu nhiên hóa độ trễ để tránh bị phát hiện pattern bot.
  - Vùng đệm thử nghiệm nhấp chuột tương tác trực tiếp (Interactive Test Pad).
- **Macro Studio**:
  - Soạn thảo kịch bản nhiều bước (Multi-action: Tap, Double Tap, Long Press, Swipe, Delay).
  - Dòng thời gian trực quan (Visual Action Timeline), dễ dàng thêm, sửa, xóa bước.
  - Lặp kịch bản theo số vòng mong muốn hoặc lặp vô hạn.
  - Lưu trữ định dạng JSON `Codable` chuẩn hóa, hỗ trợ xuất/nhập qua bộ nhớ tạm.
- **Web Automation Sandbox**:
  - Trình duyệt nhúng bảo mật cao (`WKWebView`).
  - Hỗ trợ tiêm mã JavaScript tự động click theo tọa độ hoặc CSS Selector trên mọi trang web.
  - Tự động cuộn trang (Auto Scroll) và điền form mẫu.
- **Switch Control Recipe Assistant**:
  - Hướng dẫn trực quan từng bước kích hoạt tính năng **Điều khiển công tắc (Switch Control)** của Apple để tự động click trên toàn bộ hệ thống iOS mà không cần Jailbreak.

---

## 2. KIẾN TRÚC MÃ NGUỒN (MODULAR CLEAN ARCHITECTURE)

```
AutoClickToolkit/
├── App/
│   ├── AutoClickToolkitApp.swift         # Entry Point (@main)
│   └── AppEnvironment.swift              # ObservableObject State Management
├── UI/
│   ├── Theme/Theme.swift                 # Bảng màu Dark Modern, Gradient, Shadows
│   ├── Dashboard/DashboardView.swift     # Màn hình tổng quan số liệu & Master Controls
│   ├── AutoClicker/AutoClickerView.swift # Tinh chỉnh nhịp Hz, Jitter, Test Pad
│   ├── MacroStudio/                      # Quản lý kịch bản, StepEditorView
│   ├── WebAutomation/                    # Trình duyệt nhúng JavaScript Auto Click
│   ├── Settings/                         # Chẩn đoán Sandbox, Export/Import JSON
│   └── Components/                       # GlassCard, ActionButton, CoordinateCrosshair
├── Core/
│   ├── AutoClickEngine.swift             # Concurrency Actor điều khiển vòng lặp nhấp
│   └── ActionExecutor.swift              # Bộ điều phối tuần tự các bước Macro
├── Macro/
│   ├── MacroModels.swift                 # MacroStep, MacroScenario, ActionType
│   └── MacroStorageManager.swift         # Lưu tệp JSON và khôi phục kịch bản
├── Gestures/
│   └── InAppGestureDispatcher.swift      # Dispatch synthetic touch nội bộ
├── WebKit/
│   └── WebScriptInjector.swift           # JavaScript DOM click & scroll injection
└── Resources/
    ├── Info.plist                        # Cấu hình Bundle, quyền hạn, background modes
    └── Assets.xcassets/                  # Bộ biểu tượng ứng dụng (AppIcon) chuẩn Apple
```

---

## 3. HƯỚNG DẪN BUILD FILE .IPA HOÀN TOÀN TỰ ĐỘNG

Do việc biên dịch mã nguồn Swift/SwiftUI sang mã nhị phân `arm64 Mach-O` của iOS bắt buộc phải sử dụng bộ SDK chính thức của Apple (chỉ chạy trên macOS), dự án đã được tích hợp sẵn quy trình **CI/CD tự động hóa 100% bằng GitHub Actions**:

### Cách 1: Tự động Build bằng GitHub Actions (Khuyên dùng khi dùng Windows)
1. Đẩy (Push) mã nguồn dự án này lên kho chứa GitHub cá nhân của bạn.
2. Truy cập tab **Actions** trên GitHub repository.
3. Chọn workflow **Build & Package iOS IPA (Non-Jailbreak)** và bấm **Run workflow**.
4. Máy chủ macOS-14 trên cloud sẽ tự động biên dịch, đóng gói file `AutoClickToolkit_v1.0.0.ipa` và đính kèm vào mục **Artifacts** để bạn tải về máy tính chỉ sau 2-3 phút.

### Cách 2: Biên dịch trực tiếp trên macOS (Xcode)
Chạy lệnh sau trong Terminal macOS:
```bash
xcodebuild clean archive \
  -project AutoClickToolkit.xcodeproj \
  -scheme AutoClickToolkit \
  -configuration Release \
  -archivePath build/AutoClickToolkit.xcarchive \
  -destination "generic/platform=iOS" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

mkdir -p build/Payload
cp -r build/AutoClickToolkit.xcarchive/Products/Applications/AutoClickToolkit.app build/Payload/
cd build && zip -r AutoClickToolkit.ipa Payload
```

---

## 4. HƯỚNG DẪN CÀI ĐẶT .IPA TRÊN IPHONE KHÔNG JAILBREAK (WINDOWS HOẶC MAC)

### Cách cài đặt bằng Sideloadly (Miễn phí & Nhanh nhất)
1. Tải và cài đặt phần mềm **Sideloadly** trên máy tính (hỗ trợ cả Windows và macOS).
2. Kết nối iPhone với máy tính bằng cáp sạc và chọn "Tin cậy máy tính này" (Trust This Computer).
3. Kéo thả file `AutoClickToolkit_v1.0.0.ipa` vào giao diện Sideloadly.
4. Nhập Apple ID cá nhân của bạn (dùng để ký chứng chỉ nhà phát triển miễn phí 7 ngày).
5. Bấm **Start** và đợi 1 phút để ứng dụng được cài đặt vào iPhone.
6. Trên iPhone:
   - Vào `Cài đặt -> Cài đặt chung -> Quản lý VPN & Thiết bị`, bấm vào tài khoản Apple ID của bạn và chọn **Tin cậy** (Trust).
   - Với iOS 16 trở lên: Vào `Cài đặt -> Quyền riêng tư & Bảo mật -> Chế độ nhà phát triển (Developer Mode)` và bật **BẬT (ON)**, sau đó khởi động lại máy.
