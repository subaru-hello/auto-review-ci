
###############################################################################
# IAM – CodeBuild ロール & ポリシー
###############################################################################
data "aws_iam_policy_document" "codebuild_assume" {
  statement { actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["codebuild.amazonaws.com"] }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

data "aws_iam_policy_document" "codebuild_inline" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:*", "ssm:GetParameter",             # SSM から GitHub App シークレット取得
      "bedrock:InvokeModel"                     # Claude 呼び出し
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_inline" {
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild_inline.json
}

###############################################################################
# IAM – CodePipeline ロール (CodeBuild起動権限)
###############################################################################
data "aws_iam_policy_document" "pipeline_assume" {
  statement { actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["codepipeline.amazonaws.com"] }
  }
}

resource "aws_iam_role" "pipeline" {
  name               = "${var.project_name}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_assume.json
}

data "aws_iam_policy_document" "pipeline_inline" {
  statement {
    actions   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = ["${aws_codebuild_project.review.arn}"]
  }
  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = [var.codestar_connection]
  }
  statement { actions = ["iam:PassRole"] resources = ["${aws_iam_role.codebuild.arn}"] }
}

resource "aws_iam_role_policy" "pipeline_inline" {
  role   = aws_iam_role.pipeline.id
  policy = data.aws_iam_policy_document.pipeline_inline.json
}