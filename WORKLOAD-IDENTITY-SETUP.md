# GCP Workload Identity Setup Guide

## Overview
Workload Identity allows Kubernetes pods to authenticate to GCP services without storing service account keys.

## Setup Steps

### 1. Create GCP Service Account
```bash
PROJECT_ID="YOUR_PROJECT_ID"

gcloud iam service-accounts create devsecops-app \
  --display-name="DevSecOps Application" \
  --project=$PROJECT_ID
```

### 2. Grant GCP Permissions
```bash
# Grant permissions for application needs
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:devsecops-app@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.developer"

# Add more specific roles as needed
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:devsecops-app@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter"
```

### 3. Create Kubernetes Service Account
```bash
kubectl create serviceaccount devsecops-app -n devsecops
```

### 4. Bind Kubernetes SA to GCP SA
```bash
kubectl annotate serviceaccount devsecops-app \
  -n devsecops \
  iam.gke.io/gcp-service-account=devsecops-app@$PROJECT_ID.iam.gserviceaccount.com
```

### 5. Grant Workload Identity Binding
```bash
gcloud iam service-accounts add-iam-policy-binding \
  devsecops-app@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:$PROJECT_ID.svc.id.goog[devsecops/devsecops-app]"
```

### 6. Verify Setup
```bash
# Pod should authenticate automatically
kubectl run test-pod --image=google/cloud-sdk:slim \
  --serviceaccount=devsecops-app \
  -n devsecops \
  -- sh -c "gcloud auth list"
```

## Troubleshooting

### Pod cannot authenticate
```bash
# Check annotation
kubectl describe sa devsecops-app -n devsecops

# Check IAM binding
gcloud iam service-accounts get-iam-policy \
  devsecops-app@$PROJECT_ID.iam.gserviceaccount.com
```

### Pod events
```bash
kubectl describe pod <pod-name> -n devsecops
kubectl logs <pod-name> -n devsecops
```
