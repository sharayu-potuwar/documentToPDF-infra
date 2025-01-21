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

resource "google_storage_bucket_iam_member" "storage-bucket-reader" {
  bucket = google_storage_bucket.raw-doc-bkt.name
  role = "roles/storage.legacyBucketReader"
  member = "serviceAccount:service-268852292565@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "storage-object-reader" {
  bucket = google_storage_bucket.raw-doc-bkt.name
  role = "roles/storage.legacyObjectReader"
  member = "serviceAccount:service-268852292565@gcp-sa-pubsub.iam.gserviceaccount.com"
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