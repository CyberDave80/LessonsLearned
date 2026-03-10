# Local Production-Style K3s + Rancher Cluster using k3d

## Overview
This guide uses **k3d** to run a multi-node, Highly Available (HA) K3s cluster entirely within local Docker containers, managed by Rancher.



## Prerequisites
* **Docker** installed and running.
* **k3d** installed (`brew install k3d` on Mac, or `curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash`).
* **kubectl** and **helm** installed.

---

## 1. Create the HA K3s Cluster with k3d

Create a cluster with 3 control-plane nodes (servers) and 2 worker nodes (agents). The `--port` flags map the k3d load balancer to your localhost so you can access the Rancher UI.
```bash
k3d cluster create rancher-cluster \
  --servers 3 \
  --agents 2 \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer"
```

Verify the nodes are running (K3s treats these as real nodes, but they are Docker containers):
```bash
kubectl get nodes
docker ps
```

---

## 2. Install Cert-Manager

Rancher requires cert-manager for certificate lifecycle management.
```bash
helm repo add jetstack [https://charts.jetstack.io](https://charts.jetstack.io)
helm repo update

kubectl apply -f [https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml](https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml)

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.1
```

---

## 3. Install Rancher via Helm

Install Rancher and set the hostname to `rancher.localhost`.
```bash
helm repo add rancher-latest [https://releases.rancher.com/server-charts/latest](https://releases.rancher.com/server-charts/latest)
helm repo update

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --create-namespace \
  --set hostname=rancher.localhost \
  --set bootstrapPassword=admin \
  --set replicas=3
```

---

## 4. Verify and Access

Wait for Rancher to finish deploying:
```bash
kubectl -n cattle-system rollout status deploy/rancher
```

Access the UI:
1. Open your browser and go to `https://rancher.localhost`
2. Bypass the browser's self-signed certificate warning.
3. Log in with the password: `admin`

---

## Cleanup
To tear down the entire environment and remove the containers:
```bash
k3d cluster delete rancher-cluster
```
