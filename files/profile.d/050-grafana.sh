#!/usr/bin/env bash

# Update PATH:
PATH="${PATH}:${HOME}/bin"

# Grafana does NOT support 'sslmode=prefer', replace with 'sslmode=require':
GF_DATABASE_URL="${SCALINGO_POSTGRESQL_URL/prefer/require}"

export PATH
export GF_DATABASE_URL
