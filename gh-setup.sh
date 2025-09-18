# ラベル（最小セット）
gh label create "type:bug"     -R "$ORG/$REPO" -c "#d73a4a" -d "バグ"
gh label create "type:feature" -R "$ORG/$REPO" -c "#a2eeef" -d "機能要望"
gh label create "type:chore"   -R "$ORG/$REPO" -c "#d4c5f9" -d "雑務"

gh label create "priority:P0" -R "$ORG/$REPO" -c "#b60205" -d "至急"
gh label create "priority:P1" -R "$ORG/$REPO" -c "#ffcc00" -d "重要"
gh label create "priority:P2" -R "$ORG/$REPO" -c "#cccccc" -d "低"

gh label create "status:blocked" -R "$ORG/$REPO" -c "#000000" -d "ブロック中"

# テンプレ & CI をコミット（ローカルに一度クローンして流し込み）
git clone "https://github.com/$ORG/$REPO.git"
cd "$REPO"
mkdir -p .github/ISSUE_TEMPLATE .github/workflows

cat > .github/ISSUE_TEMPLATE/bug.yml <<'YAML'
name: "🐞 Bug"
description: バグ報告
title: "[Bug] 簡潔なタイトル"
labels: ["type:bug"]
body:
  - type: textarea
    id: description
    attributes:
      label: 概要
      description: 何が起きているか
      placeholder: 期待と実際の動作
    validations:
      required: true
  - type: textarea
    id: repro
    attributes:
      label: 再現手順
      placeholder: "1) ...\n2) ...\n3) ..."
    validations:
      required: true
  - type: input
    id: env
    attributes:
      label: 環境
      placeholder: "OS / Browser / Version など"
  - type: dropdown
    id: priority
    attributes:
      label: 優先度
      options: ["P0", "P1", "P2"]
    validations:
      required: true
YAML

cat > .github/ISSUE_TEMPLATE/feature.yml <<'YAML'
name: "✨ Feature"
description: 機能要望
title: "[Feat] 簡潔なタイトル"
labels: ["type:feature"]
body:
  - type: textarea
    id: context
    attributes:
      label: 背景・目的
      placeholder: なぜ必要か、誰の課題か
    validations:
      required: true
  - type: textarea
    id: req
    attributes:
      label: 要件
      placeholder: 受け入れ条件（AC）を箇条書きで
    validations:
      required: true
  - type: textarea
    id: approach
    attributes:
      label: アプローチ案
      placeholder: 実装方針があれば
YAML

cat > .github/pull_request_template.md <<'MD'
## 目的
- 該当 Issue: #<番号>
- 自動クローズ: Closes #<番号>

## 変更点
- [ ] 主要な変更1
- [ ] 主要な変更2

## 動作確認
- [ ] ローカルで動作確認
- [ ] 重要処理のテスト追加/更新

## リスク・懸念
MD

# 最小CI（Node例。別言語なら差し替え）
cat > .github/workflows/ci.yml <<'YAML'
name: ci
on:
  pull_request:
    branches: [ "main" ]
  push:
    branches: [ "main" ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
      - run: npm ci
      - run: npm run lint --if-present
      - run: npm test --if-present -- --ci
YAML

git add .
git commit -m "chore: issue/pr templates and minimal CI"
git push origin main