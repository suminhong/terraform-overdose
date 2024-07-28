#!/bin/bash

# 현재 디렉토리부터 하위 디렉토리까지 검색
find . -type f -name "*.tf" | while read -r tf_file; do
  # .tf 파일이 있는 디렉토리로 이동
  tf_dir=$(dirname "$tf_file")
  cd "$tf_dir" || continue

  # terraform-docs 명령 실행
  terraform-docs markdown . --output-file README.md

  # 원래 디렉토리로 돌아가기
  cd - > /dev/null
done
