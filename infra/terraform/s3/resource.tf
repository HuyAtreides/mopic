resource "aws_s3_bucket" "mopic_data" {
  bucket = "mopic-data"
}

resource "aws_s3_bucket" "mopic_config" {
  bucket = "mopic-config"
}
