#!/bin/bash

psql << EOF
CREATE USER "$POSTGRES_CONTENT_USER" WITH PASSWORD "$POSTGRES_CONTENT_PASSWORD";
CREATE DATABASE "$POSTGRES_CONTENT_DB";
GRANT ALL PRIVILEGES ON DATABASE "$POSTGRES_CONTENT_DB" TO "$POSTGRES_CONTENT_USER";
EOF