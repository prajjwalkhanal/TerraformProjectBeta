output "PolicyName" {
    value = aws_iam_policy.S3Policy.name
}

output "PolicyID" {
    value = aws_iam_policy.S3Policy.id
}

output "arn" {
    value = aws_iam_policy.S3Policy.arn
}