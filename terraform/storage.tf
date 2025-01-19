resource "google_storage_bucket" "raw-doc-bkt" {
  name          = "raw-doc-bkt"
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

resource "google_storage_bucket" "pdf-doc-bkt" {
  name          = "pdf-doc-bkt"
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