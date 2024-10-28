#!/bin/bash

set -e

terraform init
terraform apply -auto-approve

APP_IP=$(terraform output -raw app_instance_public_ip)
DB_IP=$(terraform output -raw db_instance_public_ip)

cat <<EOL > ansible/inventory.yml
all:
  hosts:
    app_servers:
      ansible_host: $APP_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa

    db_servers:
      ansible_host: $DB_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
EOL

ansible-playbook -i ansible/inventory.yml ansible/playbook.yml

echo "Deployment completed!"
