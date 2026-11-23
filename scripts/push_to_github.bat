@echo off
chcp 65001 >nul
echo ============================================================
echo   ĐẨY TOÀN BỘ MÃ NGUỒN LÊN GITHUB (MCDZ09/AUTOCLICK-TOOLKIT)
echo ============================================================
echo.
cd /d "%~dp0\.."

echo [*] Đang kiểm tra remote origin...
git remote -v

echo [*] Đang đẩy mã nguồn lên nhánh main...
git push -u origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo ============================================================
    echo [V] ĐÃ ĐẨY CODE LÊN GITHUB THÀNH CÔNG!
    echo.
    echo BÂY GIỜ BẠN CHỈ CẦN:
    echo 1. Quay lại trình duyệt tab GitHub của bạn.
    echo 2. Bấm vào tab "Actions".
    echo 3. Nhìn thấy quy trình "Build & Package iOS IPA" tự động chạy.
    echo 4. Sau 2-3 phút, tải file .IPA thật trong mục "Artifacts".
    echo ============================================================
) else (
    echo.
    echo [!] Đẩy code gặp sự cố. Nếu trình duyệt yêu cầu xác thực, vui lòng bấm Đồng ý.
)

pause
