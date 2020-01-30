#!/bin/bash

# Public IP address of your ingress controller
IP="168.61.42.168"

# Name to associate with public IP address
DNSNAME="bridgevision-prod"

# Get the resource-id of the public ip
PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)

# Update public ip address with DNS name
az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME