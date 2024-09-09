module "template_files" {
    source = "hashicorp/dir/template"

    base_dir = "${path.module}/bootcamp-1-project-1a-main"
}



resource "aws_s3_bucket" "hosting_bucket" {
    bucket =  "www.${var.bucket_name}"
}

resource "aws_s3_bucket_public_access_block" "hosting_bucket_public_access_block" {
  bucket = aws_s3_bucket.hosting_bucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}




resource "aws_s3_bucket_policy" "hosting_bucket_policy" {
    bucket = aws_s3_bucket.hosting_bucket.id
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::www.${var.bucket_name}/*",
            }
        ]
    })
}



resource "aws_s3_bucket_website_configuration" "hosting_bucket_policy_website_config" {
    bucket = aws_s3_bucket.hosting_bucket.id
   
   index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}



resource "aws_s3_object" "hosting_bucket_files" {
    bucket = aws_s3_bucket.hosting_bucket.id

    for_each = module.template_files.files

    key = each.key
    content_type = each.value.content_type

    source  = each.value.source_path
    content = each.value.content

    etag = each.value.digests.md5
}