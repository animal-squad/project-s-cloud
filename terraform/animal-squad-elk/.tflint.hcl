//TODO: tflint를 제대로 사용할 수 있도록 aws key 제공해야 함
plugin "aws" {
    enabled    = true
    deep_check = true

    version = "0.34.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"

    //NOTE: Local 사용을 기준으로 작성 됨
    profile                 = "tflint"
    shared_credentials_file = "./aws-tflint-config/credentials"
}

rule "terraform_module_pinned_source" {
    enabled = false
}