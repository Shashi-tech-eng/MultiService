# MultiService Helm Charts

Production-ready Kubernetes Helm charts for a multi-service application stack.

## Overview

This repository contains three individual Helm charts (`api`, `frontend`, `worker`) and an umbrella chart (`app-umbrella`) to deploy them all together.

- **api**: Node.js backend API service on port 3000
- **frontend**: Nginx web frontend on port 80
- **worker**: Node.js background worker on port 9000

## Directory Structure

```
charts/
├── api/                          # API service chart
│   ├── Chart.yaml               # Chart metadata
│   ├── values.yaml              # Default values
│   ├── values-dev.yaml          # Development overrides
│   ├── values-prod.yaml         # Production overrides
│   └── templates/
│       ├── deployment.yaml      # Kubernetes Deployment
│       ├── service.yaml         # ClusterIP Service
│       ├── ingress.yaml         # Optional Ingress
│       └── _helpers.tpl         # Template helpers
├── frontend/                     # Frontend service chart
│   └── [same structure as api]
├── worker/                       # Worker service chart
│   └── [same structure as api]
└── app-umbrella/                # Umbrella chart (all-in-one)
    ├── Chart.yaml
    └── values.yaml
```

## Prerequisites

- Kubernetes 1.19+ cluster
- Helm 3.0+
- (Optional) nginx-ingress controller for external access

## Quick Start

### Install a single chart

```bash
# Development environment
helm install api ./charts/api \
  -f ./charts/api/values-dev.yaml \
  --namespace dev \
  --create-namespace

# Production environment
helm install api ./charts/api \
  -f ./charts/api/values-prod.yaml \
  --namespace production \
  --create-namespace
```

### Install the full stack (umbrella chart)

First, update chart dependencies:

```bash
helm dependency update ./charts/app-umbrella
```

Then deploy:

```bash
# Development
helm install myapp ./charts/app-umbrella \
  -f ./charts/app-umbrella/values.yaml \
  --namespace dev \
  --create-namespace

# Production
helm install myapp ./charts/app-umbrella \
  -f ./charts/app-umbrella/values-prod.yaml \
  --namespace production \
  --create-namespace
```

## Configuration

### Values Files

Each chart has three values files:

1. **values.yaml** - Default values (base configuration)
2. **values-dev.yaml** - Development overrides (1 replica, smaller resources)
3. **values-prod.yaml** - Production overrides (3 replicas, larger resources)

### Common Customizations

#### Image Tag
Override the Docker image tag at deploy time:

```bash
helm install api ./charts/api \
  --set image.tag=v1.2.3
```

#### Replica Count
```bash
helm install api ./charts/api \
  --set replicaCount=5
```

#### Enable Ingress
```bash
helm install api ./charts/api \
  --set ingress.enabled=true \
  --set ingress.host=api.example.com
```

#### Resource Limits
```bash
helm install api ./charts/api \
  --set resources.limits.cpu=1000m \
  --set resources.limits.memory=1Gi
```

## Features

### Health Checks
All services include:
- **Liveness Probe**: Restarts unhealthy pods
- **Readiness Probe**: Removes unhealthy pods from load balancers

API (`/health` endpoint) and Frontend (`/` endpoint) checks run every 10s and 5s respectively.

### Labels and Selectors
Proper Kubernetes labels are applied for:
- Identification: `app.kubernetes.io/name`, `app.kubernetes.io/instance`
- Versioning: `app.kubernetes.io/version`
- Management: `helm.sh/chart`

### Service Discovery
Services are discoverable within the cluster:
- `api-{release}-svc:3000` (API)
- `frontend-{release}-svc:80` (Frontend)
- `worker-{release}-svc:9000` (Worker)

### Ingress Support
Frontend and API support optional ingress configuration:

```yaml
ingress:
  enabled: true
  className: nginx
  host: api.example.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
```

## Chart Management

### Lint Charts
```bash
helm lint ./charts/api
helm lint ./charts/frontend
helm lint ./charts/worker
helm lint ./charts/app-umbrella
```

### Render Templates
```bash
# Preview manifest output
helm template my-release ./charts/api
```

### Dry Run
```bash
# Test installation without applying
helm install my-release ./charts/api --dry-run --debug
```

## Publishing Charts

Charts are automatically published to GitHub Pages on every commit to `main`.

### Manual Push to Chart Registry

If using a private chart registry (e.g., ChartMuseum):

```bash
# Package charts
helm package charts/api
helm package charts/frontend
helm package charts/worker

# Push to registry
helm cm-push api-1.0.0.tgz my-registry http://chartmuseum.example.com
```

## Deployment Lifecycle

### Initial Deployment
```bash
helm install my-release ./charts/api \
  --namespace production \
  --create-namespace
```

### Upgrade
```bash
helm upgrade my-release ./charts/api \
  --namespace production \
  --set image.tag=v1.2.4
```

### Rollback
```bash
# Rollback to previous release
helm rollback my-release 1 --namespace production

# Check release history
helm history my-release --namespace production
```

### Uninstall
```bash
helm uninstall my-release --namespace production
```

## Chart Versions

- **Chart Version**: Bumped when chart structure/templates change
- **App Version**: Corresponds to Docker image tag

Current versions:
- api: v1.1.0 (app: 0.9.3)
- frontend: v1.1.0 (app: 1.0.0)
- worker: v1.0.0 (app: 1.0.0)

## GitHub Actions CI/CD

The `.github/workflows/release-charts.yml` workflow:
1. Triggers on push to `main` when charts/ directory changes
2. Packages all charts to `.tgz` files
3. Updates the Helm repository index
4. Commits and pushes to `gh-pages` branch

Charts are then available at:
```
https://shashi-tech-eng.github.io/MultiService
```

### Add Repository
```bash
helm repo add multiservice https://shashi-tech-eng.github.io/MultiService
helm repo update
helm search repo multiservice
```

## Troubleshooting

### Pod won't start
```bash
# Check pod logs
kubectl logs -n production my-release-api-xyz123

# Check events
kubectl describe pod -n production my-release-api-xyz123

# Check deployment status
kubectl describe deployment -n production my-release-api
```

### Failed liveness probe
```bash
# Check if health endpoint is working
kubectl port-forward -n production svc/my-release-api 3000:3000
curl http://localhost:3000/health
```

### Service not discoverable
```bash
# Check DNS
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -- sh
nslookup my-release-api.production.svc.cluster.local
```

## Best Practices

1. **Use separate namespaces** - One for dev, one for prod
2. **Pin image tags** - Never rely on `latest` in production
3. **Monitor resource usage** - Adjust limits based on actual consumption
4. **Use ConfigMaps** - For non-sensitive environment configuration
5. **Use Secrets** - For credentials and sensitive data
6. **Tag releases** - Use git tags to trigger chart releases
7. **Review changes** - Always dry-run before upgrading production

## License

See LICENSE file
