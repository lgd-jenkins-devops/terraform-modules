# Este código es compatible con Terraform 4.25.0 y versiones compatibles con 4.25.0.
# Para obtener información sobre la validación de este código de Terraform, consulta https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

resource "google_compute_instance" "vm" {
  boot_disk {
    auto_delete = true
    device_name = var.vm_name

    initialize_params {
      image = "projects/desarrollo-323314/global/images/jenkins"
      size  = 20
      type  = "pd-standard"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = var.type

  metadata = {
    startup-script = "sudo yum install -y  wget\nsudo wget -O /etc/yum.repos.d/jenkins.repo \\\n    https://pkg.jenkins.io/redhat-stable/jenkins.repo\nsudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key\nsudo yum upgrade -y\n# Add required dependencies for the jenkins package\nsudo yum install  -y  fontconfig java-17-openjdk \nsudo yum install -y jenkins\nsudo systemctl daemon-reload"
  }

  name = var.vm_name

  network_interface {
    access_config {
      network_tier = "STANDARD"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = var.subnet_id
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
    provisioning_model  = "SPOT"
  }

  service_account {
    email  = var.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["allow-jenkins","allow-ssh-jenkins"]
  zone = "us-central1-a"
}