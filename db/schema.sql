-- Run once before loading data. Safe to rerun against the existing lab database.
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS chunks (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    content text NOT NULL,
    model_name text NOT NULL,
    embedding vector(384) NOT NULL,
    UNIQUE (model_name, content)
);

-- Exact cosine search. No approximate vector index yet.
-- <=> gives cosine distance (smaller is closer).
-- 1 - distance gives cosine similarity (larger is closer, not confidence).
CREATE OR REPLACE FUNCTION retrieve_chunks(query_vector vector, query_model text)
RETURNS TABLE (id bigint, content text, similarity double precision)
LANGUAGE sql STABLE
AS $$
    SELECT c.id, c.content, 1 - (c.embedding <=> query_vector) AS similarity
    FROM chunks AS c
    WHERE c.model_name = query_model
    ORDER BY c.embedding <=> query_vector, c.id
    LIMIT 3;
$$;
