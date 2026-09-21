-- Runs automatically on first container start via /docker-entrypoint-initdb.d.

CREATE USER appuser WITH PASSWORD 'apppass';
CREATE DATABASE appdb OWNER appuser;
