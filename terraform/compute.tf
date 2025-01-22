# resource "google_cloud_run_service" "cloudrun-srv" {
#   name     = "cloudrun-srv"
#   location = "us-central1"

#   template {
#     spec {
#       containers {
#         image = "us-docker.pkg.dev/cloudrun/container/hello"
#       }
#     }
#   }

#   traffic {
#     percent         = 100
#     latest_revision = true
#   }
# }

resource "google_cloud_run_v2_service" "default" {
  name     = "pubsub-doctopdf"
  location = "us-central1"

  deletion_protection = false # set to true to prevent destruction of the resource

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello" # Replace with newly created image gcr.io/<project_id>/pubsub
    }
  }
  depends_on = [google_project_service.cloudrun_api]
}