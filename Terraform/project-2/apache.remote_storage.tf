terraform {
  backend "s3" {
    bucket = "terra.1-bucket"
    key    = "project.2/apache"
    region = "eu-west-2"
  }
}