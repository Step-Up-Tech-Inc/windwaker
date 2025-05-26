-- Script para diagnosticar el campo delivery_fee en la tabla stores

-- Verificar el tipo de dato actual del campo delivery_fee
SELECT 
    column_name, 
    data_type, 
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    is_nullable
FROM 
    information_schema.columns
WHERE 
    table_name = 'stores' 
    AND column_name = 'delivery_fee';

-- Verificar si hay restricciones CHECK que limiten el valor de delivery_fee
SELECT 
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM 
    pg_constraint con
    INNER JOIN pg_class rel ON rel.oid = con.conrelid
    INNER JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
WHERE 
    rel.relname = 'stores'
    AND con.contype = 'c'
    AND pg_get_constraintdef(con.oid) LIKE '%delivery_fee%';

-- Mostrar algunos valores actuales para verificar
SELECT 
    id, 
    name, 
    delivery_fee 
FROM 
    stores 
ORDER BY 
    delivery_fee DESC 
LIMIT 5; 