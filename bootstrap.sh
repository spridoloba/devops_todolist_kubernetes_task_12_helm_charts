#!/bin/bash
set -e

echo "creating Kind cluster"
kind create cluster --name todoapp --config cluster.yml > output.log 2>&1

echo "applying taints to mysql nodes"
MYSQL_NODES=$(kubectl get nodes -l app=mysql -o name || true)
if [[ -n "$MYSQL_NODES" ]]; then
  while IFS= read -r node; do
    echo " -> taint ${node#node/}" | tee -a output.log
    kubectl taint nodes "${node#node/}" app=mysql:NoSchedule --overwrite >> output.log 2>&1
  done <<< "$MYSQL_NODES"
else
  echo "no nodes labeled with app=mysql found, skipping taint." | tee -a output.log
fi

echo "creating namespace..."
kubectl create namespace todoapp --dry-run=client -o yaml | kubectl apply -f - >> output.log 2>&1

echo "updating Helm dependencies..."
helm dependency update .infrastructure/helm-chart/todoapp >> output.log 2>&1

echo "[5/5] Installing Helm chart..."
helm install todoapp .infrastructure/helm-chart/todoapp -n todoapp --create-namespace >> output.log 2>&1

echo "installation complete, cluster resources:" | tee -a output.log
kubectl get all,cm,secret,ing -n todoapp | tee -a output.log
