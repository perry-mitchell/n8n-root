#!/bin/sh

if [ "$#" -gt 0 ]; then
  exec "$@"
else
  exec n8n
fi
