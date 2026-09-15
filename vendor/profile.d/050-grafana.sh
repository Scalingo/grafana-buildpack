#!/usr/bin/env bash

# Update PATH:
PATH="${PATH}:${HOME}/grafana/bin"
export PATH

GF_PATHS_HOME="${HOME}/grafana"
export GF_PATHS_HOME

# Grafana does NOT support 'sslmode=prefer', replace with 'sslmode=require':
if [[ -n "${SCALINGO_POSTGRESQL_URL}" ]]; then
	GF_DATABASE_URL="${SCALINGO_POSTGRESQL_URL/prefer/require}"
	export GF_DATABASE_URL
fi
