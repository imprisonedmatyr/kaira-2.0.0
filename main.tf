provider "google" {
  credentials = file("kaira2-d936d79f58f5.json")
  project = "river-cycle-449821-m1"
  region  = "us-central1"
}

resource "google_storage_bucket" "kaira2_bucket" {
  name     = "kaira2-${random_id.bucket_id.hex}"
  location = "US"
  uniform_bucket_level_access = true
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "google_storage_bucket_object" "website_files" {
  for_each = fileset("${path.module}/website", "**")

  name   = each.value
  bucket = google_storage_bucket.kaira2_bucket.name
  source = "${path.module}/website/${each.value}"
}

resource "google_storage_bucket" "website" {
  name     = "kaira2-bucket-${random_id.bucket_id.hex}"
  location = "US"
  storage_class = "STANDARD"
  
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "null_resource" "website_setup" {
  depends_on = [google_storage_bucket.website]

  provisioner "local-exec" {
    command = <<-EOT
      gcloud storage buckets update gs://${google_storage_bucket.website.name} \
        --website-main-page index.html \
        --website-not-found-page 404.html
    EOT
  }
}

resource "null_resource" "set_bucket_permissions" {
  depends_on = [google_storage_bucket.website]

  provisioner "local-exec" {
    command = <<-EOT
      gsutil iam ch allUsers:objectViewer gs://${google_storage_bucket.website.name}
    EOT
  }
}

