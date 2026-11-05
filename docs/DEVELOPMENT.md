# Windows Development Setup

## Required tools

1. Git for Windows.
2. Flutter stable SDK.
3. Visual Studio 2022 with the **Desktop development with C++** workload.
4. Visual Studio Code.
5. VS Code extensions: Flutter and Dart.

> Visual Studio 2022 is the C++ build toolchain. Visual Studio Code remains the code editor.

## Verify installation

Open PowerShell:

```powershell
git --version
flutter --version
dart --version
flutter doctor -v
```

Flutter Doctor should report a working Windows desktop toolchain.

## Get the project

```powershell
git clone https://github.com/Azthurano1/chinazium-studio.git
cd chinazium-studio/app
flutter pub get
flutter run -d windows
```

If the repository is already cloned, use `git pull` in its directory instead.

## Analyze and format

```powershell
cd app
dart format lib
flutter analyze
flutter test
```

## Build a release

```powershell
cd app
flutter build windows --release
```

The first successful build is the acceptance check for Phase 0.
