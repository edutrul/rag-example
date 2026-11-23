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

-- Small 2-dimensional vectors, easy to plot and reason about by hand, for
-- practicing pgvector's distance operators (<=> cosine, <-> euclidean,
-- <#> inner product) and deriving the angle between vectors with acos().
CREATE TABLE IF NOT EXISTS public.simple_vector_practice (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    embedding VECTOR(2) NOT NULL
);

INSERT INTO public.simple_vector_practice (content, embedding)
SELECT content, embedding FROM (
    VALUES
        ('A', '[1,0]'::vector),
        ('B', '[3,4]'::vector)
) AS seed(content, embedding)
WHERE NOT EXISTS (SELECT 1 FROM public.simple_vector_practice);
