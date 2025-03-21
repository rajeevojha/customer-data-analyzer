provider "docker" {
  host = "unix:///var/run/docker.sock"  # WSL Docker
}

resource "docker_image" "redis_app" {
  name = "redis-app:latest"
  build {
    context = "../.."
    dockerfile = "node/common/Dockerfile"
  }
}
resource "docker_container" "redis_app" {
  name  = "redis-app3"
  image = docker_image.redis_app.name
  ports {
    internal = 3000
    external = 3000
  }
  #env =["API_URL = ${var.api_url}/prod"] 
  volumes {
     host_path      = "${path.cwd}/docker.env"
     container_path = "/app/.env"
  } 
  networks_advanced {
    name = "bridge"
  }
  dns = ["8.8.8.8", "8.8.4.4"]
  depends_on = [aws_api_gateway_deployment.redis_api]
  command = ["node","index.js","docker","20000"]
}
