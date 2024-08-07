import requests

def fetch_gutenberg_text(url):
    response = requests.get(url)
    return response.text

# Fetch the text
url = "https://www.gutenberg.org/files/1342/1342-0.txt"  # Pride and Prejudice
text = fetch_gutenberg_text(url)
print(f"Fetched {len(text)} characters from Project Gutenberg")

# Save a sample of the text for use in other scripts
sample_text = text[:100000]  # First 100000 characters
with open("sample_text.txt", "w") as f:
    f.write(sample_text)

print("Saved first 100000 characters to sample_text.txt")
