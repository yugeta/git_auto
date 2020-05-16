#!/bin/sh

# $ sh auto.sh
# $ sh auto.sh -m check
# $ sh auto.sh -t node

# Function Librarys ----------

# 拡張子を取得
get_extension(){
  filename=$@
  # 拡張子を取得
  ext=${filename##*.}
  # 拡張子を全て小文字に変換
  echo `echo $ext | tr [A-Z] [a-z]`
}

# フォルダがない場合は作成
make_dir(){
  DIR=$@
  if [ ! -e $DIR ]; then
    mkdir -p $DIR
  fi
}

# 判定->処理実行
mode_auto(){
  filepath=${1}
  git=${2}
  date=${3}
  branch=${4}
  # ローカルリポジトリの確認
  if [ -e $filepath ];then

    # ローカルの更新が必要な場合->add,commitする
    # new=""
    res=`git -C $filepath diff --stat`
    if [ "$res" != "" ];then
      mode_commit $filepath $git $date
      # new="1"
    fi

    # ローカルとサーバーの差分確認
    CID_0=`git -C $filepath log --pretty=format:"%H"|head -n 1`
    CID_1=`git -C $filepath ls-remote origin HEAD|awk '{print $1}'`

    # 差分が無い場合は、何もしない
    if [ "$CID_0" = "$CID_1" ]; then
      echo "(auto) This repository is latest. : $filepath"
      # echo "(auto) \e[31m This repository is latest. \e[m : $filepath"
      # printf "%s\033[34m%s\033[m%s\n" '(auto) ' 'This repository is latest.' " : $filepath"
    
    # 差分がある場合
    else
      CHECK_SERV=`git -C $filepath log --pretty=format:"%H"`
      CHECK_DIFF=`git -C $filepath log --pretty=format:"%H" | grep "$CID_1"`
      # ローカルの方が新しい場合は、サーバーにpushする
      
      if [ "$CHECK_DIFF" != "" ] || [ "$CHECK_SERV" = "" ]; then
        # echo "(auto) push -> : $filepath";
        printf "%s\033[31m%s\033[m%s\n" '(auto) ' 'push -> ' " : $filepath"
        mode_push $filepath $git $date $branch

      # ローカルの方が古い場合は、サーバーからpullする
      else
#         CID_S=`git -C $filepath ls-remote origin|awk '{print $1}' | grep "$CID_0"`
# echo "git -C $filepath ls-remote origin|awk '{print \$1}' | grep \"$CID_0\""
# echo "pull? : $CID_S";
#         if [ "$CID_S" != "" ]; then
          # echo "(auto) pull <- : $filepath";
          printf "%s\033[31m%s\033[m%s\n" '(auto) ' 'pull <- ' " : $filepath"
          mode_pull $filepath $git $date $branch
        # else
        #   echo "(auto) Error. Repository is not avalable in pull and push  : $filepath"
        # fi
      fi
    fi

  # ローカルリポジトリが無い場合はcloneする
  else
    # clone
    # echo "(auto) clone <- : $filepath";
    printf "%s\033[34m%s\033[m%s\n" '(auto) ' 'clone <-' " : $filepath"
    res=`git clone $git $filepath`
    echo $res
  fi
}

# 判定->pull,clone処理実行
mode_pull(){
  filepath=${1}
  git=${2}
  date=${3}
  branch=${4}
  if [ -e $filepath ];then
    CID0=`git -C $filepath log --pretty=format:"%H"|head -n 1`
    CID1=`git -C $filepath ls-remote origin HEAD|awk '{print $1}'`

    if [ $CID0 = $CID1 ]; then
      # echo "(pull) Same : $filepath";
      printf "%s\033[36m%s\033[m%s\n" '(pull) ' 'Same' " : $filepath"
    else
      # echo "(pull) Diff : $filepath";
      printf "%s\033[36m%s\033[m%s\n" '(pull) ' 'Diff' " : $filepath"
      res=`git -C $filepath pull origin $branch`
    fi
  else
    # 対象が無い場合はcloneする
    # echo "(pull) Clone : $filepath";
    printf "%s\033[36m%s\033[m%s\n" '(pull) ' 'Clone' " : $filepath"
    `git clone $git $filepath`
  fi
}

# 判定->push処理実行
mode_push(){
  filepath=${1}
  git=${2}
  date=${3}
  branch=${4}
  if [ -e $filepath ];then

    # ローカルの更新が必要な場合->add,commitする
    res=`git -C $filepath diff --stat`
    if [ "$res" != "" ];then
      mode_commit $filepath $git $date
    fi

    CID0=`git -C $filepath log --pretty=format:"%H"|head -n 1`
    CID1=`git -C $filepath ls-remote origin HEAD|awk '{print $1}'`

    # head-idが違う
    if [ $CID0 != $CID1 ]; then
      # ローカル > サーバの場合は、push
      printf "%s\033[31m%s\033[m%s\n" '(push) ' 'Push' " : $filepath"
      # ローカル < サーバーの場合は、pullだけど、何もしない
      res=`git -C $filepath push origin $branch`
      echo "(push) $res"

    # 最新版のため何もしない
    else
      # echo "(push) This repository is latest. $filepath"
      printf "%s\033[36m%s\033[m%s\n" '(push) ' 'This repository is latest.' " : $filepath"
    fi
  else
    # リポジトリがローカルに無い場合はcloneする
    # echo "(push) This repository is none. -> clone"
    printf "%s\033[33m%s\033[m%s\n" '(push) ' 'Clone' " : $filepath"
    `git clone $git $filepath`
  fi
}

# 判定->add,commit処理実行
mode_commit(){
  filepath=${1}
  git=${2}
  date=${3}
  branch=${4}
  if [ -e $filepath ];then
    res=`git -C $filepath diff --stat`
    if [ "$res" != "" ];then
      res_add=`git -C $filepath add .`
      res_commit=`git -C $filepath commit -m "$date"`
      # echo "(commit) comment : $date"
      printf "%s\033[31m%s\033[m%s\n" '(commit) ' 'comment' " : $filepath"
    #  echo $res_commit
    else
      # echo "(commit) This repository is latest."
      printf "%s\033[36m%s\033[m%s\n" '(commit) ' 'This repository is latest.' " : $filepath"
    fi
  else
    # 対象が無い場合はcloneする
    # echo "(commit) This repository is none. -> clone"
    printf "%s\033[36m%s\033[m%s\n" '(commit) ' 'Clone' " : $filepath"
    `git clone $git $filepath`
  fi
}

# 判定->チェック
mode_check(){
  filepath=${1}
  git=${2}
  date=${3}
  branch=${4}
  if [ -e $filepath ];then

    # HEADが更新されている場合 -> add,commitが必要
    res=`git -C $filepath diff --stat`

    if [ "$res" != "" ];then
      # echo "(check) HEAD Go : $filepath"
      printf "%s\033[35m%s\033[m%s\n" '(check) ' 'HEAD go' " : $filepath"

    # サーバーリポジトリとローカルリポジトリを比較
    else
      CID0=`git -C $filepath log --pretty=format:"%H"|head -n 1`
      CID1=`git -C $filepath ls-remote origin HEAD|awk '{print $1}'`

      if [ "$CID0" = "$CID1" ]; then
        # echo "(check) Same : $filepath";
        printf "%s\033[36m%s\033[m%s\n" '(check) ' 'Same' " : $filepath"
      else
        # echo "$CID0 == $CID1"
        # echo "(check) Diff : $filepath";
        printf "%s\033[31m%s\033[m%s\n" '(check) ' 'Diff' " : $filepath"
      fi
    fi
  else
    # echo "(check) None : $filepath";
    printf "%s\033[36m%s\033[m%s\n" '(check) ' 'None' " : $filepath"
  fi
}

# JSON
proc_json_git(){
  mode=${1}
  filename=${2}
  date=${3}
  jq --compact-output -r '.[]' $filename | while read LINE;do
    # echo $LINE

    TYPE=`echo $LINE | jq -r '.type'`
    if [ "$TYPE" != "git" ]; then
      continue
    fi
    
    TARGET=`echo $LINE | jq -r 'if .dir then .dir else "" end'`

    if [ "$TARGET" = "./" ];then
      TARGET=`pwd`
    fi
    DIR=`dirname $TARGET`
    FILE=`basename $TARGET`
    
    FLG=`echo $LINE | jq -r 'if .flg then .flg else "0" end'`
    GIT=`echo $LINE | jq -r '.git'`
    BRANCH=`echo $LINE | jq -r 'if .branch then .name else "master:master" end'`

    make_dir $DIR

    if [ "$FLG" = "1" ];then
      echo "(flg) no-proccess : $DIR/$FILE"
    elif [ "$mode" = "auto" ];then
      mode_auto "$DIR/$FILE" $GIT $date $BRANCH
    elif [ "$mode" = "check" ];then
      mode_check "$DIR/$FILE" $GIT $date $BRANCH
    elif [ "$mode" = "pull" ];then
      mode_pull "$DIR/$FILE" $GIT $date $BRANCH
    elif [ "$mode" = "push" ];then
      mode_push "$DIR/$FILE" $GIT $date $BRANCH
    elif [ "$mode" = "commit" ];then
      mode_commit "$DIR/$FILE" $GIT $date $BRANCH
    fi

  done
}

# CSV
proc_csv_git(){
  mode=${1}
  filename=${2}
  date=${3}
  cat $filename | while read LINE;do
    echo $LINE
    NAME=`echo $LINE | cut -d, -f1`
    GIT=`echo $LINE | cut -d, -f2`
    # if [ "$mode" = "auto" ];then
    #   mode_run "$DIR/$NAME" "$GIT"
    # elif [ "$mode" = "check" ];then
    #   mode_check "$DIR$NAME"
    # fi
  done
}


proc_json_node(){
  mode=${1}
  filename=${2}
  date=${3}
  jq --compact-output -r '.[]' $filename | while read LINE;do

    TYPE=`echo $LINE | jq -r '.type'`
    if [ "$TYPE" != "node" ]; then
      continue
    fi

    NPM=`echo $LINE | jq -r '.npm'`
    if [ "$NPM" = "" ];then
      continue
    fi

    VERSION=`npm view $NPM version`
    if [ "$VERSION" != "" ];then
      printf "%s\033[36m%s\033[m\n" "(node) " "$NPM : version : $VERSION"
    else
      printf "%s\033[31m%s\033[m\n" "(node) " "$NPM : Error ! install."
      RES=`npm install $NPM`
    fi


    # echo $LINE

  done
}




proc_csv_node(){
  mode=${1}
  filename=${2}
  date=${3}

}






# 実行 ----------

# root
ROOT=`dirname $0`
cd $ROOT

date=`date +%s`

# ファイル指定(argv)がある場合
while getopts f:d:m:t: OPT
do
  case $OPT in
    # 格納ディレクトリ [ (d)vendor]
    d ) dir="$OPTARG";;
    # 設定ファイル [ (d)vendor.json , *.json , *.csv]
    f ) filename="$OPTARG";;
    # モード [ (d)auto , check ]
    m ) mode="$OPTARG";;
    # type [ ( git , node ]
    t ) type="$OPTARG";;
  esac
done


# 初期設定
if [ "$mode" = "" ];then
  mode="auto"
  # echo "Error ! not mode. [push , pull , commit]"
  # exit 0
fi
echo "- mode : $mode"
# printf "\033[36m%s\033[m\n" "-mode : $mode"


if [ "$filename" = "" ];then
  filename="auto.json"
fi
echo "- setting-file : $filename"
# printf "\033[36m%s\033[m\n" "- setting-file : $filename"

if [ ! -e $filename ];then
  # echo "Error ! not file $filename."
  printf "\033[31m%s\033[m\n" "Error ! not file $filename."
  exit 0
fi

# 拡張子判定
ext=`get_extension $filename`



# command-check
## check-git
check_git=`git --version`
if [ "$check_git" = "" ];then
  # echo "Error : not install [git]."
  printf "\033[31m%s\033[m\n" "Error ! : not install [git]."
  exit 0
fi
echo "- git-version : $check_git"
# printf "\033[36m%s\033[m\n" "- git-version : $check_git"

## check-jq
if [ "$ext" = "json" ];then
  check_jq=`jq --version`
  if [ "$check_jq" = "" ];then
    # echo "Error : not install [jq]."
    printf "\033[31m%s\033[m\n" "Error ! : not install [jq].."
    exit 0
  fi
  echo "- jq-version : $check_jq"
  # printf "\033[36m%s\033[m\n" "- jq-version : $check_jq"
fi



# [ GIT ] ----------
if [ "$type" = "" ] || [ "$type" = "git" ]; then
  # 拡張子別処理実行
  if [ $ext = "json" ]; then
    # echo "json"
    proc_json_git $mode $filename $date

  elif [ $ext = "csv" ]; then
    # echo "csv"
    proc_csv_git $mode $filename $date
  fi
fi


# [ node-modules ] ----------
if [ "$type" = "" ] || [ "$type" = "node" ]; then

  # check-npm
  NPM_VERSION=`npm -v`
  if [ "$NPM_VERSION" = "" ];then
    printf "\033[31m%s\033[m\n" "Error ! : not install [npm]."
    exit 0
  fi
  echo "- npm-version : $NPM_VERSION"

  # 拡張子別処理実行
  if [ $ext = "json" ]; then
    # echo "json"
    proc_json_node $mode $filename $date

  elif [ $ext = "csv" ]; then
    # echo "csv"
    proc_csv_node $mode $filename $date
  fi


  # echo "node-modules"
fi





