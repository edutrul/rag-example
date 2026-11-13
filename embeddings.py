from sentence_transformers import SentenceTransformer

chunks = [
    "El perro es un animal doméstico.",
    "Vive con las personas.",
    "Necesita comida y agua.",
]

model = SentenceTransformer(
    "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2",
    device="cpu",
)
embeddings = model.encode(chunks)

print(f"Forma de la matriz: {embeddings.shape}")
for chunk, vector in zip(chunks, embeddings):
    print(f"\n{chunk}")
    print(f"Primeros 5 números: {vector[:5]}")
