#
resource "aws_ecr_repository" "repositories" {
  for_each             = toset(var.repository_names)
  name                 = each.value
  image_tag_mutability = "IMMUTABLE"
}
#
resource "aws_ecr_repository_policy" "cross_account_policy" {
  for_each = toset(var.repository_names)
  #
  repository = aws_ecr_repository.repositories[each.key].name
  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      for account_id in var.allowed_accounts : {
        Sid    = "AllowCrossAccountPull-${account_id}"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${account_id}:root"
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
      }
    ]
  })
}
#