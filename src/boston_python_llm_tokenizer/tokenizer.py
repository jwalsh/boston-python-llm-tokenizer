import re
from nltk.corpus import stopwords
import nltk

nltk.download("stopwords", quiet=True)


class Tokenizer:
    def __init__(self):
        self.stop_words = set(stopwords.words("english"))

    def tokenize(self, text):
        # Convert to lowercase and split on non-word characters
        tokens = re.findall(r"\w+", text.lower())

        # Remove stop words
        tokens = [token for token in tokens if token not in self.stop_words]

        return tokens
