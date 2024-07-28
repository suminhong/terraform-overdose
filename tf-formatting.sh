#!/bin/bash

echo '🚀 모든 하위 경로의 Terraform Document를 생성합니다 ...'
# 현재 디렉토리부터 하위 디렉토리까지 검색
find . -type f -name "*.tf" | while read -r tf_file; do
  # .tf 파일이 있는 디렉토리로 이동
  tf_dir=$(dirname "$tf_file")
  cd "$tf_dir" || continue

  # terraform-docs 명령 실행
  echo "terraform-docs in $(pwd)";
  terraform-docs markdown . --output-file README.md

  # 원래 디렉토리로 돌아가기
  cd - > /dev/null
done
echo '✅ Terraform Document 생성 완료'


echo '🚀 모든 하위 경로의 Terraform File들을 포맷팅합니다 ...'
terraform fmt -recursive
echo '✅ Terraform File 포맷팅 완료'
