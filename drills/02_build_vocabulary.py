from collections import Counter

def build_vocabulary(tokens, max_vocab_size=1000):
    return dict(Counter(tokens).most_common(max_vocab_size))

# Read tokens from file
with open("tokens.txt", "r") as f:
    tokens = f.read().split()

# Build vocabulary
vocab = build_vocabulary(tokens, max_vocab_size=100)
print(f"Vocabulary size: {len(vocab)}")
print(f"Top 10 words: {list(vocab.items())[:10]}")

# Save vocabulary for use in next step
import json
with open("vocabulary.json", "w") as f:
    json.dump(vocab, f)
