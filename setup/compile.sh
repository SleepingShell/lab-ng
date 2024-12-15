#!/bin/bash
source .env

talhelper gensecret > talsecret.sops.yaml
sops -e -i talsecret.sops.yaml
talhelper genconfig