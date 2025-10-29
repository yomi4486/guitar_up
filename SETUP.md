# GuiterUp セットアップガイド

## 必要な環境

- Flutter SDK 3.0.0以上
- Dart SDK 3.0.0以上
- Android Studio または Xcode（実機/エミュレータ用）

## インストール手順

### 1. リポジトリのクローン

```bash
git clone https://github.com/yomi4486/guitar_up.git
cd guitar_up
```

### 2. 依存関係のインストール

```bash
flutter pub get
```

### 3. プロジェクトの確認

```bash
# プロジェクトの状態を確認
flutter doctor

# 接続されているデバイスを確認
flutter devices
```

### 4. アプリの実行

#### Android エミュレータで実行
```bash
flutter run
```

#### iOS シミュレータで実行（macOSのみ）
```bash
flutter run -d "iPhone"
```

#### 特定のデバイスで実行
```bash
# デバイスIDを確認
flutter devices

# デバイスIDを指定して実行
flutter run -d [device-id]
```

## テストの実行

### すべてのテストを実行
```bash
flutter test
```

### 特定のテストファイルを実行
```bash
flutter test test/practice_record_test.dart
```

### テストのカバレッジを確認
```bash
flutter test --coverage
```

## ビルド

### Android APKのビルド
```bash
# デバッグビルド
flutter build apk --debug

# リリースビルド
flutter build apk --release
```

### iOS アプリのビルド（macOSのみ）
```bash
# iOS用にビルド
flutter build ios --release
```

### App Bundleのビルド（Google Playストア用）
```bash
flutter build appbundle --release
```

## トラブルシューティング

### 依存関係の問題

```bash
# クリーンビルド
flutter clean
flutter pub get

# パッケージのアップグレード
flutter pub upgrade
```

### Android関連の問題

```bash
# Gradleのクリーン
cd android
./gradlew clean
cd ..

# 再ビルド
flutter build apk
```

### iOS関連の問題（macOS）

```bash
# CocoaPodsのクリーンアップ
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 再ビルド
flutter build ios
```

### キャッシュのクリア

```bash
# Flutterのキャッシュをクリア
flutter clean

# Dart pub のキャッシュをクリア
dart pub cache repair
```

## 開発のヒント

### ホットリロード
アプリ実行中に `r` を押すとホットリロードが実行されます。

### ホットリスタート
アプリ実行中に `R` を押すとホットリスタートが実行されます。

### デバッグモード
VS Codeやandroid Studioのデバッガーを使用してブレークポイントを設定できます。

### Flutterのバージョン管理
```bash
# 現在のFlutterバージョンを確認
flutter --version

# 特定のチャンネルに切り替え
flutter channel stable
flutter upgrade
```

## 推奨される開発環境

### エディタ
- **Visual Studio Code** + Flutter拡張機能
- **Android Studio** + Flutter/Dartプラグイン

### 便利なVS Code拡張機能
- Flutter
- Dart
- Awesome Flutter Snippets
- Pubspec Assist

### Android Studioプラグイン
- Flutter
- Dart

## パフォーマンスの最適化

### プロファイリング
```bash
# プロファイルモードで実行
flutter run --profile

# リリースモードで実行（最高性能）
flutter run --release
```

### ビルドサイズの確認
```bash
# APKのサイズを分析
flutter build apk --analyze-size

# App Bundleのサイズを分析
flutter build appbundle --analyze-size
```

## デプロイ準備

### Android
1. `android/app/build.gradle` でバージョン番号を更新
2. リリースキーの作成（初回のみ）
3. `flutter build appbundle --release`
4. Google Play Consoleにアップロード

### iOS
1. `ios/Runner.xcodeproj` をXcodeで開く
2. バージョン番号を更新
3. 証明書とプロビジョニングプロファイルを設定
4. `flutter build ios --release`
5. App Store Connectにアップロード

## サポート

問題が発生した場合：
1. GitHubのIssuesをチェック
2. Flutter公式ドキュメントを参照: https://flutter.dev/docs
3. Stack Overflowで質問

## リソース

- [Flutter公式サイト](https://flutter.dev)
- [Dart公式サイト](https://dart.dev)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Pub.dev](https://pub.dev) - Dartパッケージリポジトリ
