locals {
  tags = {
    ProjectOwner = "jack@itsjack.cloud"
    ProjectName  = "Project Onboarder"
    TimeCreated  = "${time_static.this.year}/${time_static.this.month}/${time_static.this.day}"
  }

  basic_project_data_dir = "${path.root}/project_data/basic"
  basic_project_files    = fileset(local.basic_project_data_dir, "project_*.json")
  basic_projects = {
    for file in local.basic_project_files :
    file => jsondecode(file("${local.basic_project_data_dir}/${file}"))
  }
}
