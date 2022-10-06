#!/usr/bin/env bash

# This script is to convert 顾衡好书榜 to different ebook formats.

function substitute () {
    file=$1
    
    echo " - replace special characters ... "

    sed -e '8,$s/——/---/g' \
        $file.md > $file_tmp.md

    # That *_tmp.md is empty means replacing special characters is NOT right.
    if [ -s $file_tmp.md ]; then
        mv $file_tmp.md  $file.md
    else
        echo "NOT succeed in replacing $file.md"
        exit
    fi
}

function m2e () {
    echo " - transform to epub ..."

    pandoc --toc --toc-depth=1 \
           --epub-cover-image=./fig/cover.png \
           $file.md -f markdown -o $file.epub
}

function m2p () {
    echo " - transform to pdf ..."

    pandoc --pdf-engine=xelatex \
           --toc -N \
           -V colorlinks -V urlcolor=NavyBlue \
           --highlight-style zenburn \
           $file.md -o $file.pdf
}

# ------------------------------------------------------------
# main function

if [[ $1 == "" ]]; then
    titles=(PGE)
else
    titles=($1)
fi


for title in ${titles[@]}; do
    content=()
    case $title in
        PGE)
            content=(${content[@]} PGE)
           ;;
    esac

    echo
    echo "*** To convert $title to different ebook formats *** "
    echo

    cp ./title/$title.md .

    for chapter in ${content[@]}; do
        cat md/$chapter.md >> $title.md
    done

    substitute $title
    m2e $title && mv $title.epub epub/.
    m2p $title && mv $title.pdf  pdf/.

    rm $title.md

done
