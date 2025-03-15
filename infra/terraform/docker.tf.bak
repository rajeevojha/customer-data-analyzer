provider "docker" {
  host = "unix:///var/run/docker.sock"  # WSL Docker
}

resource "docker_image" "redis_app" {
  name = "redis-app:latest"
  build {
    context = "../../"
    dockerfile = "Dockerfile"
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
    "REDIS_HOST=${local.envs["REDIS_HOST"]}",
    "REDIS_PASSWORD=${local.envs["REDIS_PASSWORD"]}"
  ]
}
