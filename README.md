# RAG Example

An introductory RAG lab. The first exercise treats each of three English sentences as a chunk and turns it into a vector using the multilingual model `paraphrase-multilingual-MiniLM-L12-v2`.

## Run on macOS

Open the repository folder in VS Code with Microsoft's **Python** extension installed. Run these commands in the integrated terminal. The lab was tested with Python 3.14.

```bash
python3 --version
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python 01-embeddings.py
```

You can also open `01-embeddings.py` and click **▶ Run Python File**. If VS Code asks for an interpreter, use **Python: Select Interpreter** and choose `.venv/bin/python`.

The first run downloads the model. Embeddings are computed locally. The output shows `Matrix shape: (3, 384)` and the first five values of each vector.

## Exercise 02: semantic retrieval

In VS Code, open **Terminal → New Terminal** and run:

```bash
cd ~/Projects/rag-example
.venv/bin/python 02-retrieval.py
```

Type a question such as `What does the dog need?` and press Enter. The script embeds your question and ranks three sentences by cosine similarity. It uses the facts from exercise 01, with `the dog` replacing `it` so each chunk has its own context. For this question, `The dog needs food and water.` should rank first.

Try another question, such as `Who does it live with?`. Press Enter on an empty question to exit. You can also open `02-retrieval.py` and click **▶ Run Python File** using the `.venv/bin/python` interpreter.

Higher scores mean greater similarity, not answer confidence. The script always ranks the available sentences, even for unrelated questions. This is the retrieval step: it returns existing text without generating an answer. Edit `chunks` to experiment with your own sentences, then save and rerun the script. No additional dependencies or API key are needed.

## Exercise 03: persistent vector storage with PostgreSQL

This exercise stores text, model names, and 384-dimensional embeddings in PostgreSQL with the **pgvector** extension. Python embeds your question; PostgreSQL ranks the stored vectors using cosine distance. There is no approximate vector index yet, so this is exact search. The primary key and uniqueness constraint create ordinary indexes for data integrity, not vector similarity search.

Start **Docker Desktop**, then run these commands in the VS Code terminal:

```bash
cd ~/Projects/rag-example
.venv/bin/python -m pip install -r requirements.txt
docker compose up -d --wait
.venv/bin/python 03-vector-store.py
```

The first run saves three chunks. Ask `What does the dog need?`, then press Enter on an empty prompt to exit. Run the script again: it reports that it is reusing saved chunks, without recalculating their embeddings. The model still loads to embed new questions.

To verify that the database persists across restarts:

```bash
docker compose down
docker compose up -d --wait
.venv/bin/python 03-vector-store.py
```

Docker stores the database in a named volume that survives `docker compose down`. Stop the database with `docker compose down` when finished. Adding `--volumes` to that command **deletes the lab data**.

Inspect the saved text and vector dimensions directly:

```bash
docker compose exec db psql -U rag -d rag_example -c "SELECT id, content, vector_dims(embedding) AS dimensions FROM chunks;"
```

The example database is bound to your computer at `localhost:55432`; its published username/password (`rag` / `rag_local`) are for this local lab. Set `DATABASE_URL` to use another PostgreSQL server with pgvector installed and permission to enable the extension. Use the same embedding model for stored texts and questions.

You can add sentences to `chunks` and rerun: only missing sentences are embedded and inserted. Previously saved sentences stay in the database even if removed from the Python list. Similarity scores are not confidence, and unrelated questions still return the nearest available chunks.

Next, with a larger dataset, we can add an HNSW index and compare approximate retrieval against this exact search. See the [pgvector documentation](https://github.com/pgvector/pgvector) for vector storage, cosine distance, and indexes.
