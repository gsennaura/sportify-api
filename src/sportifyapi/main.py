from fastapi import FastAPI

app = FastAPI(
    title="Tournament API",
    description="An API for managing tournaments",
    version="0.1.0"
)


@app.get("/")
async def root():
    return {"message": "Welcome to the Tournament API!"}
