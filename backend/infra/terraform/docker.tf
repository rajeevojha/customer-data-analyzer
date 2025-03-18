provider "docker" {
  host = "unix:///var/run/docker.sock"  # WSL Docker
}

#resource "docker_image" "redis" {
#  name = "redis:latest"
#}

#resource "docker_container" "redis_local" {
#  name  = "redis-local"
#  image = docker_image.redis.name
#  ports { 
#    internal = 6379
#    external = 6379 
#  }
#}

resource "docker_image" "redis_app" {
  name = "redis-app:latest"
  build {
    context = "../.."
    dockerfile = "node/common/Dockerfile"
  }
}
resource "docker_container" "redis_app" {
  name  = "redis-app"
  image = docker_image.redis_app.name
  ports {
    internal = 3000
    external = 3000
  }
  env = [
    "API_URL = var.api_url"
  ]
  command = ["node","function.js","docker","20000"]
}
