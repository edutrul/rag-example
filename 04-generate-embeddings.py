
from sentence_transformers import SentenceTransformer

chunks = [
    "The dog is a domesticated animal.",
    "The dog lives with people.",
    "The dog needs food and water.",
]

model = SentenceTransformer(
    "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
)

for i, chunk in enumerate(chunks, start=1):
    embedding = model.encode(chunk)

    print(f"\n========== FILA {i} ==========")
    print(f"CONTENT:\n{chunk}")
    print(f"\nEMBEDDING ({len(embedding)} dimensiones):")
    print("[" + ",".join(map(str, embedding.tolist())) + "]")



print("===================================================================")
print("===================================================================")

question = "What does the dog need?"
query_embedding = model.encode(question)

print("[" + ",".join(map(str, query_embedding.tolist())) + "]")
