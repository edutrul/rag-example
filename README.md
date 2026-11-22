# RAG Example

An introductory RAG lab. The first exercise treats each of three English sentences as a chunk and turns it into a vector using the multilingual model `paraphrase-multilingual-MiniLM-L12-v2`.

## Practicar PostgreSQL y pgvector desde cero

Para practicar SQL directamente solo necesitas Git, Docker con Compose (Docker Desktop en macOS/Windows) y VS Code. Python no es necesario para esta parte.

En otra máquina, con Docker iniciado:

```bash
git clone https://github.com/edutrul/rag-example.git
cd rag-example
docker compose up -d --wait
```

Si ya tienes el repositorio, entra en su carpeta, ejecuta `git pull --ff-only` y después `docker compose up -d --wait`.

Al iniciar con un volumen vacío, PostgreSQL crea la base `rag_example` y el usuario `rag`. El archivo `docker/init/01-pgvector.sql` activa la extensión `vector` en esa base. Además, `docker/init/02-practice-databases.sh` crea dos bases de práctica, cada una con una tabla vacía:

| Conexión de VS Code | Base | Tabla | Script SQL |
| --- | --- | --- | --- |
| Practica SQL | `practica_sql` | `public.registros`: `id` autoincremental, `nombre varchar(100)`, `fecha date`, `creado_en timestamp` | [01-practica-sql.sql](sql/01-practica-sql.sql) |
| Practica vectorial | `practica_vectorial` | `public.vectores`: una columna `embedding vector(3)` | [02-practica-vectorial.sql](sql/02-practica-vectorial.sql) |

Los scripts no insertan datos. `CREATE TABLE IF NOT EXISTS` permite volver a ejecutarlos sin borrar las tablas existentes; no modifica una tabla que ya exista con otra estructura.

Los scripts de inicialización solo se ejecutan automáticamente al preparar un volumen vacío. Si ya tenías el laboratorio, después de `git pull --ff-only` y `docker compose up -d --wait`, crea las bases y aplica los dos scripts sin borrar tus datos:

```bash
docker compose exec -T db bash /docker-entrypoint-initdb.d/02-practice-databases.sh
```

Abre esta carpeta en VS Code e instala la extensión recomendada **PostgreSQL by Microsoft** (`ms-ossdata.vscode-pgsql`). Los perfiles del grupo **Laboratorio local** se incluyen en `.vscode/settings.json` con **Save Password** activado. La contraseña fija del laboratorio es `rag_local`: en una computadora nueva introdúcela y guárdala la primera vez que conectes cada perfil. VS Code la conserva en su almacén de credenciales para no pedirla en las siguientes conexiones. La configuración viaja por Git; las credenciales guardadas son locales a cada computadora. Si los perfiles no aparecen al actualizar, ejecuta **Developer: Reload Window** desde la paleta de comandos.

Abre cada script con su conexión correspondiente. Para practicar consultas, abre un archivo SQL vacío, conecta a **Practica SQL** o **Practica vectorial**, selecciona el SQL que quieras ejecutar y pulsa **Shift+Enter**. La conexión **RAG Example (proyecto)** sigue disponible para los ejercicios Python.

| Dato | Valor fijo |
| --- | --- |
| Servidor | `127.0.0.1` |
| Puerto de tu computadora | `55432` |
| Puerto dentro del contenedor | `5432` |
| Base | `rag_example` |
| Usuario | `rag` |
| Contraseña del laboratorio local | `rag_local` |

El puerto `55432` está fijado en `compose.yaml` y en el perfil de VS Code: no cambia entre arranques ni entre máquinas. Debe estar libre; si ya lo usa otro proceso, Compose mostrará un error en vez de elegir un puerto diferente. El servidor se publica solo en tu computadora (`127.0.0.1`).

La configuración viaja por Git; los datos del volumen Docker se quedan en cada máquina. Para detener el laboratorio sin perder sus datos, ejecuta `docker compose down`. `docker compose down --volumes` elimina los datos del laboratorio y permite volver a empezar desde cero.

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
