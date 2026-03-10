# Local Kubernetes Cluster with KIND (Kubernetes-in-Docker)

## Overview

This project demonstrates how to create a **local multi-node Kubernetes cluster** using **KIND (Kubernetes IN Docker)**.

Instead of using real servers or virtual machines, KIND creates **Docker containers that behave like Kubernetes nodes**. This allows you to simulate a real cluster directly on your laptop.

This setup is extremely useful for:

* Learning Kubernetes
* Practicing for certifications like **CKA**
* Testing deployments locally
* Experimenting with multi-node clusters

---

# Conceptual Explanation

Modern container infrastructure has several layers.

## Layer 1 — Your Computer

Your laptop or workstation is the base system.

```
Laptop
```

---

## Layer 2 — Docker

Docker runs containers that isolate applications.

```
Laptop
  └ Docker Engine
      └ Containers
```

Normally, containers run applications like:

* nginx
* redis
* postgres

---

## Layer 3 — KIND Nodes

KIND creates **Docker containers that pretend to be servers**.

Each container becomes a **Kubernetes node**.

Example nodes created by KIND:

```
desktop-control-plane
desktop-worker
desktop-worker2
```

These are **Docker containers**, but Kubernetes treats them like **real machines**.

```
Laptop
  └ Docker
      └ KIND Node Containers
```

---

## Layer 4 — Kubernetes Cluster

Inside those node containers, Kubernetes components run:

Control plane node:

* API server
* scheduler
* controller manager

Worker nodes:

* kubelet
* container runtime
* networking

```
Laptop
  └ Docker
      └ KIND Nodes
          └ Kubernetes Cluster
```

---

## Layer 5 — Pods

Kubernetes schedules **pods** onto nodes.

Pods contain containers running your applications.

```
Laptop
  └ Docker
      └ KIND Nodes
          └ Kubernetes
              └ Pods
                  └ Containers
```

So effectively you have:

```
containers
running inside
containers
inside
Docker
```

---

# Why This Is Useful

Normally Kubernetes requires:

* multiple servers
* networking configuration
* container runtimes
* cluster bootstrapping

KIND compresses all of this into **a few Docker containers**, allowing you to spin up a cluster in seconds.

This makes it perfect for:

* local development
* experimentation
* training environments

---

# Prerequisites

Install the following tools:

### Docker

Verify installation:

```
docker version
```

### kubectl

Verify:

```
kubectl version --client
```

### KIND

Install via Homebrew (Mac):

```
brew install kind
```

Verify installation:

```
kind version
```

---

# Creating a Multi-Node Cluster

Create a configuration file.

## kind-cluster.yaml

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: desktop
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

This configuration creates:

```
1 control plane node
2 worker nodes
```

---

# Start the Cluster

Create the cluster:

```
kind create cluster --config kind-cluster.yaml
```

KIND will:

1. Pull the node image
2. Create Docker containers
3. Configure Kubernetes
4. Connect nodes into a cluster

---

# Verify Cluster

Check nodes:

```
kubectl get nodes
```

Expected output:

```
NAME                     STATUS   ROLES           AGE
desktop-control-plane    Ready    control-plane
desktop-worker           Ready    worker
desktop-worker2          Ready    worker
```

---

# Inspect the Docker Nodes

View node containers:

```
docker ps
```

Example output:

```
desktop-control-plane
desktop-worker
desktop-worker2
```

These containers represent the Kubernetes nodes.

---

# Inspect the Cluster Network

View the Docker network used by KIND:

```
docker network inspect kind
```

This network connects all nodes.

Example internal IPs:

```
172.19.0.4  desktop-control-plane
172.19.0.3  desktop-worker
172.19.0.2  desktop-worker2
```

---

# Access a Node

You can open a shell inside any node container.

Example:

```
docker exec -it desktop-control-plane bash
```

From there you can inspect Kubernetes internals.

---

# Delete the Cluster

When finished, remove the cluster:

```
kind delete cluster --name desktop
```

This deletes all node containers and networking.

---

# Quick Workflow Summary

Start cluster:

```
kind create cluster --config kind-cluster.yaml
```

Verify:

```
kubectl get nodes
```

Inspect nodes:

```
docker ps
```

Enter a node:

```
docker exec -it desktop-control-plane bash
```

Delete cluster:

```
kind delete cluster --name desktop
```

---

# What You Learned

This setup demonstrates several key concepts:

* Docker containers
* Kubernetes nodes
* Multi-node clusters
* Container networking
* Local Kubernetes environments

Most importantly:

**KIND allows Kubernetes to run on your laptop by turning Docker containers into fake servers.**

---

# Next Steps

Once the cluster is running, you can practice:

* Deploying pods
* Creating services
* Scaling deployments
* Debugging networking
* Observing container runtimes

Example:

```
kubectl run nginx --image=nginx
kubectl get pods -o wide
```

---

# Reference

KIND documentation:

https://kind.sigs.k8s.io/
