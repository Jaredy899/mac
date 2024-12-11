#!/bin/bash

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Check if zsh is being used
if [ -n "$ZSH_VERSION" ]; then
  printf "%sDetected zsh. Using zsh for script execution.%s\n" "${CYAN}" "${RC}"
  exec zsh "$0" "$@"
  exit
fi

# Variables
SSH_DIR="$HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# Ensure the .ssh directory exists
if [ ! -d "$SSH_DIR" ]; then
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  printf "%sCreated %s and set permissions to 700.%s\n" "${GREEN}" "$SSH_DIR" "${RC}"
else
  printf "%s%s already exists.%s\n" "${YELLOW}" "$SSH_DIR" "${RC}"
fi

# Ensure the authorized_keys file exists
if [ ! -f "$AUTHORIZED_KEYS" ]; then
  touch "$AUTHORIZED_KEYS"
  chmod 600 "$AUTHORIZED_KEYS"
  printf "%sCreated %s and set permissions to 600.%s\n" "${GREEN}" "$AUTHORIZED_KEYS" "${RC}"
else
  printf "%s%s already exists.%s\n" "${YELLOW}" "$AUTHORIZED_KEYS" "${RC}"
fi

# Add the public key to the authorized_keys file if not already added
printf "%sEnter the public key to add: %s" "${CYAN}" "${RC}"
read PUBLIC_KEY

if grep -q "$PUBLIC_KEY" "$AUTHORIZED_KEYS"; then
  printf "%sPublic key already exists in %s.%s\n" "${YELLOW}" "$AUTHORIZED_KEYS" "${RC}"
else
  echo "$PUBLIC_KEY" >> "$AUTHORIZED_KEYS"
  printf "%sPublic key added to %s.%s\n" "${GREEN}" "$AUTHORIZED_KEYS" "${RC}"
fi

printf "%sDone.%s\n" "${GREEN}" "${RC}"
