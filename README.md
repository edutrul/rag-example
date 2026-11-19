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

## Exercise 03: retrieval from a prepared PostgreSQL database

The database is prepared separately. `03-vector-store.py` only opens one connection, embeds each question, and calls PostgreSQL's `retrieve_chunks` function. It does not create tables or insert data. The function uses exact cosine search; approximate vector indexes are a later exercise.

### Explore in VS Code

Install **PostgreSQL** by Microsoft (`ms-ossdata.vscode-pgsql`). Open the PostgreSQL sidebar and connect to the workspace profile **RAG local**; enter `rag_local` when prompted for its password. If you need to create the connection manually, choose **Add New Connection** and use:

| Field | Value |
| --- | --- |
| Server | `localhost` |
| Port (advanced options if needed) | `55432` |
| Authentication | Password |
| User | `rag` |
| Password | `rag_local` |
| Database | `rag_example` |
| SSL | Disable (local lab only) |

Choose **Save & Connect**. Expand the database's `public` schema to explore the `chunks` table and the `retrieve_chunks` function. Open `db/explore.sql`, select this connection, and execute a selected statement with **Cmd+Shift+E** on macOS. See [Microsoft's connection guide](https://learn.microsoft.com/en-us/azure/postgresql/development/vs-code-extension/quickstart-connect-query).

`db/explore.sql` includes a cosine search using an existing sentence's vector. To search a new question in natural language, run:

```bash
.venv/bin/python 03-vector-store.py
```

Try `What does the dog need?`. Python creates the question embedding using the same model as the stored sentences. PostgreSQL compares it to the stored vectors. The `<=>` operator computes cosine distance (smaller is closer); `1 - distance` is cosine similarity (larger is closer). Similarity is not confidence. Press Enter on an empty prompt to exit.

### One-time setup for a fresh checkout

Start Docker Desktop, then run:

```bash
cd ~/Projects/rag-example
.venv/bin/python -m pip install -r requirements.txt
docker compose up -d --wait
.venv/bin/python scripts/load-chunks.py
```

Docker applies `db/schema.sql` automatically when initializing a new database volume. If you already have a volume from the previous version of exercise 03, apply the schema once without deleting your data:

```bash
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U rag -d rag_example < db/schema.sql
```

You can also execute `db/schema.sql` from the VS Code database client. The schema creates the table and search function; `scripts/load-chunks.py` loads missing sample sentences and their 384-dimensional embeddings. Rerunning the loader preserves existing rows. To add data, edit its `chunks` list and rerun the loader. Removing a sentence from the list does not delete it from the database.

### Files and persistence

- `db/schema.sql`: table definition and cosine retrieval function.
- `scripts/load-chunks.py`: separate data-loading step.
- `03-vector-store.py`: interactive retrieval against the prepared database.
- `db/explore.sql`: SQL examples for the database client.

The local credentials above are for this lab. Set `DATABASE_URL` in the Python process to connect to another prepared PostgreSQL database with pgvector. The question and stored text must use the same embedding model.

Stop PostgreSQL with `docker compose down` and restart with `docker compose up -d --wait`. The named volume keeps your data. Adding `--volumes` to the stop command **deletes the lab data**.

See the [pgvector documentation](https://github.com/pgvector/pgvector) for cosine distance and indexes.
