---
title: "セクション"
# このセクション自身は単体のページとして出力しない。
build:
  render: never
  list: never
# 配下の各ファイルも単体ページにはせず、トップページに連結するためだけに使う。
cascade:
  build:
    render: never
    list: local
---
