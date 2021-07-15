resource "aws_iam_group" "IAMGroup" {
  name = var.GroupName
  path = "/users/"
}

resource "aws_iam_group_membership" "Assign" {
  name = "AssingUser"

  users = ["${var.IAMUser}"]

  group = aws_iam_group.IAMGroup.name

}

resource "aws_iam_group_policy_attachment" "s3-policy-attachment" {
  group = var.GroupName
  policy_arn = var.s3-policy-arn
  
}