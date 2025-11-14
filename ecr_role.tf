#
data "aws_iam_policy_document" "trusted_policy" {
  version = "2012-10-17"
  #
  statement {
    sid    = ""
    effect = "Allow"
    #
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:oidc-provider/token.actions.githubusercontent.com"]
    }
    #
    actions = ["sts:AssumeRoleWithWebIdentity"]
    #
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    #
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      #
      values = [
        "repo:${var.github_organization}/*"
      ]
    }
  }
}
#
resource "aws_iam_role" "admin" {
  name                 = "github-runner-role-ecr"
  assume_role_policy   = data.aws_iam_policy_document.trusted_policy.json
  max_session_duration = var.max_session_duration
  tags                 = local.tags
}
#
data "aws_iam_policy_document" "inline_policy" {
  statement {
    sid    = "ecr"
    effect = "Allow"
    actions = [
      "ecr:*",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "secretsmanager"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "iam"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = ["*"]
  }
}
#
resource "aws_iam_role_policy" "admin" {
  name   = "${var.project}-development-${var.role}-IAMP-ECS"
  role   = aws_iam_role.admin.id
  policy = data.aws_iam_policy_document.inline_policy.json
}
#