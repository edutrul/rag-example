# RAG Example

Laboratorio inicial de RAG en español. El script toma tres oraciones, usa cada una como un fragmento y la convierte en un vector con el modelo multilingüe `paraphrase-multilingual-MiniLM-L12-v2`.

## Ejecutar en macOS

Abre la carpeta del repositorio en VS Code con la extensión **Python** de Microsoft. Desde la terminal integrada, ejecuta estos comandos. El laboratorio se probó con Python 3.14.

```bash
python3 --version
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python embeddings.py
```

También puedes abrir `embeddings.py` y pulsar **▶ Run Python File**. Si VS Code te pide un intérprete, usa **Python: Select Interpreter** y elige `.venv/bin/python`.

La primera ejecución descarga el modelo. El cálculo se hace localmente en CPU. La salida muestra `Forma de la matriz: (3, 384)` y los primeros cinco valores de cada vector.
