# app

A minimal sample service so the Helm chart, probes, and ServiceMonitor have
something real to run. It serves `/health`, `/ready`, `/metrics`, and `/`.

Build and run locally:

```bash
docker build -t orders-api:dev .
docker run -p 8080:8080 orders-api:dev
```

In CI, the image is built, scanned, tagged with the commit SHA, pushed to ECR,
and deployed by `.github/workflows/app-deploy.yml` (Chapter 14).
