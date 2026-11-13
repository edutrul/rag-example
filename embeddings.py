import logging


def main():
    # PyTorch registra este aviso al importar Sentence Transformers en macOS.
    redirects_logger = logging.getLogger("torch.distributed.elastic.multiprocessing.redirects")
    redirects_logger.addFilter(
        lambda record: record.getMessage()
        != "NOTE: Redirects are currently not supported in MacOs."
    )

    from sentence_transformers import SentenceTransformer

    chunks = [
        "El perro es un animal doméstico.",
        "Vive con las personas.",
        "Necesita comida y agua.",
    ]

    model = SentenceTransformer(
        "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2",
        device="cpu",
    )
    embeddings = model.encode(chunks)

    print(f"Forma de la matriz: {embeddings.shape}")
    for number, (chunk, vector) in enumerate(zip(chunks, embeddings, strict=True), start=1):
        sample = ", ".join(f"{value:.6f}" for value in vector[:5])
        print(f"\nChunk {number}: {chunk}")
        print(f"Dimensiones: {len(vector)}")
        print(f"Primeros 5 números: [{sample}]")


if __name__ == "__main__":
    main()
