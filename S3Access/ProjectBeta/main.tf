provider "aws" {
    region = "ap-southeast-2"
}

terraform {
  backend "S3" {
    bucket = "terraformstatefile-projectbeta"            // Bucket where to SAVE Terraform State
    key    = "dev/network-layer/s3Access.tfstate"      // Object name in the bucket to SAVE Terraform State
    region = "ap-southeast-2"                           // Region where bucket created
  }
}

module "create_bucket" {
    source = "../Modules/CreateBucket/"
    bucket_prefix = "${var.s3-bucket-userentry}"  
}

module "bucket_policy" {
    source = "../Modules/IAMPolicy"
    bucketname = "${module.create_bucket.s3_bucket_name}"
}

module "create_user" {
    source = "../Modules/CreateUser/"
    UserName = "${var.user-name}"
}

module "create_group" {
    depends_on = [
      module.create_bucket,
      module.create_user
    ]
    source = "../Modules/CreateGroup/"
    GroupName= "${var.group-name}"
    IAMUser= "${module.create_user.Name}"
    s3-policy-arn="${module.bucket_policy.arn}"
}