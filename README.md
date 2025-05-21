# 🧠 ML Serving Infrastructure — Technical Test Submission

This project implements a complete, production-ready infrastructure and serving pipeline for deploying a Hugging Face machine learning model using FastAPI, Terraform, EKS, Prometheus, Grafana, and GitHub Actions.

---

## ✅ Functional Requirements Covered

- [x] Infrastructure as code (Terraform for AWS EKS)
- [x] CI/CD pipeline with GitHub Actions (unit test, Docker build, K8s deploy)
- [x] Monitoring dashboard with Prometheus + Grafana
- [x] API Endpoints for model management and inference
- [x] Deployment support for both **AWS EKS** and **Minikube/local**
- [x] Unit tests and modular run scripts per folder

---

## 📁 Project Structure

```
ml-serving-app/
├── iac/                    # Terraform code for provisioning EKS
│   └── run.sh              # One-click infra provisioning
├── serving/                # FastAPI model server + Dockerfile
│   └── run.sh              # Build and optionally run locally
├── tests/                  # Unit tests using pytest
│   └── run.sh              # Run tests
├── k8s/                    # Kubernetes manifests for the app
│   └── run.sh              # Deploy to K8s and port-forward
├── monitoring/             # Helm install + Grafana dashboard JSON
│   ├── grafana-dashboards/
│   │   └── ml-serving-dashboard.json
│   └── run.sh
└── .github/workflows/ci-cd.yaml  # GitHub Actions pipeline
```

---

## ⚙️ Prerequisites

Ensure the following tools are installed:

- `Terraform` >= 1.4
- `AWS CLI` configured with EKS permissions
- `kubectl`
- `helm`
- `docker`
- `python3` and `pip` (for testing)
- (Optional) `minikube` if testing locally

---

## 🚀 How to Run Each Component

### 🛠️ 1. Provision Infrastructure

```bash
cd iac
./run.sh
```

> This uses Terraform to deploy EKS and optionally updates kubeconfig.

---

### 📊 2. Install Monitoring Stack

```bash
cd monitoring
./run.sh
```

> Installs Prometheus and Grafana via `kube-prometheus-stack`. Also includes a dashboard JSON in `grafana-dashboards/`.

---

### 🐳 3. Build and (Optionally) Run the App Locally

```bash
cd serving
./run.sh
```

> Builds Docker image and optionally starts the container on port 8000.

---

### ☸️ 4. Deploy App to Kubernetes

```bash
cd k8s
./run.sh
```

> Applies Kubernetes manifests and optionally port-forwards the app.

---

### 🧪 5. Run Tests

```bash
cd tests
./run.sh
```

---

## 🌐 API Endpoints

| Endpoint         | Method | Description                          |
|------------------|--------|--------------------------------------|
| `/model`         | GET    | Get current model ID                 |
| `/model`         | POST   | Deploy new Hugging Face model        |
| `/status`        | GET    | Get model deployment status          |
| `/completion`    | POST   | Run inference using deployed model   |

Example request:

```json
POST /model
{ "model_id": "gpt2" }
```

```json
POST /completion
{
  "messages": [
    { "role": "user", "content": "Tell me a joke" }
  ]
}
```

---

## 📊 Monitoring Dashboard

Included in: `monitoring/grafana-dashboards/ml-serving-dashboard.json`

It shows:

- Node CPU / Memory
- Requests per second
- Model load latency (p95 tracking)
- (Optional) log panel if Loki is configured

---

## 🚨 Notes

- Logs are written to stdout (can be scraped by Loki if configured)
- Terraform uses the `terraform-aws-eks` and `vpc` modules
- Docker image uses `uvicorn` + `FastAPI` + `transformers` for inference
- Requests are tracked using `prometheus_client`

---

## ✅ Submission Summary

This project delivers a cloud-native ML serving platform meeting all specified requirements. It is modular, testable, observable, and reproducible.