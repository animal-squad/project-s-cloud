terraform {
  cloud {
    organization = "animal-squad"

    //NOTE: 현재는 단일 state 저장을 위해 name 사용. 추후 tag를 사용해 확장성 있게 관리
    workspaces {
      name = "animal-squad-test"
    }
  }
}
