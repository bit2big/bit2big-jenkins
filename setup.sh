#!/bin/bash

# Create the necessary directories
mkdir -p bit2big-jenkins/{jenkins,scripts/init.groovy.d}

# Navigate to the project directory
cd bit2big-jenkins

# Create the Dockerfile
cat <<EOF > Dockerfile
# Dockerfile
FROM jenkins/jenkins:latest-alpine

LABEL maintainer="Michael Kiberu <mail@kipya.com>"

# Preinstall necessary plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copy init scripts
COPY scripts/init.groovy.d /usr/share/jenkins/ref/init.groovy.d

# Copy configuration as code files
COPY jenkins/casc.yaml /usr/share/jenkins/ref/casc.yaml

# Setting environment variables
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/casc.yaml


USER root
RUN apk add --no-cache sudo
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
USER jenkins
EOF

# Create the plugins.txt file
cat <<EOF > plugins.txt
# plugins.txt
docker-workflow:1.26
github:1.34.1
workflow-aggregator:2.6
credentials-binding:1.24
ssh-agent:1.23
email-ext:2.83
configuration-as-code:1.51
EOF

# Create the docker-compose.yml file
cat <<EOF > docker-compose.yml
services:
  jenkins:
    build: .
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    environment:
      - JENKINS_ADMIN_ID=\${JENKINS_ADMIN_ID}
      - JENKINS_ADMIN_PASSWORD=\${JENKINS_ADMIN_PASSWORD}
      - CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/casc.yaml
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.jenkins.rule=Host(\`jenkins.dev.bit2big.com\`)"
      - "traefik.http.routers.jenkins.entrypoints=web"
      - "traefik.docker.network=traefik"

volumes:
  jenkins_home:

networks:
  t2-proxy:
    external: true
EOF

# Create the .env file
cat <<EOF > .env
JENKINS_ADMIN_ID=admin
JENKINS_ADMIN_PASSWORD=m9AHUqpF5bl9QG63olX#
EOF

# Create the jenkins/casc.yaml file
cat <<EOF > jenkins/casc.yaml
# jenkins/casc.yaml
jenkins:
  systemMessage: "Jenkins configured with Configuration as Code plugin"
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: \${JENKINS_ADMIN_ID}
          password: \${JENKINS_ADMIN_PASSWORD}
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
EOF

# Create the scripts/init.groovy.d/basic-security.groovy file
cat <<EOF > scripts/init.groovy.d/basic-security.groovy
// scripts/init.groovy.d/basic-security.groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(System.getenv("JENKINS_ADMIN_ID"), System.getenv("JENKINS_ADMIN_PASSWORD"))
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
EOF

# Create the README.md file
cat <<EOF > README.md
# Bit2Big Jenkins

This repository contains a Docker-based Jenkins setup for Bit2Big builds, ensuring a secure and maintainable CI/CD environment.

## Features

- Dockerized Jenkins with pre-installed plugins
- Secure setup with best practices
- Configuration as Code for reproducible builds
- Environment variable support for credentials

## Setup

1. **Clone the repository:**

   \`\`\`sh
   git clone https://github.com/your-username/bit2big-jenkins.git
   cd bit2big-jenkins
   \`\`\`

2. **Create a \`.env\` file:**

   \`\`\`sh
   cp .env.example .env
   \`\`\`

   Edit the \`.env\` file to include your credentials:

   \`\`\`env
   JENKINS_ADMIN_ID=admin
   JENKINS_ADMIN_PASSWORD=securepassword123
   \`\`\`

3. **Build and run the Jenkins container:**

   \`\`\`sh
   docker-compose up -d
   \`\`\`

4. **Access Jenkins:**

   Open your browser and navigate to \`http://jenkins.dev.bit2big.com\`. Log in using the credentials specified in the \`.env\` file.

## Maintenance

- **Updating Jenkins:**

  To update Jenkins to the latest version, rebuild the Docker image:

  \`\`\`sh
  docker-compose build
  docker-compose up -d
  \`\`\`

- **Updating Plugins:**

  Update the \`plugins.txt\` file with the desired plugin versions and rebuild the Docker image.

## Security Best Practices

- Store credentials securely using environment variables.
- Regularly update Jenkins and plugins to the latest versions.
- Limit access to Jenkins to authorized users only.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
EOF

# Print completion message
echo "Project structure created successfully."

