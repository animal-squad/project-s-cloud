terraform {
  cloud {
    organization = "animal-squad"

    workspaces {
      project = "animal-squad-test"
      tags    = ["animal-squad", "test", "source:cli"]
    }
  }
}
