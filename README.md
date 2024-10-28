# project-s-cloud

### tflint

aws provider를 보다 안전하게 사용할 수 있도록 도와주는 lint

코드 내 aws provider 관련 문제를 확인해주는 기능을 제공한다.

#### 사용 방법

```sh
tflint --init # tflint를 사용하기 위한 초기 설정 진행

# 해당 디렉토리 구성 요소 검사
tflint
# path에 위치한 구성 요소 검사
tflint --chdir=<path>
# 현재 위치에 있는 모든 디렉토리 검사
tflint --recursive
```

#### 관련 문서

- [tflint 레포지토리](https://github.com/terraform-linters/tflint)
- [aws를 위한 tflint 설정 플러그인](https://github.com/terraform-linters/tflint-ruleset-aws/tree/master)
- [aws terraform 사용 가이드](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/introduction.html)
