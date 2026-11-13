# Goal: turn the three sentences in a paragraph into three embeddings.
from sentence_transformers import SentenceTransformer

# Each sentence is one chunk. In a real project, chunk size and boundaries
# depend on the documents and what you need to retrieve.
chunks = [
    "The dog is a domesticated animal.",
    "It lives with people.",
    "It needs food and water.",
]

# Sentence Transformers loads a pretrained multilingual model that supports
# English and runs locally.
model = SentenceTransformer("sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2")
embeddings = model.encode(chunks)

# The matrix has one row per sentence. Show the first five values of each vector.
print(f"Matrix shape: {embeddings.shape}")
for chunk, vector in zip(chunks, embeddings):
    print(f"\n{chunk}")
    print(f"First 5 values: {vector[:5]}")

# Sample output. The last few decimal places may vary by device.
# Matrix shape: (3, 384)
#
# The dog is a domesticated animal.
# First 5 values: [ 0.30211163 -0.07533839 -0.1931719   0.45517015  0.16289651]
#
# It lives with people.
# First 5 values: [ 0.42303404 -0.14984863 -0.34346724 -0.17564347 -0.11899172]
#
# It needs food and water.
# First 5 values: [ 0.18603589 -0.01928201  0.18876246  0.05051531  0.20163104]
