# Goal: persist embeddings in PostgreSQL and retrieve them with SQL.
import json
import os

import psycopg
from sentence_transformers import SentenceTransformer

MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
# This local lab connection matches compose.yaml. Override it for another server.
DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql://rag:rag_local@localhost:55432/rag_example"
)
chunks = [
    "The dog is a domesticated animal.",
    "The dog lives with people.",
    "The dog needs food and water.",
]


def main():
    try:
        connection = psycopg.connect(DATABASE_URL, autocommit=True, connect_timeout=5)
    except psycopg.OperationalError:
        raise SystemExit(
            "Could not connect to PostgreSQL. Start Docker Desktop, run "
            "'docker compose up -d --wait', and check DATABASE_URL if you set it."
        ) from None

    with connection as conn:
        with conn.transaction():
            conn.execute("CREATE EXTENSION IF NOT EXISTS vector")
            # The model produces 384 numbers per embedding. Keep its name so
            # searches never mix embeddings from different models.
            conn.execute("""
                CREATE TABLE IF NOT EXISTS chunks (
                    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    content text NOT NULL,
                    model_name text NOT NULL,
                    embedding vector(384) NOT NULL,
                    UNIQUE (model_name, content)
                )
            """)

        model = SentenceTransformer(MODEL_NAME)
        saved_texts = {
            row[0]
            for row in conn.execute(
                "SELECT content FROM chunks WHERE model_name = %s", (MODEL_NAME,)
            )
        }
        missing_chunks = [chunk for chunk in chunks if chunk not in saved_texts]
        if missing_chunks:
            embeddings = model.encode(missing_chunks)
            with conn.transaction():
                for chunk, embedding in zip(missing_chunks, embeddings):
                    # Pass values as SQL parameters. JSON supplies pgvector's
                    # textual format: [number, number, ...].
                    conn.execute(
                        """
                        INSERT INTO chunks (content, model_name, embedding)
                        VALUES (%s, %s, %s::vector)
                        ON CONFLICT (model_name, content) DO NOTHING
                        """,
                        (chunk, MODEL_NAME, json.dumps(embedding.tolist())),
                    )
            print(f"Embedded and saved {len(missing_chunks)} new chunks.")
        else:
            print("Reusing saved chunks; their embeddings were not recalculated.")

        count = conn.execute(
            "SELECT count(*) FROM chunks WHERE model_name = %s", (MODEL_NAME,)
        ).fetchone()[0]
        print(f"Stored chunks for this model: {count}")
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

            # Only the new question needs an embedding on each search.
            question_vector = json.dumps(model.encode(question).tolist())
            # <=> is cosine distance: smaller is closer. PostgreSQL performs
            # exact search here; no approximate vector index has been created.
            results = conn.execute(
                """
                SELECT id, content, embedding <=> %s::vector AS distance
                FROM chunks
                WHERE model_name = %s
                ORDER BY distance, id
                LIMIT 3
                """,
                (question_vector, MODEL_NAME),
            ).fetchall()
            print("\nRetrieved from PostgreSQL (highest similarity first):")
            for rank, (chunk_id, content, distance) in enumerate(results, start=1):
                # Convert cosine distance to cosine similarity, as in exercise 02.
                print(f"{rank}. [similarity {1 - distance:.3f}, id {chunk_id}] {content}")


if __name__ == "__main__":
    main()
