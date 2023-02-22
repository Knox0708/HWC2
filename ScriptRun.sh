#!/bin/bash

sudo: ["ubuntu ALL=(ALL) NOPASSWD:ALL"]

echo "This script will run the FBInstalling script"
/bin/bash logstashInstall.sh
