#!/bin/bash

# Public IP address of your ingress controller
IP="40.87.93.142"

# Name to associate with public IP address
DNSNAME="bridgevision-preprod"

# Get the resource-id of the public ip
PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)

# Update public ip address with DNS name
az network public-ip update --ids $PUBLICIPID --dns-name $DNSNAME