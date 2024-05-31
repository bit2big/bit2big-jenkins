# Bit2Big Jenkins

This repository contains a Docker-based Jenkins setup for Bit2Big builds, ensuring a secure and maintainable CI/CD environment.

## Features

- Dockerized Jenkins with pre-installed plugins
- Secure setup with best practices
- Configuration as Code for reproducible builds
- Environment variable support for credentials

## Setup

1. **Clone the repository:**

   ```sh
   git clone https://github.com/your-username/bit2big-jenkins.git
   cd bit2big-jenkins
   ```

2. **Create a `.env` file:**

   ```sh
   cp .env.example .env
   ```

   Edit the `.env` file to include your credentials:

   ```env
   JENKINS_ADMIN_ID=admin
   JENKINS_ADMIN_PASSWORD=securepassword123
   ```

3. **Build and run the Jenkins container:**

   ```sh
   docker-compose up -d
   ```

4. **Access Jenkins:**

   Open your browser and navigate to `http://jenkins.dev.bit2big.com`. Log in using the credentials specified in the `.env` file.

## Maintenance

- **Updating Jenkins:**

  To update Jenkins to the latest version, rebuild the Docker image:

  ```sh
  docker-compose build
  docker-compose up -d
  ```

- **Updating Plugins:**

  Update the `plugins.txt` file with the desired plugin versions and rebuild the Docker image.

## Security Best Practices

- Store credentials securely using environment variables.
- Regularly update Jenkins and plugins to the latest versions.
- Limit access to Jenkins to authorized users only.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
