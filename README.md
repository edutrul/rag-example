# RAG Example

An introductory RAG lab. The first exercise treats each of three English sentences as a chunk and turns it into a vector using the multilingual model `paraphrase-multilingual-MiniLM-L12-v2`.

## Practice PostgreSQL and pgvector from scratch

To practice SQL directly, you only need Git, Docker with Compose (Docker Desktop on macOS/Windows), and VS Code. Python is not required for this part.

On another computer, with Docker running:

```bash
git clone https://github.com/edutrul/rag-example.git
cd rag-example
docker compose up -d --wait
```

If you already have the repository, enter its folder, run `git pull --ff-only`, then `docker compose up -d --wait`.

On the first start with an empty volume, PostgreSQL creates the `rag_example` database and the `rag` user. `docker/init/01-pgvector.sql` enables the `vector` extension in that database. `docker/init/02-practice-tables.sql` also creates two practice tables in `rag_example`, seeded with sample rows:

| Table | Columns |
| --- | --- |
| `public.simple_sql_practice` | auto-incrementing `id`, `content text`; seeded with three sample rows |
| `public.simple_vector_practice` | auto-incrementing `id`, `content text`, `embedding vector(1536)`; empty |

`CREATE TABLE IF NOT EXISTS` lets the script run again without deleting existing tables, and the seed rows are inserted only if `simple_sql_practice` is empty, so re-running it does not duplicate data.

Initialization scripts run automatically only when preparing an empty volume. If the lab is already installed, after `git pull --ff-only` and `docker compose up -d --wait`, apply the script without deleting your data:

```bash
docker compose exec -T db psql -U rag -d rag_example -f /docker-entrypoint-initdb.d/02-practice-tables.sql
```

Open this folder in VS Code and install the recommended **PostgreSQL by Microsoft** extension (`ms-ossdata.vscode-pgsql`). Use a single connection named **Local PostgreSQL**, saved in **User Settings (Global)**: server `127.0.0.1`, port `55432` (under Advanced), Password authentication, user `rag`, password `rag_local`, and initial database `rag_example`. Enable **Save Password**. Create this connection once on each new computer; VS Code stores its password locally. Connection details are the same on every machine, as listed below. The project does not add Workspace connection profiles.

Under that connection, the practice tables live in `rag_example` alongside the Python exercises' `chunks` table. Open a new query against `rag_example`, select the SQL you want to run, and press **Shift+Enter**.

| Setting | Fixed value |
| --- | --- |
| Server | `127.0.0.1` |
| Host port | `55432` |
| Container port | `5432` |
| Initial database | `rag_example` |
| User | `rag` |
| Local lab password | `rag_local` |

Port `55432` is fixed in `compose.yaml`: use that same port in your VS Code connection on every computer. It must be available; if another process already uses it, Compose reports an error instead of selecting a different port. The server is published only on your computer (`127.0.0.1`).

Configuration travels through Git; Docker volume data stays on each computer. To stop the lab while keeping its data, run `docker compose down`. `docker compose down --volumes` deletes the lab data so you can start from scratch.

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

## Exercise 05: terminal RAG with local Ollama

`05-terminal-rag.py` uses your existing `rag_example` database on port `55432`
and `public.rag_chunks` table (`id`, `content`, `embedding vector(384)`). It only
reads existing rows. The table must already contain embeddings made with
`sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2`; this exercise does
not create or populate it. Exercise 03 uses a different table named `chunks`.

With PostgreSQL and Ollama already running, and `gemma3:4b` installed in Ollama:

```bash
cd ~/Projects/rag-example
.venv/bin/python -m pip install -r requirements.txt
export PGUSER=rag
export PGPASSWORD=rag_local
.venv/bin/python 05-terminal-rag.py
```

The credentials above match this local lab. Credentials come from environment
variables, not from the Python source. Optional `PGHOST`, `PGPORT`, and
`PGDATABASE` default to `localhost`, `55432`, and `rag_example`. Alternatively,
set `DATABASE_URL` with your PostgreSQL connection string; it takes precedence.
No additional Python dependencies are needed.

For each question, the terminal shows:

1. The question embedding **Q**: 384 dimensions and its first five values.
2. The top three chunks from PostgreSQL, their source IDs, and cosine similarity
   scores (`1 - distance`). SQL uses `<=>` for cosine distance and a bound vector
   parameter. Smaller distances mean closer vectors; higher similarities mean
   closer matches, not greater answer confidence.
3. The complete prompt containing the retrieved context and your question.
4. The answer from `http://localhost:11434/api/generate` using `gemma3:4b`, followed
   by source references. Citations such as `[3]` refer to `public.rag_chunks.id`.

Try `What does the dog need?`, then `What is the dog's name?`. The prompt tells
the model to use only the retrieved facts, cite its claims, and say when the
context is insufficient. This is a prompt instruction, not a guarantee: inspect
the chunks and citations to check the answer. Retrieval always returns the
nearest available chunks, even when the question is unrelated. Each question is
independent; conversation history is not sent. Press Enter on an empty question,
Ctrl+D, or Ctrl+C to exit.
