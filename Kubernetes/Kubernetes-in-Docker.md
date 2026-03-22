## Summary

## What I Learned

## Commands

# Local Kubernetes Cluster with KIND (Kubernetes-in-Docker)

## Overview

This project demonstrates how to create a **local multi-node Kubernetes cluster** using **KIND (Kubernetes IN Docker)**. Instead of using real servers or virtual machines, KIND creates **Docker containers that simulate Kubernetes nodes**. This allows you to experiment with a real Kubernetes cluster directly on your laptop. This setup is useful for learning Kubernetes, practicing for certifications like **CKA**, testing deployments locally, and experimenting with multi-node clusters.

## Conceptual Explanation

Modern container infrastructure has several layers.

**Layer 1 — Your Computer**  
Your laptop or workstation is the base system.

Laptop

**Layer 2 — Docker**  
Docker runs containers that isolate applications.

Laptop  
└ Docker Engine  
  └ Containers

Normally, containers run applications like nginx, redis, or postgres.

**Layer 3 — KIND Nodes**  
KIND creates **Docker containers configured as Kubernetes nodes**. Each container runs Kubernetes components (kubelet, kube-proxy, container runtime), has its own network identity, and behaves like a real node in a cluster.

Example nodes created by KIND:  
desktop-control-plane  
desktop-worker  
desktop-worker2

Laptop  
└ Docker  
  └ KIND Node Containers

> Note: These containers are **purpose-built for Kubernetes**. They are not general-purpose servers and do not run a Docker daemon by default.

**Layer 4 — Kubernetes Cluster**  
Inside each node container, Kubernetes components run.

Control plane node: API server, scheduler, controller manager  
Worker nodes: kubelet, container runtime (containerd), networking

Laptop  
└ Docker  
  └ KIND Nodes  
    └ Kubernetes Cluster

**Layer 5 — Pods**  
Kubernetes schedules **pods** onto nodes. Pods contain containers running your applications.

Laptop  
└ Docker  
  └ KIND Nodes  
    └ Kubernetes  
      └ Pods  
        └ Containers

## Why This Is Useful

Normally Kubernetes requires multiple servers, networking configuration, container runtimes, and cluster bootstrapping. KIND compresses all of this into **a few Docker containers**, allowing you to spin up a cluster in seconds. This makes it perfect for local development, experimentation, and training environments.

## Prerequisites

Install the following tools:

**Docker** — Verify installation with:  
docker version

**kubectl** — Verify installation with:  
kubectl version --client

**KIND** — Install via Homebrew (Mac):  
brew install kind  
Verify installation with:  
kind version

## Creating a Multi-Node Cluster

Create a configuration file named `kind-cluster.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: desktop
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```
