from fastapi import FastAPI

app = FastAPI(title="Project API Service")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
