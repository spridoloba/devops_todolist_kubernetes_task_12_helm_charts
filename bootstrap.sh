#!/bin/bash
set -e

kind create cluster --name todoapp
kubectl create namespace todoapp --dry-run=client -o yaml | kubectl apply -f -
helm dependency update ./charts/todoapp
helm install todoapp ./charts/todoapp -n todoapp --create-namespace
kubectl get all,cm,secret,ing -A | tee output.log
