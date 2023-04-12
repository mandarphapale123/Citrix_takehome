# Citrix_takehome
This repo consists terraform and ansible code to install security agent

Note: Below installations are for MAC

**TERRAFORM** 

_Pre-requisites:_

1. Create an AWS account and a user with administrator access.(save the access_key and secret_key)
2. Create a s3 bucket in your account to store terraform backend configuration
3. Install terraform with below instructions:
   1. Download the latest version of Terraform for Mac by visiting the official Terraform downloads page at https://www.terraform.io/downloads.html. Look for the download link for the Mac OS version and copy it to your clipboard.
      Open Terminal on your Mac and navigate to the directory where you want to install Terraform.
      Run the following command to download the Terraform zip archive: curl -O <DOWNLOAD_LINK>
   2. Unzip the downloaded file: unzip terraform_*_darwin_amd64.zip
   3. Move the Terraform binary to your system's binary directory by running the following command: sudo mv terraform /usr/local/bin/
   4. Verify that Terraform is installed : terraform version
4. Clone the github repository with https or ssh to your desired IDE.

_Steps to run terraform code to create infrastructure on aws:`_

1. In the 'environment.tf' file, include the unique name of the bucket created in the pre-requisites.
2. In the 'environment.tf' file, include the access_key and the secret_key created in the pre-requisites.
3. Open the terminal and do 'terraform init'. This initializes the backend s3 and provider plugins.
4. Once successful, run 'terraform plan' to verify what resources terraform code will be creating.
5. Once verified, run 'terraform apply' to execute the code. Check aws console if these resources are created:
   VPC, subnet, security group, internet gateway, route table, ec2 instance
6. Save the ssh key-pair(.pem file) created after ec2 is created.



**ANSIBLE** 

_Pre-requisites:_

1. Install Ansible on your local machine with following commands (will take upto 20 mins):
    
   1. /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   2. brew install ansible
   3. ansible --version

_Steps to install security agent aws ec2 server using ansible playbook:_

1. Check if you can connect your localhost to remote server with following command:
   ssh -i "<name of the .pem file>" ubuntu@<public dns of the ec2 server>
2. On your local machine , create a folder ansible : mkdir ansible
3. Inside ansible folder, create or paste following files:
   
   1. security_agent_installer_linux_amd64_v1.0.0.sh
   2. security_agent_config.conf

4. Create inventory.ini file :  vi inventory.ini
   Enter the following code:

   [security_agents]
   <IP addr of ec2 server> ansible_user=ubuntu ansible_ssh_private_key_file=<path to your .pem file>

5. Create ansible playbook 'vi install_security_agent.yml' and enter the following code:
      
      
  ``` ---
- name: Install security agent on virtual machine instance
  hosts: security_agents
  become: true

  tasks:
    - name: Create csg_security_agent directory
      file:
      path: /opt/csg_security_agent
      state: directory

    - name: Copy security_agent_installer.sh script
      copy:
      src: security_agent_installer_linux_amd64_v1.0.0.sh
      dest: /opt/csg_security_agent/security_agent_installer.sh
      mode: a+x

    - name: Copy and configure security_agent_config.conf file
      template:
      src: security_agent_config.conf
      dest: /opt/csg_security_agent/security_agent_config.conf
      mode: '0600'

    - name: Install security agent
      shell: /opt/csg_security_agent/security_agent_installer.sh --config /opt/csg_security_agent/security_agent_config.conf --token CSG_$h4p3#7e
      register: command_output

    - debug:
         var: command_output.stdout_lines
```

6. Run the following ansible command to install security agent on ec2 server:
   ansible-playbook -i inventory.ini install_security_agent.yml
