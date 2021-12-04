# Stream Downloader

## 概要
1. Streamで配信される動画をダウンロードし, mp4に変換するアプリケーションです
2. m3u8ファイルを指定すると、動画をサーバーからダウンロードしてmp4に変換するアプリケーションです

## 使用技術(※事前インストールが必要)
* Streamlink
* ffmpeg

## 使用言語
* PowerShell
* Python (PowerShellのポーティング版 作成中)

## 事前準備
* ffmpegを使えるようにインストールします(PATHも通す)
* Streamlinkが使えるようにインストールします

## 使用例(AbemaTVの例)
1. PowerShellの実行セキュリティポリシーを変更する必要あり 管理者権限で実行：`Set-ExecutionPolicy Unrestricted`
2. download.ps1を実行
3. AbemaTVのビデオページ(動画が再生できるページ)にアクセス
4. URLをコピーして貼り付ける
5. `extra title` ボタンをクリックし, タイトルを抽出
6. `download(URL)`ボタンをクリックすると, ダウンロードが始まります

## 今後の展望
* クロスプラットフォームに対応できるように, Pythonで書き換える
* ffmpegやStreamlinkなどの依存ソフトウェアをBinaryとして同封したい

