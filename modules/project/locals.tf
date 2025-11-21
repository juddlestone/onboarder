locals {
  common_tags = {
    ProjectOwner = var.project_owner
    ProjectName  = var.project_name
    TimeCreated  = "${time_static.this.year}/${time_static.this.month}/${time_static.this.day}"
  }
}
