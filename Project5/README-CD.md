# Continuous Deployment (CD)

This project implements a **continuous deployment (CD)** pipeline that builds, tags, pushes, and deploys Docker container images based on Git tags using GitHub Actions and DockerHub.

### Tools Used and Their Roles

- **Git & GitHub**: Version control and workflow trigger via tags
- **GitHub Actions**: Automates build and image publishing based on Git tags
- **Docker**: Containerizes the application
- **DockerHub**: Stores and serves versioned images
- **AWS EC2 (Ubuntu)**: Runs the deployed container application
- **Webhook (adnanh/webhook)**: Listens for image updates and redeploys automatically

![Diagram](Project5-CD-Diagram.png)

### Things Not Working

I didn't get the webhook service working for this project. I also wasn't able to do the demonstration of the project working.

## Generating Tags

### How to See Tags in a Git Repository

```
git tag
```

### How to Generate a Tag in a Git Repository

Use semantic versioning (`v<major>.<minor>.<patch>`):

```
git tag -a v1.0.0 -m "Release version 1.0.0"
```

### How to Push a Tag to GitHub

```
git push origin v1.0.0
```

Push all tags:

```
git push origin --tags
```

---

## Semantic Versioning Container Images with GitHub Actions

### Summary of Workflow Behavior

When a tag is pushed to GitHub:
- GitHub Actions is triggered
- Docker metadata is generated from the tag
- The container is built and tagged with:
  - `latest`
  - `major` (e.g., `1`)
  - `major.minor` (e.g., `1.0`)
- All images are pushed to DockerHub

### Workflow File Explanation

- `on: push: tags:` workflow only runs when tags are pushed
- Uses `docker/metadata-action` to extract semantic versioning
- Builds image with `docker/build-push-action`
- Authenticates to DockerHub using GitHub Secrets (`DOCKER_USERNAME`, `DOCKER_PASSWORD`)
- Pushes images to DockerHub using multiple tags

### Link to Workflow File

[.github/workflows/docker-push.yml](https://github.com/WSU-kduncan/ceg3120-cicd-DJervis04/blob/main/.github/workflows/docker-push.yml)

---

## Testing & Validating

### How to Test That Your Workflow Ran

- Push a tag using:
  ```
  git tag -a v1.0.1 -m "Release 1.0.1"
  git push origin v1.0.1
  ```
- Go to the **Actions** tab in GitHub and confirm that the CD workflow ran successfully.
- Confirm that the DockerHub repo has 3 new tags: `latest`, `1`, and `1.0`.

### How to Verify the Image in DockerHub Works

1. **On your instance, run**:
   ```
   docker pull wsudjervis/jervis-ceg3120:latest
   docker run -d -p 80:80 wsudjervis/jervis-ceg3120:latest
   ```

2. **Validate the Container Is Working**:
   - **Container side**: `docker ps` shows the container is running
   - **Host side**: `curl localhost` returns expected content
   - **External system**: Visit your EC2’s public IP in a browser

## EC2 Instance Details

- **AMI Information**: ami-084568db4383264d4 - ubuntu
- **Instance Type**: `t2.medium`
- **Recommended Volume Size**: 30 GiB
- **Security Group Configuration**:
  - Allow inbound traffic on port 22 (SSH), port 80 (HTTP), and port 9000 (webhook)
- **Justification**: These ports enable secure remote access, web traffic, and payload delivery via webhook.

---

## Docker Setup on the EC2 Instance

### How to Install Docker

```
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
```

### Additional Dependencies

- `curl` and `git` may be needed for downloading webhook and accessing repositories:
```
sudo apt install -y curl git
```

### Confirm Docker Installation

```
docker --version
docker run hello-world
```

---

## Testing on EC2 Instance

### Pull Image from DockerHub

```
docker pull wsudjervis/jervis-ceg3120:latest
```

### Run the Container

```
# for interactive mode
docker run -it wsudjervis/jervis-ceg3120:latest
# for detached mode (Once the testing phase is complete)
docker run -d -p 80:80 wsudjervis/jervis-ceg3120:latest
```

### -it vs -d Flags

- `-it`: interactive mode for debugging
- `-d`: detached mode for background operation (recommended post-testing)

### Verify Angular App is Running

- **Container Side**: `docker ps`, `docker logs <container-id>`
- **Host Side**: `curl localhost`
- **External System**: Visit EC2 public IP in browser

---

## Manual Refresh of Container Application

```
docker stop <container-name>
docker rm <container-name>
docker pull wsudjervis/jervis-ceg3120:latest
docker run -d -p 80:80 wsudjervis/jervis-ceg3120:latest
```

---

## Bash Script for Refresh

Script (`deploy.sh`) should:
1. Stop existing container
2. Remove it
3. Pull new image
4. Start a new container

[deploy.sh](https://github.com/WSU-kduncan/ceg3120-cicd-DJervis04/blob/main/Project5/deployment/deploy.sh)

---

## Webhook Listener Setup

### Install Webhook

```
sudo apt install -y webhook
```

### Verify Installation

```
webhook --version
```

### Webhook Definition Summary

- Path: `/home/ubuntu/ceg3120-cicd-DJervis04/Project5/deployment/hook.json`
- Trigger: GitHub push event with secret header
- Command: Runs `deploy.sh`

### Confirm Webhook is Running

```
ps aux | grep webhook
```

### Monitor Logs

```
journalctl -u webhook.service -f
```

### Docker Process Indicators

- `docker ps` shows container running
- `docker logs <container-id>` confirms app is serving

[hook.json](https://github.com/WSU-kduncan/ceg3120-cicd-DJervis04/blob/main/Project5/deployment/hook.json)

## Payload Sender

I didn't get this to work in my instance by the time I needed to turn this in. The whole webhook.service isn't in this project.

## Resources

[adnanh's `webhook`](https://github.com/adnanh/webhook)
[Docker - Manage Tag Labels](https://docs.docker.com/build/ci/github-actions/manage-tags-labels/)
[GitHub - docker/metadata-action](https://github.com/docker/metadata-action?tab=readme-ov-file#semver)
