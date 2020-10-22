#!/bin/sh
set -eu

if [ -z "$INPUT_SSH_USER" ]; then
    echo "Input INPUT_SSH_USER is required!"
    exit 1
fi

if [ -z "$INPUT_SSH_HOST" ]; then
    echo "Input INPUT_SSH_HOST is required!"
    exit 1
fi

if [ -z "$INPUT_SSH_KNOWN_HOSTS" ]; then
    echo "Input INPUT_SSH_KNOWN_HOSTS is required!"
    exit 1
fi

if [ -z "$INPUT_SSH_PRIVATE_KEY" ]; then
    echo "Input INPUT_SSH_PRIVATE_KEY is required!"
    exit 1
fi

if [ -z "$INPUT_STACK_COMPOSE_FILE" ]; then
    echo "Input INPUT_STACK_COMPOSE_FILE is required!"
    exit 1
fi

if [ -z "$INPUT_STACK_NAME" ]; then
    echo "Input INPUT_STACK_NAME is required!"
    exit 1
fi

echo "Registering SSH keys..."

# Save private key to a file and register it with the agent.
mkdir -p ~/.ssh
printf '%s' "$INPUT_SSH_PRIVATE_KEY" > ~/.ssh/docker
chmod 600 ~/.ssh/docker
eval $(ssh-agent)
ssh-add ~/.ssh/docker
# Add known hosts.
printf '%s' "$INPUT_SSH_KNOWN_HOSTS" > ~/.ssh/known_hosts
cat ~/.ssh/known_hosts

echo "Connecting to $INPUT_SSH_HOST..."
docker --version
docker --host ssh://$INPUT_SSH_USER@$INPUT_SSH_HOST stack deploy --compose-file $INPUT_STACK_COMPOSE_FILE --with-registry-auth $INPUT_STACK_NAME 2>&1