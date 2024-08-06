import pytest
from boston_python_llm_tokenizer.tokenizer import Tokenizer

def test_tokenize_empty_string():
    tokenizer = Tokenizer()
    assert tokenizer.tokenize("") == []

def test_tokenize_single_word():
    tokenizer = Tokenizer()
    assert tokenizer.tokenize("hello") == ["hello"]

def test_tokenize_multiple_words():
    tokenizer = Tokenizer()
    assert tokenizer.tokenize("hello world") == ["hello", "world"]

def test_tokenize_punctuation():
    tokenizer = Tokenizer()
    assert tokenizer.tokenize("hello, world!") == ["hello", "world"]

def test_tokenize_stopwords():
    tokenizer = Tokenizer()
    assert tokenizer.tokenize("the quick brown fox") == ["quick", "brown", "fox"]