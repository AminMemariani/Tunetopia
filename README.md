# Tunetopia 🎵

A modern, cross-platform music player built with Flutter that supports local audio files with a beautiful design.

## Features ✨

- 🎵 **Local Audio Playback**: Play MP3, WAV, OGG, and AAC files
- 🎨 **Material 3 Design**: Modern, accessible UI following latest design standards
- 📱 **Cross-Platform**: Runs on macOS, iOS, Android, Windows, and Linux
- 🖼️ **Album Art Support**: Displays embedded album artwork from audio files
- ⏱️ **Duration Display**: Shows accurate song length and playback progress
- 🎛️ **Playback Controls**: Play, pause, stop, and seek functionality
- 📁 **File Picker**: Easy audio file selection and import
- 🧪 **Comprehensive Testing**: Full test coverage for reliability

## Screenshots 📸

*Screenshots will be added here*

## Prerequisites 📋

Before you start contributing, you'll need to install Flutter and set up your development environment.

### System Requirements

- **macOS**: macOS 10.14 or later
- **Windows**: Windows 10 or later
- **Linux**: Ubuntu 18.04 or later
- **Disk Space**: At least 2.8 GB of free space
- **RAM**: 8 GB or more recommended

## Installation Guide 🚀

### Step 1: Install Flutter

#### macOS
```bash
# Using Homebrew (recommended)
brew install flutter

# Or download manually
# 1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/macos
# 2. Extract to a location (e.g., ~/development/flutter)
# 3. Add to PATH: export PATH="$PATH:~/development/flutter/bin"
```

#### Windows
```bash
# 1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
# 2. Extract to C:\src\flutter
# 3. Add C:\src\flutter\bin to your PATH environment variable
```

#### Linux
```bash
# Using snap (Ubuntu)
sudo snap install flutter --classic

# Or download manually
# 1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/linux
# 2. Extract to ~/development/flutter
# 3. Add to PATH: export PATH="$PATH:~/development/flutter/bin"
```

### Step 2: Install IDE

#### VS Code (Recommended)
1. Download and install [VS Code](https://code.visualstudio.com/)
2. Install the Flutter extension:
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Flutter"
   - Install the official Flutter extension

#### Android Studio
1. Download and install [Android Studio](https://developer.android.com/studio)
2. Install the Flutter plugin:
   - Open Android Studio
   - Go to Preferences/Settings → Plugins
   - Search for "Flutter"
   - Install the Flutter plugin

### Step 3: Install Platform Dependencies

#### For macOS Development
```bash
# Install Xcode from the App Store
# Install CocoaPods
sudo gem install cocoapods

# Install Rust (required for metadata_god package)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

#### For Windows Development
```bash
# Install Visual Studio Build Tools
# Download from: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
```

#### For Linux Development
```bash
# Install required packages
sudo apt-get update
sudo apt-get install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev
```

### Step 4: Verify Installation

```bash
# Check Flutter installation
flutter doctor

# This should show all components as green ✓
# If there are issues, follow the suggested fixes
```

## Getting Started 🏁

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/Tunetopia.git
cd Tunetopia
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App

#### macOS
```bash
flutter run -d macos
```

#### iOS Simulator
```bash
flutter run -d ios
```

#### Android Emulator
```bash
flutter run -d android
```

#### Web
```bash
flutter run -d chrome
```

## Project Structure 📁

```
lib/
├── constants/
│   └── style.dart          # App styling constants
├── models/
│   └── song.dart           # Song data model
├── pages/
│   ├── home.dart           # Main home page
│   ├── song_page.dart      # Individual song player page
│   ├── setting_page.dart   # Settings page
│   └── widgets/
│       ├── appbar.dart     # Custom app bar
│       ├── controls.dart   # Audio playback controls
│       ├── home_item.dart  # Home page items
│       └── my_drawer.dart  # Navigation drawer
├── providers/
│   └── songs.dart          # Song management provider
├── theme/
│   ├── theme.dart          # App theme configuration
│   └── theme_provider.dart # Theme state management
└── main.dart               # App entry point
```

## Development Workflow 🔄

### 1. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes
- Follow the existing code style
- Add tests for new functionality
- Update documentation if needed

### 3. Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
flutter test test/duration_loading_test.dart

# Run with coverage
flutter test --coverage
```

### 4. Check Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Run linter
flutter lint
```

### 5. Commit Your Changes
```bash
git add .
git commit -m "feat: add your feature description"
```

### 6. Push and Create Pull Request
```bash
git push origin feature/your-feature-name
# Create PR on GitHub
```

## Testing 🧪

The project includes comprehensive tests:

- **Unit Tests**: Test individual functions and classes
- **Widget Tests**: Test UI components
- **Integration Tests**: Test complete user flows

Run tests with:
```bash
flutter test
```

## Contributing Guidelines 🤝

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Commit Messages
Use conventional commit format:
```
feat: add new feature
fix: resolve bug
docs: update documentation
test: add or update tests
refactor: code refactoring
style: formatting changes
```

### Pull Request Process
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Update documentation
7. Submit a pull request

## Troubleshooting 🔧

### Common Issues

#### Flutter Doctor Issues
```bash
# If flutter doctor shows issues, run:
flutter doctor --android-licenses
flutter config --enable-web
flutter config --enable-macos-desktop
```

#### Audio Playback Issues
- Ensure audio files are in supported formats (MP3, WAV, OGG, AAC)
- Check file permissions
- Verify audio device is working

#### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### macOS Specific Issues
```bash
# If you get permission errors:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# If Rust is not found:
source "$HOME/.cargo/env"
```

## Dependencies 📦

### Main Dependencies
- `flutter`: Core Flutter framework
- `provider`: State management
- `audioplayers`: Audio playback functionality
- `metadata_god`: Audio file metadata extraction
- `file_picker`: File selection
- `permission_handler`: Platform permissions
- `cached_memory_image`: Image caching

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code linting
- `mockito`: Mocking for tests
- `build_runner`: Code generation

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
