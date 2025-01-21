resource "google_artifact_registry_repository" "my-repo" {
  location      = "us-central1"
  repository_id = "employee-repository"
  description   = "This repository is created for docker images of employee app and cloudsql auth proxy"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}