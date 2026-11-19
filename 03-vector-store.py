# Goal: connect to the prepared database and retrieve text by meaning.
import json
import os

import psycopg
from sentence_transformers import SentenceTransformer

MODEL_NAME = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
# This local lab connection matches compose.yaml. Override it for another server.
DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql://rag:rag_local@localhost:55432/rag_example"
)


def main():
    try:
        connection = psycopg.connect(DATABASE_URL, autocommit=True, connect_timeout=5)
    except psycopg.OperationalError:
        raise SystemExit(
            "Could not connect to PostgreSQL. Start Docker Desktop, run "
            "'docker compose up -d --wait', and check DATABASE_URL if you set it."
        ) from None

    # Reuse one connection. Schema setup and data loading happen separately.
    with connection as conn:
        model = SentenceTransformer(MODEL_NAME)
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
            # The search SQL lives in PostgreSQL (see db/schema.sql).
            results = conn.execute(
                "SELECT * FROM retrieve_chunks(%s::vector, %s)",
                (question_vector, MODEL_NAME),
            ).fetchall()
            if not results:
                print("No saved chunks. Run scripts/load-chunks.py first.")
            print("\nRetrieved from PostgreSQL (highest similarity first):")
            for rank, (chunk_id, content, similarity) in enumerate(results, start=1):
                print(f"{rank}. [similarity {similarity:.3f}, id {chunk_id}] {content}")


if __name__ == "__main__":
    try:
        main()
    except (psycopg.errors.UndefinedTable, psycopg.errors.UndefinedFunction):
        raise SystemExit("Run the one-time database setup in README.md first.") from None
