# variables.tf

variable "kubernetes_host" {
    type = string
    default = "https://kubernetes.default.svc:443"
    description = "The URL of the Kubernetes API server"
}

variable "issuer" {
    type = string
    default = "https://kubernetes.default.svc.cluster.local"
    description = "The issuer URL for the Kubernetes authentication backend"
}

variable "key_type" {
    type = string
    default = "aes256-gcm96"
    description = "The type of key to use for the transit secrets engine"
}

