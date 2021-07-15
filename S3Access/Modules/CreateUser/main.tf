resource "aws_iam_user" "IAMUser" {
    name = var.UserName
    path = "/system/"

    tags = var.tags
}
