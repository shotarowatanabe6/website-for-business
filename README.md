# プロフィールサイト

ITエンジニアとしての自己紹介を1ページにまとめた静的サイト。
Hugoで生成し、Cloudflare Pagesで公開する。

サイトの方針と、変更してよい範囲は [CLAUDE.md](./CLAUDE.md) にある。

## 必要なもの

- Hugo 0.152.2（`brew install hugo`）

## ローカルで動かす

```sh
hugo server
```

`http://localhost:1313/` が開く。
ファイルを保存するとブラウザが自動で更新される。

スマートフォンの実機で見るときは、同じWi-Fiにつないだうえで次のように起動する。

```sh
hugo server --bind 0.0.0.0 --baseURL "http://$(ipconfig getifaddr en0):1313/"
```

## 本文を書き換える

トップページの本文は `content/sections/` にある。

| ファイル | セクション |
| --- | --- |
| `10-about.md` | 自己紹介 |
| `20-tech.md` | 技術 |
| `30-hobby.md` | 趣味 |
| `40-links.md` | リンク |

先頭の `---` で囲まれた部分がそのセクションの設定で、`title` が見出し、`weight` が表示順になる。
順番を入れ替えたいときは `weight` の数字を変える（小さいほど上）。
セクションを増やすときは、同じ形式のファイルを足せばよい。
見出しへのページ内リンクは `anchor` の値から作られるので、重複しない英数字を付ける。

## 名前と紹介文を変える

名前、紹介文、ドメインは `hugo.toml` にある。
`title` か `tagline` を変えたときは、OGP画像を作り直す。

```sh
sh tools/make-og.sh
```

## 公開する

`main` にpushするとCloudflare Pagesが自動でビルドしてデプロイする。

```sh
git add -A && git commit -m "本文を更新" && git push
```

### Cloudflare Pagesの初期設定

GitHubにリポジトリを作ってpushしたあと、Cloudflareのダッシュボードで Workers & Pages から Pages のプロジェクトを作り、このリポジトリを選ぶ。
ビルド設定に次の値を入れる。

| 項目 | 値 |
| --- | --- |
| Framework preset | Hugo |
| Build command | `hugo --minify` |
| Build output directory | `public` |
| 環境変数 | `HUGO_VERSION` = `0.152.2` |

`HUGO_VERSION` を省くとCloudflare既定の古いHugoが使われ、ビルドが失敗する。

デプロイが通ると `https://<プロジェクト名>.pages.dev/` で見られるようになる。
このURLを `hugo.toml` の `baseURL` に入れてpushし直すと、canonicalとOGP画像の絶対URLが正しくなる。

### 独自ドメインをつなぐ

1. ドメインを取得する（Cloudflare Registrarで取ると、DNSの設定が最初から済んだ状態になる）
2. Pagesプロジェクトの Custom domains でドメインを追加する
3. 証明書が発行されたら、`hugo.toml` の `baseURL` をそのドメインに変えてpushする

`baseURL` の末尾のスラッシュを省かない。
