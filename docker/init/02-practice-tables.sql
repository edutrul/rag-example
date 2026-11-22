-- Practice tables in the rag_example database, seeded on first start.
-- CREATE TABLE IF NOT EXISTS lets this run again without deleting existing data.
CREATE TABLE IF NOT EXISTS public.simple_sql_practice (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL
);

INSERT INTO public.simple_sql_practice (content)
SELECT content FROM (
    VALUES
        ('The dog is a domesticated animal.'),
        ('The dog lives with people.'),
        ('It needs food and water.')
) AS seed(content)
WHERE NOT EXISTS (SELECT 1 FROM public.simple_sql_practice);

-- Small 3-dimensional vectors, easy to reason about by hand, for practicing
-- pgvector's distance operators (<=> cosine, <-> euclidean, <#> inner product).
CREATE TABLE IF NOT EXISTS public.simple_vector_practice (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    embedding VECTOR(3) NOT NULL
);

INSERT INTO public.simple_vector_practice (content, embedding)
SELECT content, embedding FROM (
    VALUES
        ('unit vector on x', '[1,0,0]'::vector),
        ('unit vector on y', '[0,1,0]'::vector),
        ('diagonal in the xy-plane', '[1,1,0]'::vector)
) AS seed(content, embedding)
WHERE NOT EXISTS (SELECT 1 FROM public.simple_vector_practice);
