#!/bin/bash

# Script to run the ADK agent
# Usage:
# ./runme.sh        (starts in console/chat mode)
# ./runme.sh --web  (starts in web mode)

# Default mode is chat
MODE="chat"
AGENT_MODULE="olive.agent"

# Determine the project root directory (where the script is located)
PROJECT_ROOT=$(dirname "$(realpath "$0")")

# Check for --web flag
if [ "$1" = "--web" ]; then
  MODE="serve"
  echo "Starting ADK in web mode (adk serve)..."
else
  echo "Starting ADK in console mode (adk chat)..."
  if [ -z "$1" ]; then # Only show hint if no arguments were passed
    echo "Hint: To run in web mode, use: $0 --web"
  fi
fi

# Activate virtual environment
VENV_PATH="$PROJECT_ROOT/.venv/bin/activate"
if [ -f "$VENV_PATH" ]; then
  echo "Activating virtual environment from $VENV_PATH..."
  . "$VENV_PATH"
else
  echo "Error: Virtual environment not found at $VENV_PATH"
  echo "Please ensure you have run 'uv venv' in the project root ($PROJECT_ROOT)."
  exit 1
fi

# Check if adk command is available and offer to install if not
if ! command -v adk &> /dev/null; then
    echo "---------------------------------------------------------------------"
    echo "The 'adk' command was not found in your activated virtual environment."
    echo "This is part of the 'google-adk' package."
    echo "---------------------------------------------------------------------"
    read -p "Would you like to attempt to install it now using 'uv pip install google-adk'? (y/N): " install_choice
    if [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then
        echo "Attempting to install google-adk..."
        if uv pip install google-adk; then
            echo "google-adk installed successfully."
            # Re-check if adk is now available
            if ! command -v adk &> /dev/null; then
                echo "Error: 'adk' command still not found after installation attempt. Please check your environment and installation."
                exit 1
            fi
        else
            echo "Error: Failed to install google-adk. Please install it manually in your '.venv' environment."
            exit 1
        fi
    else
        echo "Installation skipped. 'adk' command is required to run the agent."
        exit 1
    fi
fi

# Run the ADK command
echo "Executing: adk $MODE $AGENT_MODULE"
adk $MODE $AGENT_MODULE
# The script will exit when the adk command finishes.
# Deactivation of venv happens automatically on script exit or can be done manually if needed.