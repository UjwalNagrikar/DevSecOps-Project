# Quick Start Guide - DevSecOps Platform

## Prerequisites
```bash
# Install required tools
gcloud init
terraform --version  # >= 1.0
kubectl version --client
helm version
git clone https://github.com/YOUR_ORG/DevSecOps-Project.git
cd DevSecOps-Project
```

## 5-Minute Quick Start

### 1. Setup GCP Infrastructure
```bash
cd Infrasture_code
cat > terraform.tfvars <<EOF
project_id = "YOUR_PROJECT_ID"
region     = "us-central1"
EOF

terraform init
terraform apply -auto-approve
```

### 2. Connect to Cluster
```bash
gcloud container clusters get-credentials devsecops-gke-cluster \
  --region us-central1 \
  --project YOUR_PROJECT_ID
```

### 3. Deploy Application
```bash
helm upgrade --install devsecops-app ./helm/devsecops-app \
  --namespace devsecops \
  --create-namespace
```

### 4. Setup ArgoCD
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd \
  --namespace argocd --create-namespace
kubectl apply -f argocd/applications.yaml
```

### 5. Install Istio
```bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-*/
./bin/istioctl install --set profile=production -y
kubectl apply -f ../K8s_manifesto/istio/istio-config.yaml
```

## Verification

```bash
# Check cluster
kubectl get nodes
kubectl get pods -n devsecops

# Check GitOps
kubectl get applications -n argocd

# Check service mesh
kubectl get virtualservices -n devsecops
```

## Next Steps
- Configure GitHub Actions secrets
- Push code to trigger CI/CD
- Monitor deployments via ArgoCD dashboard
- View metrics in Grafana

See [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) for full documentation.
