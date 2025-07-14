FROM archlinux:latest

# Update and install base dependencies, sudo, git, and github-cli
# Also install 'which' as it's often used by scripts and might be missing
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm bash sudo git github-cli which less && \
    # Clean up pacman cache
    pacman -Scc --noconfirm

# Create the codespace user with a home directory, add to wheel group (for sudo)
# Set bash as the default shell
RUN useradd -m -G wheel -s /bin/bash codespace && \
    # Setup passwordless sudo for the codespace user
    echo 'codespace ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/codespace && \
    chmod 0440 /etc/sudoers.d/codespace