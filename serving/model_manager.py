import asyncio
from transformers import pipeline

status = "NOT_DEPLOYED"
model_id = None
generator = None


async def deploy_model(model_name: str):
    global status, generator, model_id
    status = "PENDING"
    await asyncio.sleep(2)  # simulate delay
    status = "DEPLOYING"
    await asyncio.sleep(5)  # simulate loading
    try:
        generator = pipeline("text-generation", model=model_name)
        status = "RUNNING"
        model_id = model_name
        return model_name
    except Exception as e:
        status = "NOT_DEPLOYED"
        raise e


def get_status():
    return status


def get_model_id():
    return model_id if model_id else "none"


async def infer(messages):
    global generator
    if generator is None:
        raise Exception("No model deployed")
    user_input = messages[-1]["content"]
    output = generator(user_input, max_length=50, do_sample=True)
    return [{"role": "assistant", "message": output[0]["generated_text"]}]
