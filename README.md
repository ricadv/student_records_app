<h1>Description</h1>

- Creates aws resources (ec2, vpc, subnet, routing table, internet gateway, security group) with Terraform.
- Configures an instance to download a source file, copy and start a service that runs the Python program.
- The Python program is a simple student online attendance that accepts a student name and ID.

<h2>Steps</h2>

1. Clone repo and edit aws_keys file to have your aws access key and secret
2. "terraform apply"
3. You should be able to see the instance using "ansible-inventory --graph"
4. "ansible-playbook main.yml"
