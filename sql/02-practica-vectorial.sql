-- Base de datos: practica_vectorial (conexion "Practica vectorial" en VS Code).
-- Una sola columna: cada fila guarda un vector de tres numeros.
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS public.vectores (
    embedding vector(3)
);
