#!/bin/bash
# 版本号: v1.0.<git提交总数>
# 用法: bash version.sh  (任意目录下均可执行)

cd "$(dirname "$0")"
echo "v1.0.$(git rev-list --count HEAD)"
