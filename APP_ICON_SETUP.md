# Setting App Icon for Face Mark Attendance

## Using flutter_launcher_icons

### 1. Add dependency to pubspec.yaml

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### 2. Add flutter_icons configuration to pubspec.yaml

```yaml
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/logo.png"
  min_sdk_android: 21
```

### 3. Run the command

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## Manual Setup (Alternative)

### Android
1. Replace `android/app/src/main/res/mipmap-*/ic_launcher.png` with your logo
2. Update `android/app/src/main/AndroidManifest.xml` if needed

### iOS
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → App Icon
3. Drag `assets/images/logo.png` to the icon slots

## App Name Update

### Android
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Face Mark Attendance"
    ...>
```

### iOS
Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleName</key>
<string>Face Mark Attendance</string>
```

Or use Xcode:
- Select Runner → General → Display Name: "Face Mark Attendance"
