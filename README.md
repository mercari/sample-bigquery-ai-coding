# BigQueryとVSCode+GitHUb CopilotやCursorでBigQueryのAIコーディングをしよう〜練習問題リポジトリ〜

## はじめに

* このリポジトリは[Mercari Analytics Blogの記事](https://note.com/mercari_data/n/nfca7f28f1094)内の練習問題を格納したものです。
* データアナリストの方、特にVS CodeとGitHub Copilot、あるいはCursorのようなエディタ+AIコーディングアシスタントを使い始めたばかり/使用を検討している方を対象としています。  
* BigQueryのオープンデータセット `thelook_ecommerce` を活用した実践的なSQLクエリのサンプルを通じて、データ分析のスキルアップとAIを活用した開発フローを体験することを目的としています。

## このリポジトリでできること
*   **VS Code/CursorでのAIコーディングアシスタントの活用体験**: 
    *   VS Code/CursorでGitHub Copilotや他のAIアシスタントと対話しながら、SQLの理解を深めたり、クエリを改善したりする体験ができます。

## ファイル構成

```
.
├── queries/                  # BigQuery練習用のSQLファイル群
│   ├── query01_explain.sql
│   ├── query02_auto_completion.sql
│   ├── query03_base.sql
│   ├── query04_user_segment.sql
│   └── image_check.png
├── .github/
│   └── prompts/              # GitHub Copilot等、汎用的なAIアシスタント用のプロンプトサンプル集
│       ├── prompt01_change_category.prompt.md
│       └── prompt02_agent.prompt.md
├── .cursor/                  # Cursorエディタ特有の設定ファイル等
│   └── rules/                # Cursorエディタ向けプロンプト/指示の保管場所 (内容は.github/promptsと同様のものを想定)
└── README.md                 # このファイル
```

*   **`queries/`**: このディレクトリには、BigQueryで実行できるSQLクエリのサンプルファイル (`.sql`) が含まれています。
    *   主に `bigquery-public-data.thelook_ecommerce` という一般公開データセットを使用しています。
    *   **`query01_explain.sql`**: 人力で一目で理解するのが難しい、複雑な分析クエリ（RFM分析、コホート分析など）の例です。Ask ModeでAIに解説させる用です。
    *   **`query02_auto_completion.sql`**: AIコーディングアシスタントのコード補完機能を体験するために、意図的に不完全な状態にしてあるクエリです。ファイルを開き、`GROUP BY`句の後にカーソルを置くなどして、補完機能を試してみてください。(このファイルは構文エラーがLinterで表示されることが想定されています)
    *   **`query03_base.sql`**: AIアシスタントに指示を出して変更・拡張していくことを想定したベースとなるクエリです。
    *   **`query04_user_segment.sql`**: `query03_base.sql` と同じデータセットを使用しつつ、異なる切り口（例：ユーザーセグメント別）で集計するクエリです。`query03_base.sql` での分析結果と組み合わせて使用することを想定しています。
    *   **`image_check.png`**: `query03_base.sql` と組み合わせて、AIアシスタントに画像の内容を確認させるためのサンプル画像です。
*   **`.github/prompts/`**: このディレクトリには、GitHub Copilot Chatで利用できるプロンプトのサンプル (`.prompt.md`) が含まれています。
    *   これらのプロンプトは、特定の分析タスクをAIに指示したり、コードの説明を求めたりする際の参考にしてください。
    *   **`prompt01_change_category.prompt.md`**: `queries/query03_base.sql` をベースに、分析対象のカテゴリや期間を変更するようAIアシスタントに指示する際のプロンプト例です。Edit Mode(GitHub Copilot)/Manual Mode(Cursor)で使用します。
    *   **`prompt02_agent.prompt.md`**: GMV分析のワークフロー（認証、クエリ実行、結果分析）をAIアシスタントに再現させるためのプロンプト例です。Agent Modeを体験するためのプロンプトです。
*   **`.cursor/rules/`**:  `.github/prompts/` と同内容で、Cursorでも動作するものを用意しています。


## 使い方・学習の進め方
* ローカルにこのリポジトリをクローンし、VS Code/Cursorで開いてください。  
* 詳細は[ブログ記事](https://note.com/mercari_data/n/nfca7f28f1094)をご参照ください。  

## 注意事項
*   このリポジトリは、あくまで学習用のサンプルです。実際の業務で使用する際は、データの正確性やセキュリティに十分注意してください。
*   SQLクエリの実行には、Google Cloud PlatformのBigQueryサービスを使用します。Google Cloud Platformのアカウントが必要です。
*   PRについては、内容の明確な誤りや、GitHub Copilot/Cursorのアップデートに伴う内容の不整合についてのみ受け付けます。
    *   事前に[CLA](https://www.mercari.com/cla/)にご同意ください。
  
## ライセンス
Copyright 2025 Mercari, Inc.  
このリポジトリは[MITライセンス](LICENSE)に準拠しています。

データ出典：[Google BigQuery Public Datasets - thelook_ecommerce](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce?hl=ja&inv=1&invt=AbxhBA&project=mercari-bq-analytics-jp-prod)

--- 

このリポジトリが、あなたやあなたの会社でのBigQueryでのAI活用の第一歩となれば幸いです。
