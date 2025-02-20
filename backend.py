from fastapi import FastAPI, File, UploadFile
from paddleocr import PaddleOCR
import uvicorn
import shutil
import os
from google import genai
from fastapi.middleware.cors import CORSMiddleware

origins = [
    "http://localhost",
    "https://localhost",
    "http://localhost:8080",
]

# Task: Function calling
# https://ai.google.dev/gemini-api/docs/function-calling/tutorial?lang=python#generate-function-call

GEMINI_API_KEY = open(".key").read().strip()

client = genai.Client(api_key=GEMINI_API_KEY)

app = FastAPI()
ocr = PaddleOCR(use_angle_cls=True, lang="en")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def process_image(file: UploadFile):
    """Handles image saving, OCR processing, and cleanup. PADDLEOCR"""
    file_location = f"temp_{file.filename}"
    with open(file_location, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    result = ocr.ocr(file_location, cls=True)
    os.remove(file_location)  # Cleanup file
    
    extracted_text = " ".join([word[1][0] for line in result for word in line])
    return extracted_text

def get_book_details(text: str):
    prompt = f"Extract the book details from the following text: {text}"
    response = client.models.generate_content(
        model='gemini-2.0-flash',
        contents=prompt
    )

    candidate = response.candidates[0]
    print(candidate)
    # Extract the text from the parts list
    parts = candidate.content.parts
    book_details = " ".join([part.text for part in parts if part.text])
    
    return book_details if book_details else "No details found."

@app.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    extracted_text = process_image(file)
    book_details = get_book_details(extracted_text)
    return {"extracted_text": extracted_text, "book_details": book_details}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)