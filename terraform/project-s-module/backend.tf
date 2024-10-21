terraform {
  cloud {
    organization = "animal-squad"

    workspaces {
      project = basename(path.cwd)
      tags    = ["project-s", "production", "source:cli"]
    }
  }
}
