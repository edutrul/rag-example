# Objetivo: convertir las tres oraciones de un párrafo en tres embeddings.
from sentence_transformers import SentenceTransformer

# En este ejercicio, cada oración es un chunk. En un proyecto real,
# el tamaño y los límites de los chunks dependen de los documentos.
chunks = [
    "El perro es un animal doméstico.",
    "Vive con las personas.",
    "Necesita comida y agua.",
]

# Sentence Transformers permite usar un modelo multilingüe preentrenado
# que admite español y se puede ejecutar localmente.
model = SentenceTransformer("sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2")
embeddings = model.encode(chunks)

# La matriz tiene una fila por oración. Mostramos solo cinco valores de cada vector.
print(f"Forma de la matriz: {embeddings.shape}")
for chunk, vector in zip(chunks, embeddings):
    print(f"\n{chunk}")
    print(f"Primeros 5 números: {vector[:5]}")

# Ejemplo de salida. Los últimos decimales pueden variar según el equipo.
# Forma de la matriz: (3, 384)
#
# El perro es un animal doméstico.
# Primeros 5 números: [ 0.2616387  -0.22603865 -0.21553874  0.36915547  0.14774287]
#
# Vive con las personas.
# Primeros 5 números: [ 0.28743172  0.06521122 -0.15082905 -0.07429039 -0.25089025]
#
# Necesita comida y agua.
# Primeros 5 números: [ 0.07610965 -0.01227246  0.16950226  0.19492432  0.04208274]
