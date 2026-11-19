# One-time data loading, separate from the retrieval exercise.
import json
import os

import psycopg
from sentence_transformers import SentenceTransformer

MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql://rag:rag_local@localhost:55432/rag_example"
)
chunks = [
    "The dog is a domesticated animal.",
    "The dog lives with people.",
    "The dog needs food and water.",
]

with psycopg.connect(DATABASE_URL) as conn:
    saved = {
        row[0] for row in conn.execute(
            "SELECT content FROM chunks WHERE model_name = %s", (MODEL_NAME,)
        )
    }
    missing = [chunk for chunk in chunks if chunk not in saved]
    if missing:
        model = SentenceTransformer(MODEL_NAME)
        for chunk, embedding in zip(missing, model.encode(missing)):
            conn.execute(
                """INSERT INTO chunks (content, model_name, embedding)
                   VALUES (%s, %s, %s::vector)
                   ON CONFLICT (model_name, content) DO NOTHING""",
                (chunk, MODEL_NAME, json.dumps(embedding.tolist())),
            )
        print(f"Prepared {len(missing)} new chunks.")
    else:
        print("The sample chunks are already saved. Nothing to load.")
