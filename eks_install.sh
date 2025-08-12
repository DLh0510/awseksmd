#!/bin/bash
 
# Exit on error
set -e
 
echo "Starting installation and configuration of AWS CLI, kubectl, and eksctl..."
 
# Install AWS CLI
echo "Installing AWS CLI..."
sudo yum remove -y awscli || true
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws
 
# Install kubectl
echo "Installing kubectl..."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl.sha256
sha256sum -c kubectl.sha256
chmod +x ./kubectl
mkdir -p $HOME/bin
cp ./kubectl $HOME/bin/kubectl
rm -f kubectl kubectl.sha256
 
# Install eksctl
echo "Installing eksctl..."
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check || echo "Warning: eksctl checksum verification failed"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm -f eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin
 
# Configure PATH and shell settings permanently
echo "Configuring PATH and shell settings..."
 
# Check if .bashrc exists, create if not
touch ~/.bashrc
 
# Check if .bash_profile exists, create if not
touch ~/.bash_profile
 
# Add PATH configurations to .bashrc if not already present
if ! grep -q "export PATH=/usr/local/bin:\$PATH" ~/.bashrc; then
    echo 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc
fi
 
if ! grep -q "export PATH=\$HOME/bin:\$PATH" ~/.bashrc; then
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
fi
 
# Add kubectl autocompletion to .bashrc if not already present
if ! grep -q "source <(kubectl completion bash)" ~/.bashrc; then
    echo 'source <(kubectl completion bash)' >> ~/.bashrc
fi
 
# Add kubectl alias to .bashrc if not already present
if ! grep -q "alias k=kubectl" ~/.bashrc; then
    echo 'alias k=kubectl' >> ~/.bashrc
    echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
fi
 
# Source .bashrc from .bash_profile if not already present
if ! grep -q "source ~/.bashrc" ~/.bash_profile; then
    echo 'if [ -f ~/.bashrc ]; then source ~/.bashrc; fi' >> ~/.bash_profile
fi
 
# Apply changes to current session
source ~/.bashrc
 
echo "Installation and configuration completed successfully!"
echo "Your PATH and tools are now permanently configured."
echo "You can verify the installations with:"
echo "  aws --version"
echo "  kubectl version --client"
echo "  eksctl version"
