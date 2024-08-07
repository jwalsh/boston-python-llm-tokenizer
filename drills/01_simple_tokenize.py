def simple_tokenize(text):
    return text.split()

# Read the sample text
with open("sample_text.txt", "r") as f:
    sample_text = f.read()

# Tokenize
tokens = simple_tokenize(sample_text)
print(f"First 20 tokens: {tokens[:20]}")
print(f"Total tokens: {len(tokens)}")

# Save tokens for use in next step
with open("tokens.txt", "w") as f:
    f.write("\n".join(tokens))
