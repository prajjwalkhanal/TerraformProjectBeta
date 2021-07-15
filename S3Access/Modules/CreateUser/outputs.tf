output "Name" {
    value = aws_iam_user.IAMUser.name
}

output "UserID" {
    value = aws_iam_user.IAMUser.unique_id  
}