import os
import shutil
import zipfile

def package_local_bundle():
    dist_dir = "build"
    payload_dir = os.path.join(dist_dir, "Payload")
    app_dir = os.path.join(payload_dir, "AutoClickToolkit.app")

    if os.path.exists(dist_dir):
        shutil.rmtree(dist_dir)

    os.makedirs(app_dir, exist_ok=True)

    # Copy Info.plist
    plist_src = "AutoClickToolkit/Resources/Info.plist"
    if os.path.exists(plist_src):
        shutil.copy(plist_src, os.path.join(app_dir, "Info.plist"))

    # Copy AppIcons
    icon_src_dir = "AutoClickToolkit/Resources/Assets.xcassets/AppIcon.appiconset"
    if os.path.exists(icon_src_dir):
        for f in os.listdir(icon_src_dir):
            if f.endswith(".png"):
                shutil.copy(os.path.join(icon_src_dir, f), os.path.join(app_dir, f))

    # PkgInfo
    with open(os.path.join(app_dir, "PkgInfo"), "wb") as f:
        f.write(b"APPL????")

    # Create dummy executable placeholder for structure verification
    # Note: On macOS, xcodebuild generates the actual arm64 Mach-O binary.
    binary_path = os.path.join(app_dir, "AutoClickToolkit")
    with open(binary_path, "wb") as f:
        # Standard placeholder byte marker
        f.write(b"\xcf\xfa\xed\xfe" + b"\x00" * 1024)

    # Package into .IPA (ZIP format)
    ipa_output_path = os.path.join(dist_dir, "AutoClickToolkit_Package_Structure.ipa")
    with zipfile.ZipFile(ipa_output_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(payload_dir):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, start=dist_dir)
                zipf.write(full_path, rel_path)

    print(f"Packaged IPA structure successfully at: {ipa_output_path}")

if __name__ == "__main__":
    package_local_bundle()
