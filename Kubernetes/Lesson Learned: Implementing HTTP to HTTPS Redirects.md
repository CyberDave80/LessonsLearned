# Summary: Authentication & API Gateway

## What I Learned

### 1. Gateway API vs. Ingress

I learned that the **Gateway API** is the modern successor to Ingress. It provides a more modular way to manage traffic by separating the infrastructure (Gateway) from the application routing (HTTPRoute). This allows for cleaner management of shared resources like load balancer IPs and SSL certificates.

### 2. Debugging "503 Service Unavailable"

A critical lesson was troubleshooting 503 errors. I discovered that even if a Gateway is "Ready," it returns a 503 if the Service has no **Endpoints**. This usually happens because of a **Label Mismatch**: the `selector` in the `service.yaml` must exactly match the `labels` in the `deployment.yaml`.

### 3. Automated SSL with cert-manager

I implemented automated HTTPS using **cert-manager** and **Let's Encrypt**. I learned how a `ClusterIssuer` acts as a global certificate authority for the cluster and how annotations in the Gateway resource trigger the automated issuance and renewal of SSL certificates.

### 4. HTTP-to-HTTPS Redirects

Instead of simply deleting Port 80, I learned to implement a **RequestRedirect Filter**. This ensures that any user trying to access the site via `http://` is automatically "bounced" to the secure `https://` version with a **301 Moved Permanently** status code.

---

## Commands

### Cluster Management

- `kubectl get nodes` — Check node status and health.
- `kubectl get pods --show-labels` — Check pod status and verify label configurations.
- `kubectl delete service <name>` — Remove old LoadBalancer services to enforce Gateway-only traffic.

### Gateway API Operations

- `kubectl get gateway` — Retrieve the public IP of the NGINX Gateway.
- `kubectl describe httproute <name>` — Check the status of routing rules and backend connectivity.
- `kubectl get clusterissuer` — Verify the status of the Let's Encrypt production issuer.

### SSL & Troubleshooting

- `kubectl get certificate` — Check if the SSL certificate has been issued and is "Ready."
- `kubectl describe challenge` — The primary tool for debugging stuck SSL certificates (DNS or Port 80 issues).
- `curl -I http://<domain>` — Inspect headers to verify that the 301 redirect is functioning.

## Before changing these documents (gateway.yml and route.yaml) request a certificate and configure an issuer.yaml file

### issuer.yaml

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-production
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
      - http01:
          gatewayHTTPRoute:
            parentRefs:
              - name: prod-gateway
                namespace: default
```

### gateway.yaml

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: prod-gateway
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-production
spec:
  gatewayClassName: nginx
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      hostname: "app.example.com"
    - name: https
      port: 443
      protocol: HTTPS
      hostname: "app.example.com"
      tls:
        mode: Terminate
        certificateRefs:
          - name: app-tls-cert
```

### route.yaml

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-app-route
spec:
  hostnames:
    - "app.example.com"
  parentRefs:
    - name: prod-gateway
  rules:
    # Enforce HTTPS via Redirect
    - filters:
        - type: RequestRedirect
          requestRedirect:
            scheme: https
            statusCode: 301
    # Route to Backend Service
    - backendRefs:
        - name: web-app-service
          port: 80
```
