-- Script para modificar el campo delivery_fee en la tabla stores
-- Cambia el tipo de dato a numeric con mayor precisión o elimina la restricción de valor máximo

-- Opción 1: Cambiar el tipo de dato a numeric(10,2) para permitir valores más grandes
ALTER TABLE stores 
ALTER COLUMN delivery_fee TYPE numeric(10,2);

-- Opción 2: Si existe una restricción CHECK que limita el valor, eliminarla
-- (Primero debemos identificar el nombre de la restricción)
DO $$
DECLARE
    constraint_name text;
BEGIN
    SELECT con.conname INTO constraint_name
    FROM pg_constraint con
    INNER JOIN pg_class rel ON rel.oid = con.conrelid
    INNER JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
    WHERE rel.relname = 'stores'
    AND con.contype = 'c'
    AND pg_get_constraintdef(con.oid) LIKE '%delivery_fee%';
    
    IF constraint_name IS NOT NULL THEN
        EXECUTE 'ALTER TABLE stores DROP CONSTRAINT ' || constraint_name;
    END IF;
END $$;

-- Opcional: Agregar una nueva restricción con un límite más alto si es necesario
-- ALTER TABLE stores 
-- ADD CONSTRAINT stores_delivery_fee_check 
-- CHECK (delivery_fee >= 0 AND delivery_fee <= 100000); 