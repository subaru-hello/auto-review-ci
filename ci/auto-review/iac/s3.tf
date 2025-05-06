###############################################################################
# S3 バケット（パイプライン用）
###############################################################################
resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "${var.project_name}-artifacts-${var.region}"
  force_destroy = true
}