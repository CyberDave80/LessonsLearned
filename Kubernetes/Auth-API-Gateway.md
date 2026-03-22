
## Summary
This project implements a secure, scalable, cloud-native API architecture. The system uses a Kubernetes Gateway (NGINX) as the single public entry point to handle TLS termination and initial routing. Traffic is then passed to an API Gateway (KrakenD), which acts as a security enforcer by validating JSON Web Tokens (JWTs) before allowing access to protected resources. A dedicated Identity Provider (built with Django) handles user authentication and issues these JWTs using RS256 asymmetric cryptography. Finally, successfully authenticated requests are routed to a stateless Core Application Service, which remains completely isolated from the complexities of user authentication.

### 1. Ingress & Gateway Layer
* **Technology:** NGINX Gateway Fabric, Cert-Manager, Let's Encrypt.
* **Role:** Acts as the cluster's front door. It exposes a single public IP address, automatically provisions and manages SSL/TLS certificates for secure HTTPS connections, and uses `HTTPRoute` resources to direct traffic to internal services (KrakenD or Django) based on URL paths.

### 2. API Gateway Layer (KrakenD)
* **Technology:** KrakenD.
* **Role:** Serves as the security checkpoint and reverse proxy. It intercepts requests destined for the Core Application Service and locally validates the provided JWT using a public key (JWKS) mounted as a Kubernetes Secret. If the token is missing or invalid, KrakenD drops the request; if valid, it forwards the traffic to the backend.

### 3. Identity Provider (Django Authentication)
* **Technology:** Django, Django REST Framework, SimpleJWT.
* **Role:** Manages user state and issues access credentials. When a user logs in, Django generates a JWT signed with a private RSA key. It embeds a Key ID (`kid`) in the token header so the API Gateway knows which public key to use for validation.

### 4. Core Application Service
* **Technology:** Generic stateless backend (e.g., Python/FastAPI).
* **Role:** Houses the actual business logic. Because KrakenD guarantees that only authenticated traffic reaches this service, the application code remains 100% stateless and oblivious to user management, making it highly scalable and easy to maintain.

---

## What I Learned
* **Decoupling Authentication:** Separating the Identity Provider (stateful) from the Core Application Service (stateless) prevents monolithic design and allows the backend to scale effortlessly.
* **Asymmetric Cryptography (RS256):** Using a private key to sign tokens (Django) and a public key to verify them (KrakenD) creates a zero-trust architecture. Even if the API Gateway is compromised, attackers cannot forge new access tokens.
* **Local Token Validation:** By exposing the public key in a JSON Web Key Set (JWKS) format and mounting it directly into the KrakenD pod, the API Gateway can validate tokens instantly without making network calls to the Identity Provider.
* **Configuration as Code:** Managing sensitive data (RSA keys) via Kubernetes Secrets and routing logic via ConfigMaps ensures that infrastructure deployments remain secure, declarative, and container-agnostic.

---

## Commands

**1. Generating Asymmetric RSA Keys**
```bash
# Generate a 2048-bit RSA Private Key
openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048

# Extract the corresponding Public Key
openssl rsa -pubout -in private_key.pem -out public_key.pem
```
**2. Kubernetes Secret & Config Management**
```bash
# Create a secret for the Identity Provider (Django) to access the raw PEM files
kubectl create secret generic loginkeys --from-file=./private_key.pem --from-file=./public_key.pem

# Base64 encode the JWKS JSON file to store it as a Kubernetes Secret for the API Gateway (KrakenD)
base64 -w 0 jwk.json

# Generate a ConfigMap from the validated KrakenD configuration
kubectl create configmap krakend-cfg --from-file=./krakend.json
```
**3. API Gateway (KrakenD) Diagnostics**
```bash
# Validate the syntax of the KrakenD configuration file before deploying
krakend validate --config krakend.json

# Audit the KrakenD configuration for security recommendations
krakend audit --config krakend.json
```

**4. Identity Provider (Django) Initialization**
```
# Initialize the Django project and authentication app
poetry run django-admin startproject myproject .
poetry run django-admin startapp login

# Run database migrations and create an admin user
poetry run python manage.py migrate
poetry run python manage.py createsuperuser
```
