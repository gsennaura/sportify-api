from fastapi import FastAPI
from sportifyapi.api.controllers.country.country_controller import router as country_router

app = FastAPI(
    title="Tournament API",
    description="An API for managing tournaments",
    version="0.1.0",
)


@app.get("/")
async def root():
    return {"message": "Welcome to the Tournament API!"}

app.include_router(country_router)
