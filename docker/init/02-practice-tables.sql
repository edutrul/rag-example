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

CREATE TABLE IF NOT EXISTS public.simple_vector_practice (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    embedding VECTOR(1536)
);
