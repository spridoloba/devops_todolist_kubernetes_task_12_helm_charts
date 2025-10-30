#!/bin/bash
set -e


kind create cluster --name todoapp --config cluster.yml


kubectl create namespace todoapp


helm dependency update .


helm install todoapp . --namespace todoapp --create-namespace


kubectl get all -n todoapp
