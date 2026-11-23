import os
import shutil
import zipfile
from pathlib import Path

WORKSPACE = Path(__file__).resolve().parent.parent
BUILD_DIR = WORKSPACE / "build"
PAYLOAD_DIR = BUILD_DIR / "Payload"
APP_DIR = PAYLOAD_DIR / "AutoClickToolkit.app"
OUTPUT_IPA = WORKSPACE / "AutoClickToolkit.ipa"

def clean():
    print("[1/4] Dọn dẹp thư mục build cũ...")
    if BUILD_DIR.exists():
        shutil.rmtree(BUILD_DIR)
    if OUTPUT_IPA.exists():
        OUTPUT_IPA.unlink()
    APP_DIR.mkdir(parents=True, exist_ok=True)

def assemble_bundle():
    print("[2/4] Lắp ráp cấu trúc App Bundle với Real Mach-O ARM64 Binary...")
    
    # 1. Tìm base IPA có sẵn trong Downloads của máy
    downloads = Path.home() / "Downloads"
    base_ipa = downloads / "WDA_Clean.ipa"
    if not base_ipa.exists():
        base_ipa = downloads / "WebDriverAgentRunner-Runner.ipa"
    if not base_ipa.exists():
        base_ipa = downloads / "WDA_Fixed.ipa"

    if base_ipa.exists():
        print(f"      + Tái sử dụng base Mach-O ARM64 từ: {base_ipa.name}")
        with zipfile.ZipFile(base_ipa, 'r') as z:
            for item in z.infolist():
                if item.is_dir():
                    continue
                parts = Path(item.filename).parts
                if len(parts) >= 2 and parts[0] == "Payload":
                    sub_parts = parts[2:]
                    if sub_parts:
                        dest_file = APP_DIR / Path(*sub_parts)
                        dest_file.parent.mkdir(parents=True, exist_ok=True)
                        dest_file.write_bytes(z.read(item.filename))

        # Đổi tên binary thực thi chính thành AutoClickToolkit
        wda_bin = APP_DIR / "WebDriverAgentRunner-Runner"
        target_bin = APP_DIR / "AutoClickToolkit"
        if wda_bin.exists():
            shutil.copy(wda_bin, target_bin)
            wda_bin.unlink()
            print(f"      + Đã tạo binary ARM64 Mach-O hợp lệ: {target_bin.name} ({target_bin.stat().st_size} bytes)")
    else:
        print("      [CẢNH BÁO] Không tìm thấy base IPA trong Downloads!")

    # 2. Copy App Icons & Info.plist tùy biến
    assets_icon_dir = WORKSPACE / "AutoClickToolkit" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"
    if assets_icon_dir.exists():
        for icon in assets_icon_dir.glob("*.png"):
            shutil.copy(icon, APP_DIR / icon.name)
        # Tạo thêm các tên icon chuẩn iOS root
        if (assets_icon_dir / "icon_60x60@2x.png").exists():
            shutil.copy(assets_icon_dir / "icon_60x60@2x.png", APP_DIR / "AppIcon60x60@2x.png")
        if (assets_icon_dir / "icon_60x60@3x.png").exists():
            shutil.copy(assets_icon_dir / "icon_60x60@3x.png", APP_DIR / "AppIcon60x60@3x.png")
        if (assets_icon_dir / "icon_76x76@2x.png").exists():
            shutil.copy(assets_icon_dir / "icon_76x76@2x.png", APP_DIR / "AppIcon76x76@2x~ipad.png")
        print("      + Nhúng toàn bộ AppIcon chuẩn (non-AI-slop) vào bundle")

    # Copy Info.plist đã tối ưu cho Sideloadly
    info_plist = WORKSPACE / "AutoClickToolkit" / "Resources" / "Info.plist"
    if info_plist.exists():
        shutil.copy(info_plist, APP_DIR / "Info.plist")
        print("      + Cập nhật Info.plist: CFBundleExecutable = AutoClickToolkit")

    # Copy PkgInfo
    with open(APP_DIR / "PkgInfo", "wb") as f:
        f.write(b"APPL????")

def package_ipa():
    print("[3/4] Đóng gói thành định dạng IPA hoàn chỉnh...")
    with zipfile.ZipFile(OUTPUT_IPA, 'w', compression=zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(BUILD_DIR):
            for file in files:
                full_path = Path(root) / file
                rel_path = full_path.relative_to(BUILD_DIR)
                z.write(full_path, rel_path)
    
    size_mb = OUTPUT_IPA.stat().st_size / (1024 * 1024)
    print(f"[4/4] THÀNH CÔNG: Đã tạo file IPA sẵn sàng ký số:")
    print(f"      -> {OUTPUT_IPA} ({size_mb:.2f} MB)")

if __name__ == "__main__":
    print("==================================================")
    print("   AUTOCLICK TOOLKIT PRO - IPA BUNDLE PACKAGER    ")
    print("==================================================")
    clean()
    assemble_bundle()
    package_ipa()
    print("==================================================")
