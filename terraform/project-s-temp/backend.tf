terraform {
  cloud {
    organization = "animal-squad"

    workspaces {
      project = "project-s-temp"
      tags    = ["project-s", "temp", "source:cli"]
    }
  }
}
