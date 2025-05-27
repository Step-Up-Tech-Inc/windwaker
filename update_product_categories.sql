-- Actualizar categorías para Restaurante El Buen Sabor (ID: 00000000-0000-0000-0000-000000000001)
UPDATE products 
SET category = 'Hamburguesas' 
WHERE store_id = '00000000-0000-0000-0000-000000000001' 
AND name LIKE '%Hamburguesa%';

UPDATE products 
SET category = 'Pizzas' 
WHERE store_id = '00000000-0000-0000-0000-000000000001' 
AND name LIKE '%Pizza%';

UPDATE products 
SET category = 'Pastas' 
WHERE store_id = '00000000-0000-0000-0000-000000000001' 
AND name LIKE '%Pasta%' OR name LIKE '%Carbonara%';

UPDATE products 
SET category = 'Ensaladas' 
WHERE store_id = '00000000-0000-0000-0000-000000000001' 
AND name LIKE '%Ensalada%';

UPDATE products 
SET category = 'Sopas' 
WHERE store_id = '00000000-0000-0000-0000-000000000001' 
AND name LIKE '%Sopa%';

UPDATE products 
SET category = 'Acompañamientos' 
WHERE store_id = '00000000-0000-0000-0000-000000000001' 
AND (name LIKE '%Papas%' OR name LIKE '%Aros%' OR name LIKE '%Fritas%');

UPDATE products 
SET category = 'Bebidas' 
WHERE store_id = '00000000-0000-0000-0000-000000000001' 
AND (name LIKE '%Refresco%' OR name LIKE '%Bebida%' OR name LIKE '%Té%');

UPDATE products 
SET category = 'Platos principales' 
WHERE store_id = '00000000-0000-0000-0000-000000000001' 
AND category = 'Restaurante' 
AND category NOT IN ('Hamburguesas', 'Pizzas', 'Pastas', 'Ensaladas', 'Sopas', 'Acompañamientos', 'Bebidas');

-- Actualizar categorías para Farmacia Santa María (ID: 00000000-0000-0000-0000-000000000002)
UPDATE products 
SET category = 'Medicamentos' 
WHERE store_id = '00000000-0000-0000-0000-000000000002' 
AND (name LIKE '%Paracetamol%' OR name LIKE '%Ibuprofeno%' OR name LIKE '%Pastilla%');

UPDATE products 
SET category = 'Primeros Auxilios' 
WHERE store_id = '00000000-0000-0000-0000-000000000002' 
AND (name LIKE '%Venda%' OR name LIKE '%Curita%');

UPDATE products 
SET category = 'Suplementos' 
WHERE store_id = '00000000-0000-0000-0000-000000000002' 
AND (name LIKE '%Vitamina%' OR name LIKE '%Suplemento%');

UPDATE products 
SET category = 'Cuidado Personal' 
WHERE store_id = '00000000-0000-0000-0000-000000000002' 
AND (name LIKE '%Champú%' OR name LIKE '%Protector%');

UPDATE products 
SET category = 'Higiene' 
WHERE store_id = '00000000-0000-0000-0000-000000000002' 
AND (name LIKE '%Jabón%' OR name LIKE '%Alcohol%');

UPDATE products 
SET category = 'Protección' 
WHERE store_id = '00000000-0000-0000-0000-000000000002' 
AND name LIKE '%Mascarilla%';

UPDATE products 
SET category = 'Dispositivos Médicos' 
WHERE store_id = '00000000-0000-0000-0000-000000000002' 
AND name LIKE '%Termómetro%';

UPDATE products 
SET category = 'General' 
WHERE store_id = '00000000-0000-0000-0000-000000000002' 
AND category = 'Farmacia' 
AND category NOT IN ('Medicamentos', 'Primeros Auxilios', 'Suplementos', 'Cuidado Personal', 'Higiene', 'Protección', 'Dispositivos Médicos');

-- Actualizar categorías para Supermercado La Esquina (ID: 00000000-0000-0000-0000-000000000003)
UPDATE products 
SET category = 'Frutas' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND (name LIKE '%Manzana%' OR name LIKE '%Plátano%' OR name LIKE '%Fruta%');

UPDATE products 
SET category = 'Verduras' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND (name LIKE '%Tomate%' OR name LIKE '%Verdura%');

UPDATE products 
SET category = 'Lácteos' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND (name LIKE '%Leche%' OR name LIKE '%Yogurt%' OR name LIKE '%Huevo%');

UPDATE products 
SET category = 'Carnes' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND (name LIKE '%Pollo%' OR name LIKE '%Carne%');

UPDATE products 
SET category = 'Panadería' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND name LIKE '%Pan%';

UPDATE products 
SET category = 'Granos' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND (name LIKE '%Arroz%' OR name LIKE '%Frijol%');

UPDATE products 
SET category = 'Aceites' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND name LIKE '%Aceite%';

UPDATE products 
SET category = 'Enlatados' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND (name LIKE '%Atún%' OR name LIKE '%Lata%');

UPDATE products 
SET category = 'Desayuno' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND name LIKE '%Cereal%';

UPDATE products 
SET category = 'Repostería' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND name LIKE '%Azúcar%';

UPDATE products 
SET category = 'General' 
WHERE store_id = '00000000-0000-0000-0000-000000000003' 
AND category = 'Supermercado' 
AND category NOT IN ('Frutas', 'Verduras', 'Lácteos', 'Carnes', 'Panadería', 'Granos', 'Aceites', 'Enlatados', 'Desayuno', 'Repostería'); 