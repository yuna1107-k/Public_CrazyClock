# CrazyClock

CrazyClock は Flutter で作られたカスタマイズ可能な時計アプリです。
このアプリは「1日の長さ」を独自に定義でき、時間・分・秒の単位を設定して
アナログ／デジタル表示で確認できます。設定は永続化され、アプリ起動時に復元されます。

**特徴**
- **カスタム日長**: 時間数（hours per day）、分数（minutes per hour）、秒数（seconds per minute）を設定可能（デフォルト: 24:60:60）。
- **アナログ + デジタル表示**: 針は設定に合わせてスナップし、デジタル表示はセンチ秒（2桁）まで表示します。
- **設定の永続化**: shared_preferences を利用してユーザー設定を保存します。
- **設定画面**: `Settings` ページから値を変更できます。

**セットアップ**
必要条件: Flutter SDK がインストールされていること。

依存パッケージ（pubspec.yaml に追加されていることを確認してください）:
- shared_preferences
- intl

基本的なコマンド:

```bash
flutter pub get
flutter run
```

プラットフォーム別実行例:

```bash
# macOS デスクトップ
flutter run -d macos

# Android エミュレータ/端末
flutter run -d android

# iOS シミュレータ/端末（Xcode が必要）
flutter run -d ios
```

**主要ファイル**
- [lib/Clock.dart](lib/Clock.dart)
- [lib/setting.dart](lib/setting.dart)
- [lib/main.dart](lib/main.dart)

**使い方**
- アプリ起動後、下部のナビゲーションで `Clock` と `Settings` を切り替えます。
- `Settings` で `hours per day` / `minutes per hour` / `seconds per minute` を変更すると、時計表示が即時に反映されます。

**変更履歴 / 注意点**
- アプリ表示名はネイティブ側で `CrazyClock` に変更されています（Android/iOS/macOS のマニフェスト／Info.plist／XIB を更新済み）。
- 設定はローカルに保存されるため、値をリセットしたい場合はアプリのデータをクリアしてください。

**貢献**
- バグ報告・機能提案は issue を立ててください。PR は歓迎します。

----
## License

このプロジェクトは **MIT License** の下で公開されています。


---
Designed with by [yuna1107](https://github.com/yuna1107-k)

このREADME.mdはGithub Copilotを使用して作成しています。
