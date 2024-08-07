import json

def decode_text(encoded_text, vocabulary):
    rev_vocab = {v: k for k, v in vocabulary.items()}
    return [rev_vocab.get(code, "<UNK>") for code in encoded_text]

# Load vocabulary
with open("vocabulary.json", "r") as f:
    vocabulary = json.load(f)

# Load encoded text
with open("encoded_text.json", "r") as f:
    encoded_text = json.load(f)

# Decode text
decoded = decode_text(encoded_text, vocabulary)
print(f"First 20 decoded tokens: {decoded[:20]}")

# Compare with original
with open("sample_text.txt", "r") as f:
    original = f.read().split()[:20]
print(f"First 20 original tokens: {original}")
