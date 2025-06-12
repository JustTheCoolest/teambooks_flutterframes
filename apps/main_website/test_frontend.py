import requests

API_URL = "http://localhost:8000/upload/"  # Change if running on a different host
IMAGE_PATH = "assets/volunteer_image.jpg"  # Replace with the actual image file path

def upload_image(image_path):
    """Uploads an image to the FastAPI server and prints the response."""
    with open(image_path, "rb") as file:
        files = {"file": file}
        response = requests.post(API_URL, files=files)
        
    if response.status_code == 200:
        data = response.json()
        print("Extracted Text:", data.get("extracted_text", "N/A"))
        print("Book Details:", data.get("book_details", "N/A"))
    else:
        print("Error:", response.status_code, response.text)

if __name__ == "__main__":
    upload_image(IMAGE_PATH)
