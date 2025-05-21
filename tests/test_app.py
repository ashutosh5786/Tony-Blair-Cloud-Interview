from fastapi.testclient import TestClient
from serving.app import app
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))


client = TestClient(app)
client = TestClient(app)


def test_get_status_initial():
    response = client.get("/status")
    assert response.status_code == 200
    assert response.json()["status"] == "NOT_DEPLOYED"


def test_get_model_initial():
    response = client.get("/model")
    assert response.status_code == 200
    assert response.json()["model_id"] is None


def test_post_model_deployment():
    response = client.post("/model", json={"model_id": "gpt2"})
    assert response.status_code == 200
    assert response.json()["status"] == "success"
    assert response.json()["model_id"] == "gpt2"


def test_post_completion_before_model_ready():
    response = client.post(
        "/completion", json={"messages": [{"role": "user", "content": "Hello"}]})
    # Since model takes time to load in background, it might still not be ready
    assert response.status_code == 200
    body = response.json()
    assert body["status"] in ["error", "success"]


def test_post_model_invalid_payload():
    response = client.post("/model", json={})
    assert response.status_code == 422
