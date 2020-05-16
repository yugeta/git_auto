Git auto
==
```
Author : Yugeta.Koji
Date   : 2020.05.15
```

# Summary
- ライブラリを含めた複数のgit操作を簡単に行えるようにするシステム。

# Function
- 設定ファイル(setting.json,setting.csv)に記載されたデータを元に、各種ライブラリ管理を行う。
- 自動インストール
- 自動commit (master,etc)
- 自動push (master,etc)
- 自動チェックアウト (own管理リポジトリ判断が必要)

# Request
- CONFLICT対応
  pullした時の"CONFLICT"メッセージを取得してalertできる機能がほしい

# Mode
- auto   : 設定にあって、DLされていないものはpull,サーバーの方に最新版があればpull,ローカルで更新がある場合は、pushを自動判別して行う
  * pushしない（できない）ものはsettingに記載する
- check  : ライブラリの状態を確認する

- commit : 内部のプロジェクトを全てcommitする (commit文言は、"yyyymmddhhiiss")
- push   : 既存の状態をadd,commitして、pushする (commitされていない場合は、自動commitされる)
- pull   : リポジトリからライブラリをダウンロード(pull)する


# Sample
- 確認
  $ sh auto.sh -m check -f data/auto.csv

- $ sh auto.sh -m auto -f data/auto.csv -d plugin/
- $ sh auto.sh -m auto -f data/auto.csv -d .

# Setting-file
- json
[
  {
    "name" : "+++++",  // * Program(library) Name
    "dir"  : "plugin/input_cache/",  // * ライブラリ格納場所:target-library-path
    "git"  : "https://github.com/yugeta/input_cache.git",  // * git-repository-path
    "pullonly" : true,  // clone,pullのみ実行(pushしない) *oss利用などの場合
    "branch" : "master:master", // * branchを指定 *無い場合は自動で"master:master"になる。
    "flg"  : 1 // このライブラリを自動で使用しない場合にflg=1とする、この設定が無い場合は自動的にflg=0
  },
  ...
]

- csv


# Caution
- git-repository
  githubなどのサービス利用する際は、認証ができている状態にしてください。

- git-branch
  操作するgitはすべてmasterブランチとする。

- git-commit
  commitの際のメッセージを書き込みたい場合は、個別に処理してください。
  HEADが移動していると、自動でcommitしてしまいます。

# initial-git
- add-remote
$ git remote -v
$ git remote add origin %repo-url%

- change-remote
$ git remote -v
$ git remote rm origin
$ git remote add origin %repo-url%

