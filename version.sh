#!/bin/bash
# 版本号: v1.0.<git提交总数>
# 用法: bash version.sh

echo "v1.0.$(git rev-list --count HEAD)"
