#!/bin/bash
set -e

function is_mongodb_running() {
  if mongosh --host mongo1 --port 27017 --eval "db.adminCommand('ping')" | grep 'ok'; then
    return 0
  else
    return 1
  fi
}

function is_replicat_set_initialized() {
  if mongosh --host mongo1 --port 27017 --eval "rs.status()" | grep 'ok'; then
    return 0
  else
    return 1
  fi
}

echo "Waiting for mongodb initialize..."
until is_mongodb_running; do
  sleep 1
done

echo "Setting up replica set"
if is_replicat_set_initialized; then
  echo "Replica set already initialized"
else
  mongosh --host mongo1 --eval 'rs.initiate({
    _id: "rs0",
    members: [
      { _id: 0, host: "mongo1:27017", priority: 2 },
      { _id: 1, host: "mongo2:27017", priority: 1}
    ]
  })'
fi

echo "MongoDB replica set is ready! 🚀"
