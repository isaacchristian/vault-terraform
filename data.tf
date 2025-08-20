# data.tf

data "local_sensitive_file" "auth_backend_ca" {
    filename = "${path.module}/minikube-apiserver-ca.crt"
}

data "local_sensitive_file" "auth_backend_jwt" {
    filename = "${path.module}/apiserver-reviewer.jwt"
}