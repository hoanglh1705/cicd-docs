FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get install -qy git curl make && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 11
    apt-get install -qy default-jdk && \
# Install maven
    apt-get install -qy maven && \
# Cleanup old packages
    apt-get -qy autoremove
# Install npm
RUN apt-get install nodejs -y  && \
    apt-get -qy install npm && \
    node -v

# Install serverless framework
RUN npm install -g serverless@3.34.0 && \
    npm install -g serverless-hooks-plugin && \
    npm install -g serverless-prune-plugin && \
    npm install -g serverless-api-gateway-throttling

# Install serverless plugin 
RUN npm install -g @agiledigital/serverless-sns-sqs-lambda && \
    npm install -g serverless-git-info

# Install AWS CLI
RUN apt-get install unzip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Install Golang
RUN curl -O -L "https://golang.org/dl/go1.19.3.linux-amd64.tar.gz" && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz

# Set environment for Go
ENV GOPATH=/go
ENV GOBIN=$GOPATH/bin
ENV PATH=$PATH:/usr/local/go/bin:$GOROOT:$GOPATH:$GOBIN
ENV GOPRIVATE="gitlab.com"
ENV GONOPROXY="gitlab.com"
ENV GONOSUMDB="gitlab.com"
ENV GOINSECURE="gitlab.com"
ENV AWS_PROFILE="aws-profile"

# Install go-swagger
RUN apt-get install -qy jq && \
    download_url=$(curl -s https://api.github.com/repos/go-swagger/go-swagger/releases/51070809 | \
  jq -r '.assets[] | select(.name | contains("'"$(uname | tr '[:upper:]' '[:lower:]')"'_amd64")) | .browser_download_url') && \
    curl -o /usr/local/bin/swagger -L'#' "$download_url" && \
    chmod +x /usr/local/bin/swagger

# Clean
RUN rm -rf /var/cache/apt && rm -rf /var/lib/apt/lists/* && \
    rm -rf go1.19.3.linux-amd64.tar.gz && \
    rm -rf awscliv2.zip && \
    go version && \
    aws --version && \
    swagger version

# Add user jenkins to the image
RUN adduser --quiet jenkins && \
# Set password for the jenkins user.
    echo "jenkins:slave@123" | chpasswd && \
    mkdir /home/jenkins/.m2

# Copy authorized keys
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
