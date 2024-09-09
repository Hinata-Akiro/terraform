resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.hosting_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.hosting_bucket.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled      = true
  comment              = "CloudFront distribution for S3 hosted static website"
  default_root_object  = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.hosting_bucket.id}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }


    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    # If you have a custom certificate in AWS ACM, you can use it here by specifying the ARN:
    # acm_certificate_arn      = "arn:aws:acm:region:account-id:certificate/certificate-id"
    # ssl_support_method        = "sni-only"
  }


  tags = {
    Name = "CloudFront CDN for S3 Bucket"
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Origin Access Identity for S3 bucket hosting website"
}
