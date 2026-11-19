-- Open this file in the VS Code PostgreSQL client connected to rag_example.
-- Select a statement and execute it to explore its results.

-- Read the stored text and check the embedding dimensions.
SELECT id, content, model_name, vector_dims(embedding) AS dimensions
FROM chunks
ORDER BY id;

-- See the vectors themselves (each has 384 numbers).
SELECT id, embedding FROM chunks ORDER BY id;

-- Search using a saved sentence's vector as the query.
-- That sentence should rank first with similarity near 1.
-- For a NEW natural-language question, Python must first embed the question.
SELECT id, content,
       1 - (embedding <=> (
           SELECT embedding FROM chunks
           WHERE content = 'The dog needs food and water.'
             AND model_name = 'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2'
       )) AS similarity
FROM chunks
WHERE model_name = 'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2'
ORDER BY similarity DESC, id
LIMIT 3;
