# one bucket for storing raw and processed data
# one bucket for storing scripts - ETL/glue code
# another one for storing lambda artifacts(zip files)

resource "aws_s3_bucket" "spotify_datalake" {
    bucket = "spotify-datalake-${var.account_id}"
    force_destroy = true # Allow deletion of non-empty buckets

    tags = {
        Name = "spotify-datalake"
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "spotify_datalake_lifecycle" {
    bucket = aws_s3_bucket.spotify_datalake.id

    rule {
        id     = "Expire old raw data"
        status = "Enabled"

        expiration {
            days = 90
        }

        filter {
            prefix = "${var.pipeline_name}/raw/"
        }
    }

    rule {
        id     = "Expire old processed data"
        status = "Enabled"

        expiration {
            days = 90
        }

        filter {
            prefix = "${var.pipeline_name}/processed/"
        }
    }
}

# use bucket ownership to avoid ACL issues when accessing the bucket from different accounts
# best practice: ownership controls first then ACL depending on your use case
resource "aws_s3_bucket_ownership_controls" "spotify_datalake" {
    bucket = aws_s3_bucket.spotify_datalake.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket" "spotify_scripts" {
    bucket = "spotify-scripts-${var.account_id}"
    force_destroy = true # Allow deletion of non-empty buckets

    tags = {
        Name = "spotify-scripts"
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_ownership_controls" "spotify_scripts" {
    bucket = aws_s3_bucket.spotify_scripts.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "spotify_scripts" {
    bucket = aws_s3_bucket.spotify_scripts.id
    acl    = "private"

    depends_on = [ 
        aws_s3_bucket_ownership_controls.spotify_scripts
     ]
}

resource "aws_s3_bucket" "spotify_lambda_artifacts" {
  bucket = "spotify-lambda-artifacts-${var.account_id}"
  force_destroy = true # Allow deletion of non-empty buckets

  tags = {
      Name = "spotify-lambda-artifacts"
      Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "spotify_lambda_artifacts" {
  bucket = aws_s3_bucket.spotify_lambda_artifacts.id

  rule {
      object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "spotify_lambda_artifacts" {
  bucket = aws_s3_bucket.spotify_lambda_artifacts.id
  acl    = "private"

  depends_on = [ 
      aws_s3_bucket_ownership_controls.spotify_lambda_artifacts
   ]
}