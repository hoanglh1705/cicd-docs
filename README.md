# CICD docs

### This repository to build ci/cd pipeline for aws lambda project by jenkins.
### We will setup Docker on Ubuntu as server and create pipeline with Jenkins cluster (master and worker) on Docker. With Jenkins cluster, Docker will spin up agent container to run pipeline, and agent container will be terminated after pipeline done. 

# Prerequisites
 - Ubuntu 22.04
 - Docker
 - Jenkins
 - AWS CLI
 - Serverless framework

# 1. Install Docker on Ubuntu server

    First, update your existing list of packages:
    > sudo apt update

    Next, install a few prerequisite packages which let apt use packages over HTTPS:
    > sudo apt install apt-transport-https ca-certificates curl software-properties-common

    Then add the GPG key for the official Docker repository to your system:
    > curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    Add the Docker repository to APT sources:
    > sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

    Finally, install Docker:
    > sudo apt install docker-ce

    Check that it’s running:
    > sudo systemctl status docker

    If you want to avoid typing sudo whenever you run the docker command, add your username to the docker group:
    > sudo usermod -aG docker ${USER}

    To apply the new group membership, log out of the server and back in, or type the following:
    > su - ${USER}

    Confirm that your user is now added to the docker group by typing:
    > groups

ref: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04
ref: https://www.geeksforgeeks.org/how-to-setup-jenkins-in-docker-container/ (AWS EC2)

# 2. Configure a Docker Host With Remote API

### Set up a docker host at port 2376. Jenkins server will connect to this host for spinning up the build agent containers.

    Open the docker service file:
    > sudo vim /lib/systemd/system/docker.service
    
    Search for ExecStart and replace that line with the following:
    > ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock

    Reload and restart docker service:
    > sudo systemctl daemon-reload
    > sudo service docker restart

    Validate API by executing the following curl commands. Replace 54.221.134.7 with your host IP:
    > curl http://localhost:2376/version
    > curl http://54.221.134.7:2376/version

ref: https://devopscube.com/docker-containers-as-build-slaves-jenkins/

# 3. Install and set up Jenkins master

    Install Jenkins master on Docker:
    > docker run --name jenkins-master --restart=on-failure -d -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
ref: https://www.jenkins.io/doc/book/installing/docker/

    If server run on EC2 instance, edit inbound rule to access jenkins from internet:
    > Type: Custom TCP
    > Port range: 8080
    > Source: Any where IPv4

    > Type: Custom TCP
    > Port range: 32768 - 60999
    > Source: My IP

    Set up Jenkins and add Docker plugin:
    https://www.bogotobogo.com/DevOps/Docker/Docker-Jenkins-Master-Slave-Agent-ssh.php

# 4. Create Jenkins agent Docker Image
    At folder jenkins-slave, we will create jenkins slave image to use for Docker agent in Jenkins.
    Jenkins master connect with docker agent by ssh with user:pass.

    Build jenkins-slave images:
    > docker build -t jenkins-slave .

ref: https://www.coachdevops.com/2022/08/jenkins-build-agent-setup-using-docker.html

# 5. Configure Jenkins to connect Docker

Access Jenkins on browser: http://localhost:8080/

    Now go to **Manage Jenkins** -> **Configure Nodes Cloud** or **Manage Nodes and Clouds** (Depends on Jenkins version) -> **Configure Clouds**

    Click on **Docker Cloud Details** 

    Enter value:
        Docker Host URI:
        > tcp://docker_host_dns:2376 (docker_host_dns is the ip address of Ubuntu server which running Docker)
        > Example: tcp://192.168.1.11:2376 (If ubuntu server is EC2 instance, ip is the private IP address of instance)
    
        Make sure **Enabled** is selected

        Now click on Test Connection to make sure connecting with docker host is working. Result success example: **Version = 20.10.21, API Version = 1.41**

    Click on **Docker Agent templates...**

    Enter value:
        Labels:
        > docker-slave

        Make sure **Enable** is selected

        Name:
        > docker-slave

        Docker Image: (image tag of Docker agent images was builded at step 4)
        > jenkins-slave

        Remote File System Root:
        > /home/jenkins

        Usage:
        > Use this node as much as possible

        Connect method:
        > Connect with SSH

        SSH key:
        > Use configured SSH credentials

            SSH Credentials:
                Click **+Add** -> **Jenkins** -> Open **Add Credentials** dialog to config

                Add Credentials:
                    Kind:
                    > Username with password

                    Scope:
                    > Global (Jenkins, node, items. all child items, etc)

                    Username: (user name in Dockerfile of jenkins-slave)
                    > jenkins

                    Password: (password of user name in Dockerfile of jenkins-slave)
                    > slave@123

                    ID:
                    > jenkins-slave-user

                    Description:
                    > Jenkins slave user 

                    Click **Add**

                Choose jenkins slave user credentials

            Host Key Verification Strategy:
            > Non verifying Verification Strategy
        
        Pull strategy:
        > Never pull

        Click **Save**

ref: https://www.coachdevops.com/2022/08/jenkins-build-agent-setup-using-docker.html

# 6. Create CI/CD pipeline for project

    Copy scripts folder, Makefile, serverless.dev.yml and Jenkinsfile into your project. Replace parameters with your value (aws key, aws role, aws profile, aws region,...)

    Change value of GOPRIVATE env if your repository in private zone.

    In Jenkins Dashboard, create **New Item** -> **Pipeline**

    In Pipeline configure:
        Definition:
        > Pipeline script from SCM

        SCM:
        > Git

        Repositories:
            Repository URL: (Add your repository url)
            > https://github.com/hoanglh1705/cicd-docs.git

            Credentials: (Add git user in credentials)
            > Gitlab user to access repositories

        Branch Specifier:
        > */dev

        Script Path:
        > Jenkinsfile

    Click **Save**

    DONE!!! Build and fix if have any error :)))

# Congratulation!!! Welcome to CI/CD lands