resource "aws_iam_policy" "S3Policy" {
    name = "s3-${var.bucketname}-policy"
    path = "/"
    description = "Policy to allow access to S3 bucket"

    policy = jsonencode({
            Version: "2012-10-17",
            Statement: [
            {
                Sid: "ListObjectsInBucket",
                Effect: "Allow",
                Action: ["s3:ListBucket"],
                Resource: ["arn:aws:s3:::${var.bucketname}"]
            },
            {
                Sid: "AllObjectActions",
                Effect: "Allow",
                Action: "s3:*Object*",
                Resource: ["arn:aws:s3:::${var.bucketname}/*"]
            }
            ]
    })
  
}