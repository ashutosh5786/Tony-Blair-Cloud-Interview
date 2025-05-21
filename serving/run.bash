uvicorn main:app --reload


## we cam run test service with

curl -X POST http://localhost:8000/model -H "Content-Type: application/json" \
  -d '{"model_id": "gpt2"}'

curl -X POST http://localhost:8000/completion -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "Hello"}]}'
