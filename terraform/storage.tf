resource "google_storage_bucket" "raw-document-bucket" {
  name          = "raw-document-bucket"
  location      = "us-central1"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }
}