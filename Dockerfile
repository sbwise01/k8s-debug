ARG KSOPS_VERSION="v4.1.1"

# Using ksops image to install ksops and kustomize
FROM --platform=linux/amd64 viaductoss/ksops:$KSOPS_VERSION as ksops-builder

FROM --platform=linux/amd64 ubuntu

# Core
RUN apt update && apt install -y curl wget gnupg unzip lsb-release jq bash-completion python3-pip

# Packages
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
  netcat \
  traceroute \
  dnsutils \
  iputils-ping \
  vim \
  tree \
  net-tools \
  iproute2 \
  openssh-client \
  openssl \
  postgresql \
  redis

RUN apt-get clean -y

# Access to source command
RUN ln -snf /bin/bash /bin/sh
RUN source /etc/bash_completion
RUN echo "source /etc/bash_completion" >> ~/.bashrc

# Install Kubernetes CLI (kubectl)
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
COPY install_kubectl.sh .
RUN /bin/bash install_kubectl.sh
RUN rm -f install_kubectl.sh kubectl kubectl.sha256
RUN kubectl completion bash >> ~/.kubectl_completion
RUN echo "source ~/.kubectl_completion" >> ~/.bashrc

# Install sops
ARG SOPS_VERSION=v3.7.3
RUN curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    chmod +x /usr/local/bin/sops

# Override the default kustomize executable with the Go built version
COPY --from=ksops-builder /go/bin/kustomize /usr/local/bin/kustomize

# Add ksops executable to path
COPY --from=ksops-builder /go/src/github.com/viaduct-ai/kustomize-sops/ksops /usr/local/bin/ksops
RUN mkdir -p /home/argocd/.config/kustomize/plugin/viaduct.ai/v1/ksops
COPY --from=ksops-builder /go/src/github.com/viaduct-ai/kustomize-sops/ksops /home/argocd/.config/kustomize/plugin/viaduct.ai/v1/ksops/ksops

# Install AWS Cli (using pip3 to install, to ensure newest version available)
RUN pip3 install awscli
RUN complete -C '/usr/local/bin/aws_completer' aws
RUN echo "complete -C '/usr/local/bin/aws_completer' aws" >> ~/.bashrc
