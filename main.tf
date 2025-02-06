provider "google" {
  credentials = file("credentials.json")
  project = "river-cycle-449821-m1"
  region  = "us-central1"
}

resource "google_storage_bucket" "library_website_bucket" {
  name     = "library-website-${random_id.bucket_id.hex}"
  location = "US"
  uniform_bucket_level_access = true
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "google_storage_bucket_object" "website_files" {
  for_each = fileset("${path.module}/website", "**")

  name   = each.value
  bucket = google_storage_bucket.library_website_bucket.name
  source = "${path.module}/website/${each.value}"
}

resource "google_storage_bucket" "website" {
  name     = "my-unique-bucket-${random_id.bucket_id.hex}"
  location = "US"
  storage_class = "STANDARD"
  
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

