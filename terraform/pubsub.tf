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
}


resource "google_pubsub_topic_iam_member" "doc-topic-member" {
  project = google_pubsub_topic.doc-topic.project
  topic = google_pubsub_topic.doc-topic.name
  role = "roles/storage.objectViewer"
  member = "service-268852292565@gcp-sa-pubsub.iam.gserviceaccount.com"
}


resource "google_pubsub_subscription" "compute-subscription" {
  name  = "compute-subscription"
  topic = google_pubsub_topic.doc-topic.id

  ack_deadline_seconds = 20

  labels = {
    foo = "bar"
  }

  push_config {
    push_endpoint = "https://compute-subscription.com/push"

    attributes = {
      x-goog-version = "v1"
    }
  }
}