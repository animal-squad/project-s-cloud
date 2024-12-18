terraform {
  cloud {
    organization = "animal-squad"

    workspaces {
      name = "linket-test"
    }
  }
}
