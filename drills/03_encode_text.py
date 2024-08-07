import json

def encode_text(text, vocabulary):
    return [vocabulary.get(token, 0) for token in text.split()]

# Load vocabulary
with open("vocabulary.json", "r") as f:
    vocabulary = json.load(f)

# Read sample text
with open("sample_text.txt", "r") as f:
    sample_text = f.read()

# Encode text
encoded = encode_text(sample_text, vocabulary)
print(f"First 20 encoded tokens: {encoded[:20]}")

# Save encoded text for use in next step
with open("encoded_text.json", "w") as f:
    json.dump(encoded, f)
