//TODO: tflint를 제대로 사용할 수 있도록 aws key 제공해야 함
plugin "aws" {
    enabled = true
    version = "0.34.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}