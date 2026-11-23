# Goal: retrieve the sentence closest in meaning to a question.
from sentence_transformers import SentenceTransformer

# Keep the facts from exercise 01, but make each chunk self-contained:
# repeating "the dog" avoids losing context when a sentence is retrieved alone.
chunks = [
    "The dog is a domesticated animal.",
    "The dog lives with people.",
    "The dog needs food and water.",
]

model = SentenceTransformer("sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2")
# Encode the chunks once; reuse their vectors for every question.
embeddings = model.encode(chunks)

print("Semantic retrieval: search the three sentences by meaning.")
print("Try: What does the dog need?")
print("Press Enter without a question to exit.")

while True:
    try:
        question = input("\nYour question: ").strip()
    except (EOFError, KeyboardInterrupt):
        print("\nGoodbye!")
        break
    if not question:
        break

    # Embed the question in the same vector space as the chunks.
    question_embedding = model.encode(question)
    # Cosine similarity compares vector direction. Higher means more similar;
    # the score is not a probability or a guarantee that the answer is present.
    scores = model.similarity(question_embedding, embeddings)[0]
    ranked_indices = scores.argsort(descending=True).tolist()

    print("\nRetrieved sentences (highest similarity first):")
    for rank, index in enumerate(ranked_indices, start=1):
        print(f"{rank}. [{scores[index].item():.3f}] {chunks[index]}")

# This exercise retrieves existing text. It does not generate an answer.
