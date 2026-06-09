# k8s

Cluster security and observability manifests from Chapters 10 and 13:

- `namespace.yaml` - the production namespace with Pod Security Standards (restricted) enforced
- `rbac.yaml` - a least-privilege read-only Role and binding
- `network-policies.yaml` - default-deny ingress plus an explicit allow for the app
- `external-secret.yaml` - SecretStore and ExternalSecret pulling from AWS Secrets Manager
- `servicemonitor.yaml` - Prometheus scrape config for the app

Apply the namespace first, then the rest:

```bash
kubectl apply -f namespace.yaml
kubectl apply -f rbac.yaml -f network-policies.yaml -f external-secret.yaml -f servicemonitor.yaml
```
