-- Base de datos: practica_sql (selecciona la conexion "Practica SQL" en VS Code).
-- Crea la tabla vacia. No inserta filas ni borra datos existentes.
CREATE TABLE IF NOT EXISTS public.registros (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre varchar(100),
    fecha date,
    creado_en timestamp DEFAULT CURRENT_TIMESTAMP
);
