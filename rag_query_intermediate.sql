-- ============================================================
-- COMPARACIÓN COMPLETA DE MÉTRICAS
-- PostgreSQL + pgvector
--
-- Q = [1,0]
-- ============================================================

SELECT
    content,
    embedding,

    -- Número de dimensiones.
    vector_dims(embedding) AS dimensiones,

    -- Longitud o magnitud del vector.
    vector_norm(embedding) AS norma_l2,

    -- Vector normalizado a longitud 1.
    l2_normalize(embedding) AS normalizado,

    -- Distancia euclidiana:
    -- sqrt(SUM((b_i - a_i)^2))
    embedding <-> '[1,0]'::vector
        AS distancia_euclidiana,

    -- Distancia Manhattan:
    -- SUM(ABS(b_i - a_i))
    embedding <+> '[1,0]'::vector
        AS distancia_manhattan,

    -- Producto punto:
    -- SUM(a_i * b_i)
    -(embedding <#> '[1,0]'::vector)
        AS producto_punto,

    -- Distancia coseno:
    -- 1 - similitud_coseno
    embedding <=> '[1,0]'::vector
        AS distancia_coseno,

    -- Similitud coseno:
    -- producto_punto / (norma_a * norma_b)
    1 - (embedding <=> '[1,0]'::vector)
        AS similitud_coseno

FROM public.simple_vector_practice
ORDER BY embedding <=> '[1,0]'::vector ASC;