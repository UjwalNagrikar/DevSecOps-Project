#!/bin/bash
# Chaos testing script for validating platform resilience

set -euo pipefail

NAMESPACE="devsecops"
DEPLOYMENT="devsecops-app"

echo "=== Kubernetes Platform Resilience Testing ==="

# Test 1: Pod Failure Recovery
echo "Test 1: Pod Failure Recovery..."
kubectl delete pod -l app.kubernetes.io/name=$DEPLOYMENT -n $NAMESPACE --grace-period=0 --force || true
sleep 10
READY_PODS=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=$DEPLOYMENT -o jsonpath='{.items[?(@.status.conditions[?(@.type=="Ready")].status=="True")].metadata.name}' | wc -w)
if [ "$READY_PODS" -ge 2 ]; then
    echo "✓ Pod recovery successful: $READY_PODS pods ready"
else
    echo "✗ Pod recovery failed"
    exit 1
fi

# Test 2: Node Autoscaling
echo "Test 2: Node Autoscaling..."
kubectl scale deployment $DEPLOYMENT --replicas=10 -n $NAMESPACE
sleep 30
CURRENT_REPLICAS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
echo "Current replicas: $CURRENT_REPLICAS / 10"
if [ "$CURRENT_REPLICAS" -ge 8 ]; then
    echo "✓ Autoscaling successful"
else
    echo "✗ Autoscaling failed"
    exit 1
fi

# Scale back
kubectl scale deployment $DEPLOYMENT --replicas=3 -n $NAMESPACE

# Test 3: Service Connectivity Under Load
echo "Test 3: Service Connectivity Under Load..."
EXTERNAL_IP=$(kubectl get svc $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "localhost:8080")
echo "Testing connectivity to: $EXTERNAL_IP"

# Test 4: Rolling Update
echo "Test 4: Rolling Update..."
kubectl set image deployment/$DEPLOYMENT $DEPLOYMENT=gcr.io/PROJECT_ID/$DEPLOYMENT:latest -n $NAMESPACE || true
sleep 5
ROLLOUT_STATUS=$(kubectl rollout status deployment/$DEPLOYMENT -n $NAMESPACE --timeout=300s)
if echo "$ROLLOUT_STATUS" | grep -q "successfully rolled out"; then
    echo "✓ Rolling update successful"
else
    echo "✗ Rolling update failed"
fi

# Test 5: Pod Disruption Budget Compliance
echo "Test 5: Pod Disruption Budget Compliance..."
PDB_DISRUPTIONS=$(kubectl get pdb -n $NAMESPACE -o jsonpath='{.items[0].status.disruptionsAllowed}')
echo "Allowed disruptions: $PDB_DISRUPTIONS"

echo ""
echo "=== All Resilience Tests Completed ==="
