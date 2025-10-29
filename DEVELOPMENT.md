# GuiterUp - 開発ドキュメント

## プロジェクト構造

```
guiter_up/
├── lib/
│   ├── main.dart                          # アプリのエントリーポイント
│   ├── models/
│   │   └── practice_record.dart           # 練習記録のデータモデル
│   ├── screens/
│   │   ├── home_screen.dart               # ホーム画面（ボトムナビゲーション）
│   │   ├── practice_screen.dart           # 練習タブ画面
│   │   ├── records_screen.dart            # 記録タブ画面
│   │   ├── add_practice_screen.dart       # 練習記録追加/編集画面
│   │   └── practice_detail_screen.dart    # 練習記録詳細画面
│   └── services/
│       ├── database_service.dart          # SQLiteデータベース管理
│       └── practice_records_provider.dart # 状態管理プロバイダー
├── test/
│   ├── practice_record_test.dart          # モデルの単体テスト
│   └── widget_test.dart                   # ウィジェットテスト
├── android/                               # Android固有の設定
├── ios/                                   # iOS固有の設定
└── pubspec.yaml                           # 依存関係の定義

```

## データモデル

### PracticeRecord

練習記録を表すデータモデル。

#### フィールド
- `id`: String - 一意の識別子（UUID）
- `title`: String? - タイトル（任意）
- `dateTime`: DateTime - 練習日時
- `guitarType`: String? - ギターの種類（任意）
- `guitarModel`: String? - ギターの型番（任意）
- `ampEquipmentMemo`: String? - アンプ・機材のメモ（任意）
- `impressionMemo`: String? - 所感メモ（任意）
- `referenceUrl`: String? - 参考URL（任意）
- `videoPaths`: List<String> - 動画ファイルのパスのリスト

#### メソッド
- `toMap()`: データベース保存用にMapに変換
- `fromMap()`: Mapからインスタンスを生成
- `copyWith()`: フィールドの一部を変更した新しいインスタンスを生成

## サービス

### DatabaseService

SQLiteを使用したローカルデータベース管理。

#### 主なメソッド
- `insertRecord(PracticeRecord)`: 新しい記録を追加
- `getAllRecords()`: すべての記録を取得（日時降順）
- `getRecord(String id)`: IDで記録を取得
- `updateRecord(PracticeRecord)`: 記録を更新
- `deleteRecord(String id)`: 記録を削除
- `getUsedGuitarModels()`: 過去に使用したギター型番のリストを取得（サジェスト用）

### PracticeRecordsProvider

Providerパターンを使用した状態管理。

#### 主なメソッド
- `loadRecords()`: データベースから記録を読み込み
- `addRecord(PracticeRecord)`: 新しい記録を追加
- `updateRecord(PracticeRecord)`: 記録を更新
- `deleteRecord(String id)`: 記録を削除
- `getGuitarModelSuggestions()`: ギター型番のサジェストを取得

## 画面構成

### HomeScreen
- ボトムナビゲーションバーで練習タブと記録タブを切り替え

### PracticeScreen（練習タブ）
- ウェルカムカード
- 「新しい練習を記録」ボタン
- 使い方ガイド（4つのステップ）

### AddPracticeScreen（練習記録追加/編集）
- 動画セクション：撮影/選択ボタン、複数動画対応
- 基本情報：タイトル、日時選択
- ギター情報：種類、型番（オートコンプリート対応）
- 機材・メモ：アンプ機材メモ、所感メモ
- 参考URL：YouTube動画やTAB譜のURL

### RecordsScreen（記録タブ）
- 練習記録の一覧表示（カード形式）
- 各カードに表示：
  - タイトル、日付
  - ギター情報（あれば）
  - 所感メモ（3行まで）
  - 動画数、機材メモ、参考URLの有無をタグ表示

### PracticeDetailScreen（詳細画面）
- すべての記録情報を表示
- 動画プレイヤー（複数動画の切り替え対応）
- 編集・削除機能
- 参考URLのリンク（タップで外部ブラウザで開く）

## 使用技術

### 主要パッケージ
- **provider**: 状態管理
- **sqflite**: ローカルデータベース（SQLite）
- **path_provider**: ファイルパスの取得
- **camera**: カメラアクセス
- **video_player**: 動画再生
- **image_picker**: 動画選択
- **url_launcher**: URL起動
- **youtube_player_flutter**: YouTube動画埋め込み
- **intl**: 日付フォーマット
- **uuid**: 一意のID生成

## パーミッション

### Android
- CAMERA: 動画撮影
- RECORD_AUDIO: 音声録音
- WRITE_EXTERNAL_STORAGE: ファイル保存（Android 9以下）
- READ_EXTERNAL_STORAGE: ファイル読み込み（Android 12以下）
- READ_MEDIA_VIDEO: 動画読み込み（Android 13以上）
- INTERNET: 参考URL表示

### iOS
- NSCameraUsageDescription: カメラアクセス
- NSMicrophoneUsageDescription: マイクアクセス
- NSPhotoLibraryUsageDescription: フォトライブラリ読み込み
- NSPhotoLibraryAddUsageDescription: フォトライブラリ書き込み

## 開発メモ

### データベーススキーマ

```sql
CREATE TABLE practice_records (
  id TEXT PRIMARY KEY,
  title TEXT,
  dateTime TEXT NOT NULL,
  guitarType TEXT,
  guitarModel TEXT,
  ampEquipmentMemo TEXT,
  impressionMemo TEXT,
  referenceUrl TEXT,
  videoPaths TEXT  -- '|||'で区切られた文字列
)
```

### 動画パスの保存形式
複数の動画パスを`|||`で区切った文字列として保存。
例: `/path/to/video1.mp4|||/path/to/video2.mp4`

### ギター型番のサジェスト機能
過去に入力されたギターの種類と型番の組み合わせを
オートコンプリートで表示。重複を排除し、新しいものを優先。

## 今後の拡張案

1. タグ機能の追加
2. 練習時間の記録
3. 目標設定機能
4. グラフによる上達の可視化
5. バックアップ・エクスポート機能
6. クラウド同期（オプション）
