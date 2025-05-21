from fastapi import FastAPI, Request, BackgroundTasks
from pydantic import BaseModel
from transformers import pipeline
from threading import Lock
import time
from prometheus_client import Counter, Gauge, generate_latest, CONTENT_TYPE_LATEST


app = FastAPI()

# Status: NOT_DEPLOYED | PENDING | DEPLOYING | RUNNING
status = {"state": "NOT_DEPLOYED", "model_id": None}
lock = Lock()
model_pipeline = None


class ChatRequest(BaseModel):
    messages: list[dict]


class ModelRequest(BaseModel):
    model_id: str


@app.get("/status")
def get_status():
    return {"status": status["state"]}


REQUEST_COUNT = Counter("app_requests_total",
                        "Total number of /completion requests")
MODEL_LOAD_TIME = Gauge("model_load_duration_seconds",
                        "Model load duration in seconds")


def load_model(model_id: str):
    global model_pipeline
    try:
        with lock:
            status["state"] = "DEPLOYING"
            start = time.time()
            model_pipeline = pipeline("text-generation", model=model_id)
            duration = time.time() - start
            MODEL_LOAD_TIME.set(duration)
            status["state"] = "RUNNING"
            status["model_id"] = model_id
    except Exception as e:
        status["state"] = "NOT_DEPLOYED"
        status["model_id"] = None


@app.get("/model")
def get_model():
    return {"model_id": status["model_id"]}


def load_model(model_id: str):
    global model_pipeline
    try:
        with lock:
            status["state"] = "DEPLOYING"
            time.sleep(1)  # simulate load
            model_pipeline = pipeline("text-generation", model=model_id)
            status["state"] = "RUNNING"
            status["model_id"] = model_id
    except Exception as e:
        status["state"] = "NOT_DEPLOYED"
        status["model_id"] = None
        print(f"Error loading model: {e}")


@app.post("/model")
def post_model(body: ModelRequest, background_tasks: BackgroundTasks):
    if status["state"] in ["DEPLOYING", "PENDING"]:
        return {"status": "error", "message": "Model is already being deployed"}
    status["state"] = "PENDING"
    background_tasks.add_task(load_model, body.model_id)
    return {"status": "success", "model_id": body.model_id}


@app.post("/completion")
def post_completion(body: ChatRequest):
    if status["state"] != "RUNNING" or model_pipeline is None:
        return {"status": "error", "message": "Model is not running"}

    user_msg = body.messages[-1]["content"]
    try:
        result = model_pipeline(user_msg, max_length=50,
                                num_return_sequences=1)
        reply = result[0]["generated_text"]
        return {"status": "success", "response": [{"role": "assistant", "message": reply}]}
    except Exception as e:
        return {"status": "error", "message": str(e)}
