resource "google_pubsub_topic" "doc-topic" {
  name = "doc-topic"

  # Outside of automated terraform-provider-google CI tests, these values must be of actual Cloud Storage resources for the test to pass.
  ingestion_data_source_settings {
    cloud_storage {
        bucket = "raw-doc-bkt"
        text_format {
            delimiter = " "
        }
        minimum_object_create_time = "2024-01-01T00:00:00Z"
        match_glob = ".docx"
    }
    platform_logs_settings {
        severity = "WARNING"
    }
    
  }
  depends_on = [ google_storage_bucket_iam_member.storage-bucket-reader, google_storage_bucket_iam_member.storage-object-reader ]
}

resource "google_service_account" "sa" {
  account_id   = "cloud-run-pubsub-invoker"
  display_name = "Cloud Run Pub/Sub Invoker"
}

resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members  = ["serviceAccount:${google_service_account.sa.email}"]
}

resource "google_project_service_identity" "pubsub_agent" {
  provider = google-beta
  project  = "gcp-devops-436118" #data.google_project.project.project_id
  service  = "pubsub.googleapis.com"
}

resource "google_project_iam_binding" "project_token_creator" {
  project = "gcp-devops-436118" #data.google_project.project.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_project_service_identity.pubsub_agent.email}"]
}


resource "google_pubsub_subscription" "compute-subscription" {
  name  = "compute-subscription"
  topic = google_pubsub_topic.doc-topic.id

  ack_deadline_seconds = 20

  labels = {
    foo = "bar"
  }

  push_config {
    push_endpoint = google_cloud_run_v2_service.default.uri
    oidc_token {
      service_account_email = google_service_account.sa.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
}