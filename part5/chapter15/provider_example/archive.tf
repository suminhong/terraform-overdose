resource "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_code"     # Lambda 코드가 있는 로컬 디렉터리
  output_path = "${path.module}/lambda_code.zip" # 생성할 ZIP 파일 경로
}

resource "aws_lambda_function" "this" {
  function_name = "test-lambda"
  role          = "test-role"
  handler       = "index.handler" # Lambda 핸들러(index.js의 handler 함수)
  runtime       = "nodejs18.x"

  # 아카이브된 ZIP 파일 경로
  filename = archive_file.this.output_path

  source_code_hash = filebase64sha256(archive_file.this.output_path) # 코드 변경 추적
}
