
# Ansible controller and agent nodes set up guide

<p align=center>
  <img src=imgs/ansible_diagram.PNG>
</p>

## Why use Ansible

- Ease of use
- Automates and simplifies repetitive tasks
- Can manage several servers at the same time

## Test machines' connection to internet by updating them
```bash
vagrant ssh controller
sudo apt-get update -y
vagrant ssh web
sudo apt-get update -y
vagrant ssh db
sudo apt-get update -y
```

## Install Ansible
```bash
vagrant ssh controller

sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible -y
ansible --version
sudo apt-get install tree -y
```

## Test hosts connection
```bash
cd /etc/ansible
tree
ping 192.168.33.10
ping 192.168.33.11
ansible all -m ping (should throw error because we're trying to ping hosts but we haven't added them to hosts file)
```

## Test SSH into machines
`ssh vagrant@192.168.33.11` (DB, password: vagrant)
`ssh vagrant@192.168.33.10` (WEB, password: vagrant)

## Add hosts
```bash
cd /etc/ansible
sudo nano hosts

[web]
192.168.33.10 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant
[db]
192.168.33.11 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant
ansible all -m ping (to ping successfuly, the machine must be running)
```

## Ad Hoc Commands (Running commands from controller without being inside web or app machines)
```bash
ansible all -a "uname -a"
ansible web -a "date"
ansible all -a "free -m" (check system memory)

# go to ansible doc and find out how to reboot machines and check uptime from controller
ansible all -a "uptime"
```

## Playbooks (Set of instructions)
`sudo nano nginx_playbook.yml`
```Yaml
# This is a playbook to install and set up Nginx in our web server (192.168.33.10)
# This playbook is written in YAML and YAML starts with three dashes (front matter)

---
# name of the hosts - hosts is to define the name of your host of all
- hosts: web

# find the facts about the host
  gather_facts: yes

# admin access
  become: true

# instructions using task module in ansible
  tasks:
  - name: Install Nginx

# install nginx
    apt: pkg=nginx state=present update_cache=yes

# ensure it's running/active
# update cache
# restart nginx if reverse proxy is implemented or if needed
    notify:
      - restart nginx
  - name: Allow all access to tcp port 80
    ufw:
        rule: allow
        port: '80'
        proto: tcp

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

- Run playbook
`ansible-playbook nginx_playbook.yml`
`ansible web -m shell -a "systemctl status nginx"`


### nodeapp_config.yml (pseudo code)

```Yaml
# on the web server we would like to install nodejs with required dependencies so we could launch the nodeapp on the web server's IP
# then moving onto configuring reverse proxy with nginx so we could launch the app on port 80 instead of 3000

# hosts: web
# gather_facts: yes

# instructions in this playbook to install nodejs
# tasks: install nodejs


# shell: 

# copy the app code to web server (clone it from repo, or scp from localhost to controller to web)

# go to right location to install npm, cd app
# npm start
```

### Useful Commands

scp -P 2222 -r ~/Desktop/Work/Sparta/VMs/engi89_nginx/app/ vagrant@127.0.0.1:/home/vagrant
scp -P 2201 -r ~/Desktop/Work/Sparta/GitHub\ Repos/eng89_ansible/eng89_ansible_controller/playbooks/nodejs_playbook.yml vagrant@127.0.0.1:/home/vagrant
scp -P 2201 eng89_devops.pem vagrant@127.0.0.1:/home/vagrant/.ssh/

## Connecting to AWS

```bash
sudo apt install python3-pip
sudo pip3 install awscli
sudo pip3 install boto boto3
sudo apt-get update -y
sudo apt-get upgrade -y
cd /etc/ansible
sudo mkdir group_vars
cd group/vars
sudo mkdir all
cd ~/etc/ansible
sudo vi ansible.conf
  # press i to insert
  # save: esc :wq! then enter
  # to not save: esc q! enter
cd group_vars/all
sudo ansible-vault create pass.yml # (password: sparta)
  vim: 
    aws_access_key: # (paste key from csv and make sure you have a space after:)
    aws_secret_key: 
sudo cat pass.yml
sudo ansible-playbook create_ec2.yml --ask-vault-pass --tags create_ec2
  # (input password created earlier)
  ```