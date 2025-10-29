# アーキテクチャ図

## アプリケーションの構造

```
┌─────────────────────────────────────────────────────────────┐
│                          MyApp                              │
│                    (MaterialApp)                            │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   ChangeNotifierProvider                     │
│              (PracticeRecordsProvider)                       │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      HomeScreen                              │
│               (BottomNavigationBar)                          │
└───────────────┬───────────────────────────┬─────────────────┘
                │                           │
        ┌───────▼────────┐          ┌──────▼──────────┐
        │ PracticeScreen │          │ RecordsScreen   │
        │   (練習タブ)    │          │   (記録タブ)    │
        └───────┬────────┘          └──────┬──────────┘
                │                           │
                ▼                           ▼
    ┌──────────────────────┐    ┌────────────────────┐
    │ AddPracticeScreen    │    │ [記録一覧リスト]    │
    │   (新規作成/編集)     │    └────────┬───────────┘
    └──────────────────────┘             │
                                         ▼
                            ┌────────────────────────┐
                            │ PracticeDetailScreen   │
                            │    (詳細表示)          │
                            └────────────────────────┘
```

## データフロー

```
┌──────────────────┐
│  ユーザー操作     │
└────────┬─────────┘
         │
         ▼
┌─────────────────────────────────┐
│  PracticeRecordsProvider        │
│  - addRecord()                  │
│  - updateRecord()               │
│  - deleteRecord()               │
│  - loadRecords()                │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  DatabaseService                │
│  - insertRecord()               │
│  - updateRecord()               │
│  - deleteRecord()               │
│  - getAllRecords()              │
│  - getUsedGuitarModels()        │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  SQLite Database                │
│  (guitar_up.db)                 │
│  - practice_records テーブル    │
└─────────────────────────────────┘
```

## 主要な機能フロー

### 新規記録作成フロー
```
PracticeScreen
  └─> [新しい練習を記録] タップ
      └─> AddPracticeScreen
          ├─> [動画を撮影/選択]
          │   └─> image_picker パッケージ
          ├─> [各種情報を入力]
          │   ├─> タイトル
          │   ├─> 日時選択
          │   ├─> ギター情報（オートコンプリート）
          │   ├─> 機材メモ
          │   ├─> 所感メモ
          │   └─> 参考URL
          └─> [保存] タップ
              └─> PracticeRecordsProvider.addRecord()
                  └─> DatabaseService.insertRecord()
                      └─> SQLite に保存
                          └─> 記録一覧を再読み込み
                              └─> RecordsScreen に反映
```

### 記録閲覧フロー
```
RecordsScreen (記録一覧)
  └─> [記録カード] タップ
      └─> PracticeDetailScreen
          ├─> 動画プレイヤー表示
          │   └─> video_player パッケージ
          ├─> すべての情報表示
          ├─> [参考URL] タップ
          │   └─> url_launcher で外部ブラウザを開く
          ├─> [編集] タップ
          │   └─> AddPracticeScreen (編集モード)
          └─> [削除] タップ
              └─> 確認ダイアログ
                  └─> PracticeRecordsProvider.deleteRecord()
```

## 状態管理

```
Provider パターン
  └─> PracticeRecordsProvider (ChangeNotifier)
      ├─> _records: List<PracticeRecord>
      ├─> _isLoading: bool
      └─> notifyListeners() で UI を更新

Consumer<PracticeRecordsProvider> で
各画面が状態を購読
```
