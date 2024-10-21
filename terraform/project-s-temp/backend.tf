terraform {
  cloud {
    organization = "animal-squad"

    workspaces {
      project = basename(path.cwd)
      tags    = ["project-s", "temp", "source:cli"]
    }
  }
}
