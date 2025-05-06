
###############################################################################
# CodeBuild プロジェクト
###############################################################################
resource "aws_codebuild_project" "review" {
  name          = var.project_name
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 30

  artifacts { type = "NO_ARTIFACTS" }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:7.0" # Node20入り
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    environment_variable {
      name  = "GITHUB_REPOSITORY_OWNER"
      value = var.github_owner
    }
    environment_variable {
      name  = "GITHUB_REPOSITORY_NAME"
      value = var.github_repo
    }
    # GitHub App シークレットは SSM SecureString 参照例
    environment_variable {
      name       = "GITHUB_APP_ID"
      type       = "PARAMETER_STORE"
      value      = "/codepipeline/github-app-id"
    }
    environment_variable {
      name       = "GITHUB_APP_PRIVATE_KEY"
      type       = "PARAMETER_STORE"
      value      = "/codepipeline/github-app-private-key"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "web-front/shell/codepipeline/buildspec.yml"
  }
}