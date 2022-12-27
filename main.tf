provider "google" {
credentials = //set your creds file path
project = var.project_id
region = var.region
}

resource "google_kms_key_ring" "keyring" {
  name = var.keyring_name
  location = var.region
}

resource "google_kms_crypto_key" "key" {
  name = var.key_name
  key_ring = google_kms_key_ring.keyring.id
  rotation_period = var.rotation_period

  version_template {
    algorithm = var.algorithm
  }

  lifecycle {
    prevent_destroy = false
  }
}

data "google_project" "project" {}


resource "google_kms_crypto_key_iam_binding" "crypto_key" {

  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members       = [
     "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}
