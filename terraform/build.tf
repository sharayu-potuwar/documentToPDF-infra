# // Create a secret containing the personal access token and grant permissions to the Service Agent
# resource "google_secret_manager_secret" "github_token_secret" {
#     project =  "gcp-devops-436118"
#     secret_id = "github-secret"

#     replication {
#         auto {}
#     }
# }

# resource "google_secret_manager_secret_version" "github_token_secret_version" {
#     secret = google_secret_manager_secret.github_token_secret.id
#     secret_data = var.secret_data
# }

# data "google_iam_policy" "serviceagent_secretAccessor" {
#     binding {
#         role = "roles/secretmanager.secretAccessor"
#         members = ["serviceAccount:service-268852292565@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
#     }
# }

# resource "google_secret_manager_secret_iam_policy" "policy" {
#   project = google_secret_manager_secret.github_token_secret.project
#   secret_id = google_secret_manager_secret.github_token_secret.secret_id
#   policy_data = data.google_iam_policy.serviceagent_secretAccessor.policy_data
# }

// Create the GitHub connection
resource "google_cloudbuildv2_connection" "my_connection" {
    project = "gcp-devops-436118"
    location = "us-central1"
    name = "cloudbuild-github-conn"

    github_config {
        app_installation_id = 55361269
        authorizer_credential {
            oauth_token_secret_version = var.secret_data
        }
    }
    # depends_on = [google_secret_manager_secret_iam_policy.policy]
}

//Connecting a GitHub repository
resource "google_cloudbuildv2_repository" "my_repository" {
      project = "gcp-devops-436118"
      location = "us-central1"
      name = "doctopdf_app"
      parent_connection = google_cloudbuildv2_connection.my_connection.name
      remote_uri = "https://github.com/sharayu-potuwar/documentToPDF-app.git"
  }



//Service aaccount 
resource "google_service_account" "cloudbuild_service_account" {
  account_id = "cloudbuild-sa"
}

resource "google_project_iam_member" "act_as" {
  project = "gcp-devops-436118"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_project_iam_member" "logs_writer" {
  project = "gcp-devops-436118"
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}


resource "google_project_iam_member" "artifact_access" {
  project = "gcp-devops-436118"
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

//trigger
resource "google_cloudbuild_trigger" "repo-trigger" {
  name = "cloud-build-trigger"
  project = "gcp-devops-436118"
  location = "us-central1"
  repository_event_config {
    repository = google_cloudbuildv2_repository.my_repository.id
    push {
      branch = "main"
    }
  }

  service_account = google_service_account.cloudbuild_service_account.id
  filename        = "cloudbuild.yaml"
  depends_on = [
    google_project_iam_member.act_as,
    google_project_iam_member.logs_writer
  ]
}
