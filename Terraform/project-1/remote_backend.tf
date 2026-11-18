terraform {
  backend "s3" {
    bucket = "terra.1-bucket"
    key    = "projects/terra.1"
    region = "eu-west-2"
  }
}

