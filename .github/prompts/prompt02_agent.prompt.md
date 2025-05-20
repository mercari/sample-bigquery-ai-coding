# GMV分析：ワークフロー再現プロンプト
[クエリ](../../queries/query03_base.sql)は、過去3年間のカテゴリ別GMVを集計します。
過去3年間のGMVトレンドを分析するために、以下の手順に従ってください。

---

## 1. Google Cloud認証
```bash
# ブラウザで認証を実行します
gcloud auth login
```

## 2. BigQueryクエリの実行
```bash
# リポジトリルートに移動します
cd $(git rev-parse --show-toplevel)

# CSV出力形式でクエリを実行します
bq query --use_legacy_sql=false --format=csv \
  < queries/query03_base.sql
```
注：モデルがターミナルで全出力を確認する必要があるため、CSVファイルには保存しないでください。

## 3. 分析
すべての結果を確認し、過去3年間のGMVトレンドを分析し、増減の主な理由を箇条書きでリストアップしてください。