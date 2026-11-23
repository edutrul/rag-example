
-- ============================================================
-- LABORATORIO DE PGVECTOR
-- PostgreSQL + pgvector | Fundamentos para AI Engineering y RAG
-- ============================================================
--
-- VECTORES PRINCIPALES:
-- A = [1,0]
-- B = [3,4]
--
-- Norma(A) = 1
-- Norma(B) = 5
-- Producto punto(A,B) = 3
-- Coseno(A,B) = 0.6
--
-- ::vector convierte un literal al tipo vector de pgvector.
--
-- NOTA:
-- Este laboratorio no crea ni modifica tablas.
-- ============================================================


-- ============================================================
-- 01. VERIFICAR PGVECTOR
-- ============================================================

-- Muestra la versión de la extensión instalada.
SELECT extname, extversion
FROM pg_extension
WHERE extname = 'vector';


-- ============================================================
-- 02. DIMENSIONES DE UN VECTOR
-- ============================================================

-- Cuenta cuántas componentes tiene el vector.
-- No confundir dimensiones con longitud.

SELECT
    vector_dims('[3,4]'::vector) AS dimensiones;

-- Resultado: 2


-- ============================================================
-- 03. NORMA O LONGITUD DEL VECTOR
-- ============================================================

-- Norma euclidiana:
-- ||B|| = sqrt(3^2 + 4^2)
-- ||B|| = sqrt(25) = 5

SELECT
    vector_norm('[3,4]'::vector) AS norma;

-- Resultado: 5


-- ============================================================
-- 04. DISTANCIA EUCLIDIANA (L2)
-- OPERADOR: <->
-- ============================================================

-- Calcula la distancia directa entre dos vectores.
--
-- A = [1,0]
-- B = [3,4]
--
-- d(A,B) = sqrt((3-1)^2 + (4-0)^2)
-- d(A,B) = sqrt(20)

SELECT
    '[1,0]'::vector <-> '[3,4]'::vector
        AS distancia_euclidiana;

-- Resultado aproximado: 4.472136
-- Menor distancia = vectores más cercanos.


-- ============================================================
-- 05. DISTANCIA MANHATTAN (L1)
-- OPERADOR: <+>
-- ============================================================

-- Suma las diferencias absolutas por componente.
--
-- |3-1| + |4-0| = 2 + 4 = 6

SELECT
    '[1,0]'::vector <+> '[3,4]'::vector
        AS distancia_manhattan;

-- Resultado: 6


-- ============================================================
-- 06. PRODUCTO PUNTO
-- OPERADOR: <#>
-- ============================================================

-- Producto punto matemático:
--
-- A · B = (1*3) + (0*4) = 3
--
-- pgvector devuelve el NEGATIVO del producto punto.
-- Esto permite ordenar de menor a mayor en búsquedas.

SELECT
    '[1,0]'::vector <#> '[3,4]'::vector
        AS producto_punto_negativo;

-- Resultado: -3


-- ============================================================
-- 07. OBTENER EL PRODUCTO PUNTO POSITIVO
-- ============================================================

-- Negamos el resultado de <#>.

SELECT
    -('[1,0]'::vector <#> '[3,4]'::vector)
        AS producto_punto_positivo;

-- Resultado: 3


-- ============================================================
-- 08. DISTANCIA COSENO
-- OPERADOR: <=>
-- ============================================================

-- Distancia coseno = 1 - similitud coseno
--
-- En nuestro ejemplo:
-- 1 - 0.6 = 0.4
--
-- 0 = misma dirección
-- 1 = direcciones perpendiculares
-- 2 = direcciones opuestas
--
-- Requiere vectores no nulos.

SELECT
    '[1,0]'::vector <=> '[3,4]'::vector
        AS distancia_coseno;

-- Resultado: 0.4
-- Menor distancia = mayor alineación.


-- ============================================================
-- 09. SIMILITUD COSENO
-- ============================================================

-- Similitud coseno = 1 - distancia coseno
--
-- Rango: -1 a 1
--
--  1 = misma dirección
--  0 = perpendiculares
-- -1 = direcciones opuestas

SELECT
    1 - ('[1,0]'::vector <=> '[3,4]'::vector)
        AS similitud_coseno;

-- Resultado: 0.6


-- ============================================================
-- 10. CALCULAR EL ÁNGULO ENTRE VECTORES
-- ============================================================

-- cos(theta) = similitud coseno
--
-- theta = arccos(similitud)
--
-- ACOS devuelve radianes.
-- DEGREES convierte radianes a grados.
--
-- LEAST y GREATEST evitan pequeños problemas
-- de precisión fuera del rango [-1,1].

SELECT
    DEGREES(
        ACOS(
            LEAST(
                1.0,
                GREATEST(
                    -1.0,
                    1 - ('[1,0]'::vector
                         <=> '[3,4]'::vector)
                )
            )
        )
    ) AS angulo_grados;

-- Resultado aproximado: 53.1301 grados


-- ============================================================
-- 11. NORMALIZAR UN VECTOR
-- FUNCIÓN: l2_normalize()
-- ============================================================

-- Normalizar significa obtener un vector de norma 1.
--
-- B = [3,4]
-- Norma(B) = 5
--
-- B_normalizado = [3/5,4/5]
-- B_normalizado = [0.6,0.8]
--
-- El vector conserva su dirección.

SELECT
    l2_normalize('[3,4]'::vector)
        AS vector_normalizado;

-- Resultado: [0.6,0.8]


-- ============================================================
-- 12. COMPROBAR LA NORMALIZACIÓN
-- ============================================================

-- La longitud del vector normalizado debe ser 1.

SELECT
    vector_norm(
        l2_normalize('[3,4]'::vector)
    ) AS norma_normalizada;

-- Resultado: 1


-- ============================================================
-- 13. PRODUCTO PUNTO CON VECTORES NORMALIZADOS
-- ============================================================

-- Si ambos vectores tienen norma 1:
--
-- similitud_coseno = producto_punto
--
-- A = [1,0] ya es unitario.
-- B_normalizado = [0.6,0.8]
--
-- A · B_normalizado = 0.6

SELECT
    -(
        l2_normalize('[1,0]'::vector)
        <#>
        l2_normalize('[3,4]'::vector)
    ) AS producto_punto_normalizado;

-- Resultado: 0.6
-- Coincide con la similitud coseno.


-- ============================================================
-- 14. SUMA DE VECTORES
-- OPERADOR: +
-- ============================================================

-- [1,0] + [3,4] = [4,4]

SELECT
    '[1,0]'::vector + '[3,4]'::vector
        AS suma;

-- Resultado: [4,4]


-- ============================================================
-- 15. RESTA DE VECTORES
-- OPERADOR: -
-- ============================================================

-- B - A
-- [3,4] - [1,0] = [2,4]

SELECT
    '[3,4]'::vector - '[1,0]'::vector
        AS resta;

-- Resultado: [2,4]


-- ============================================================
-- 16. MULTIPLICACIÓN POR COMPONENTES
-- OPERADOR: *
-- ============================================================

-- Multiplica componentes correspondientes.
--
-- [1,2] * [3,4] = [3,8]
--
-- ATENCIÓN:
-- No es el producto punto.

SELECT
    '[1,2]'::vector * '[3,4]'::vector
        AS multiplicacion;

-- Resultado: [3,8]


-- ============================================================
-- 17. COMPARAR TODAS LAS MÉTRICAS
-- ============================================================

-- Una sola consulta con nuestros vectores A y B.

SELECT
    '[1,0]'::vector <-> '[3,4]'::vector
        AS distancia_euclidiana,

    '[1,0]'::vector <+> '[3,4]'::vector
        AS distancia_manhattan,

    -('[1,0]'::vector <#> '[3,4]'::vector)
        AS producto_punto,

    '[1,0]'::vector <=> '[3,4]'::vector
        AS distancia_coseno,

    1 - ('[1,0]'::vector <=> '[3,4]'::vector)
        AS similitud_coseno;

-- RESULTADOS ESPERADOS:
--
-- Euclidiana:      4.472136   # Es la hipotenusa
-- Manhattan:       6
-- Producto punto:  3
-- Distancia coseno: 0.4
-- Similitud coseno: 0.6


-- ============================================================
-- 18. SIMULAR DOCUMENTOS SIN CREAR UNA TABLA
-- ============================================================

-- VALUES crea filas temporales para esta consulta.
--
-- Consulta: A = [1,0]
--
-- Tres candidatos:
--
-- Documento A: [1,0]   --> distancia coseno 0
-- Documento B: [3,4]   --> distancia coseno 0.4
-- Documento C: [-1,0]  --> distancia coseno 2

WITH documentos(nombre, embedding) AS (
    VALUES
        ('Documento A', '[1,0]'::vector),
        ('Documento B', '[3,4]'::vector),
        ('Documento C', '[-1,0]'::vector)
)
SELECT
    nombre,
    embedding,
    embedding <=> '[1,0]'::vector
        AS distancia_coseno
FROM documentos
ORDER BY distancia_coseno ASC;

-- Orden esperado:
-- Documento A: 0
-- Documento B: 0.4
-- Documento C: 2


-- ============================================================
-- 19. KNN: K-NEAREST NEIGHBORS
-- ============================================================

-- kNN significa k vecinos más cercanos.
--
-- k = 2
--
-- Buscaremos los 2 vectores con menor
-- distancia coseno respecto a [1,0].

WITH documentos(nombre, embedding) AS (
    VALUES
        ('Documento A', '[1,0]'::vector),
        ('Documento B', '[3,4]'::vector),
        ('Documento C', '[-1,0]'::vector)
)
SELECT
    nombre,
    embedding,
    embedding <=> '[1,0]'::vector
        AS distancia_coseno
FROM documentos
ORDER BY distancia_coseno ASC
LIMIT 2;

-- Devuelve:
-- Documento A
-- Documento B
--
-- Nota:
-- Es una búsqueda exacta sobre tres candidatos.
-- No estamos utilizando HNSW todavía.


-- ============================================================
-- 20. KNN MOSTRANDO SIMILITUD COSENO
-- ============================================================

-- Buscamos por distancia, pero mostramos similitud.

WITH documentos(nombre, embedding) AS (
    VALUES
        ('Documento A', '[1,0]'::vector),
        ('Documento B', '[3,4]'::vector),
        ('Documento C', '[-1,0]'::vector)
)
SELECT
    nombre,
    embedding,

    embedding <=> '[1,0]'::vector
        AS distancia_coseno,

    1 - (embedding <=> '[1,0]'::vector)
        AS similitud_coseno

FROM documentos
ORDER BY embedding <=> '[1,0]'::vector ASC
LIMIT 3;

-- Similitudes esperadas:
--
-- A:  1
-- B:  0.6
-- C: -1


-- ============================================================
-- 21. KNN UTILIZANDO DISTANCIA EUCLIDIANA
-- ============================================================

-- Cambiamos solamente el operador.
--
-- Usamos <->
-- Menor distancia euclidiana = más cercano.

WITH documentos(nombre, embedding) AS (
    VALUES
        ('Documento A', '[1,0]'::vector),
        ('Documento B', '[3,4]'::vector),
        ('Documento C', '[-1,0]'::vector)
)
SELECT
    nombre,
    embedding,
    embedding <-> '[1,0]'::vector
        AS distancia_euclidiana
FROM documentos
ORDER BY embedding <-> '[1,0]'::vector ASC
LIMIT 3;

-- Nota:
-- El ranking puede ser diferente del ranking
-- obtenido mediante distancia coseno.


-- ============================================================
-- 22. KNN UTILIZANDO PRODUCTO PUNTO
-- ============================================================

-- <#> devuelve el producto punto negativo.
--
-- Ordenamos ASC para encontrar productos punto altos.
-- Esto es apropiado cuando la métrica elegida
-- para el modelo es producto punto.

WITH documentos(nombre, embedding) AS (
    VALUES
        ('Documento A', '[1,0]'::vector),
        ('Documento B', '[3,4]'::vector),
        ('Documento C', '[-1,0]'::vector)
)
SELECT
    nombre,
    embedding,

    -(embedding <#> '[1,0]'::vector)
        AS producto_punto

FROM documentos
ORDER BY embedding <#> '[1,0]'::vector ASC
LIMIT 3;

-- Ranking esperado:
-- Documento B:  3
-- Documento A:  1
-- Documento C: -1
--
-- Observación:
-- B supera a A por producto punto.
-- Pero por coseno A es mejor.
--
-- ¡Aquí se observa la influencia de la longitud!


-- ============================================================
-- 23. COMPARAR DOS MÉTRICAS Y SUS RANKINGS
-- ============================================================

-- Cada métrica produce sus propias puntuaciones.
-- Los resultados no deben interpretarse
-- automáticamente como porcentajes de relevancia.

WITH documentos(nombre, embedding) AS (
    VALUES
        ('Documento A', '[1,0]'::vector),
        ('Documento B', '[3,4]'::vector),
        ('Documento C', '[-1,0]'::vector)
)
SELECT
    nombre,

    1 - (embedding <=> '[1,0]'::vector)
        AS similitud_coseno,

    -(embedding <#> '[1,0]'::vector)
        AS producto_punto,

    embedding <-> '[1,0]'::vector
        AS distancia_euclidiana

FROM documentos
ORDER BY embedding <=> '[1,0]'::vector ASC;


-- ============================================================
-- 24. CONSULTA TÍPICA DE RAG
-- ============================================================

-- EJEMPLO EDUCATIVO:
--
-- Los nombres jurídicos son etiquetas.
-- Los vectores son inventados para practicar SQL.
-- NO representan embeddings semánticos reales.
--
-- La pregunta se representa mediante [1,0].
-- Recuperamos los 2 candidatos más cercanos.

WITH fragmentos(titulo, embedding) AS (
    VALUES
        ('Hábeas corpus',   '[1,0]'::vector),
        ('Derecho penal',   '[3,4]'::vector),
        ('Contrato civil',  '[-1,0]'::vector)
)
SELECT
    titulo,
    embedding <=> '[1,0]'::vector
        AS distancia_coseno,
    1 - (embedding <=> '[1,0]'::vector)
        AS similitud_coseno
FROM fragmentos
ORDER BY embedding <=> '[1,0]'::vector ASC
LIMIT 2;

-- En RAG real:
--
-- 1. Un modelo genera embeddings de documentos.
-- 2. Se almacenan en PostgreSQL.
-- 3. El mismo modelo genera el embedding de la pregunta.
-- 4. pgvector recupera los fragmentos cercanos.
-- 5. Los fragmentos se entregan al LLM como contexto.


-- ============================================================
-- FIN DEL LABORATORIO
-- ============================================================
