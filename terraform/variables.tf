variable "main_instance_ami" {
    description = "instance AMI for the REST API, default using Ubuntu Server 22.04 LTS"
    type = string
    default = "ami-00983e8a26e4c9bd9"
}