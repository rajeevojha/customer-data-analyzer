provider "google" {
  project = "carbide-ether-452420-i7"  # From GCP Console > Project Info
  region  = "us-west1"
}

resource "google_storage_bucket" "function_bucket" {
  name     = "redis-counter-bucket-${random_id.bucket_suffix.hex}"
  location = "US"
}

resource "google_storage_bucket_object" "function_code" {
  name   = "function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "../../node/common/function.zip"  # Zip without inline
}

resource "google_cloudfunctions_function" "redis_counter" {
  name        = "redis-counter"
  runtime     = "nodejs18"
  entry_point = "handler"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_code.name
  environment_variables = {
    REDIS_HOST = local.envs["REDIS_HOST"]  # Replace with local IP later
    REDIS_PORT = local.envs["REDIS_PORT"]  # Replace with local IP later
    REDIS_USER = local.envs["REDIS_USER"]  # Replace with local IP later
    REDIS_PASSWORD = local.envs["REDIS_PASSWORD"]  # Replace with local IP later
  }
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.trigger.name
  }
}

resource "google_pubsub_topic" "trigger" {
  name = "redis-counter-trigger"
}

resource "google_cloud_scheduler_job" "trigger_job" {
  name        = "redis-counter-scheduler"
  schedule    = "*/4 * * * *"  # Every 4s
  pubsub_target {
    topic_name = google_pubsub_topic.trigger.id
    data       = base64encode("{\"source\": \"gcp\"}")
  }
}
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
