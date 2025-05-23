-- Migración para insertar datos de ejemplo en las tablas del esquema público

-- 1. Insertar tiendas (negocios) 
INSERT INTO public.stores (id, name, description, owner_id, created_at, updated_at, is_deleted)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'Restaurante El Buen Sabor', 'Restaurante con los mejores platillos de la ciudad', NULL, NOW(), NOW(), FALSE),
    ('00000000-0000-0000-0000-000000000002', 'Farmacia Santa María', 'Farmacia con atención personalizada y productos de calidad', NULL, NOW(), NOW(), FALSE),
    ('00000000-0000-0000-0000-000000000003', 'Supermercado La Esquina', 'Supermercado con variedad de productos frescos y de calidad', NULL, NOW(), NOW(), FALSE)
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = NOW();

-- 2. Insertar los productos del Restaurante (ID: 1)
INSERT INTO public.products (id, name, description, image_url, category, price, unit, quantity, store_id, status, created_at, updated_at, is_deleted)
VALUES
    -- Hamburguesas
    (gen_random_uuid(), 'Hamburguesa Clásica', 'Hamburguesa con queso, lechuga y tomate', 'https://cdn.pixabay.com/photo/2016/03/05/19/02/hamburger-1238246_1280.jpg', 'Hamburguesas', 5500, 'unidad', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Hamburguesa Especial', 'Hamburguesa con doble carne, queso, tocino y salsa especial', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd', 'Hamburguesas', 7500, 'unidad', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    
    -- Pizzas
    (gen_random_uuid(), 'Pizza Margarita', 'Pizza con salsa de tomate, mozzarella y albahaca', 'https://cdn.pixabay.com/photo/2017/12/09/08/18/pizza-3007395_1280.jpg', 'Pizzas', 8000, 'unidad', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Pizza Hawaiana', 'Pizza con jamón y piña', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38', 'Pizzas', 9000, 'unidad', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    
    -- Acompañamientos
    (gen_random_uuid(), 'Papas Fritas', 'Papas fritas crujientes', 'https://cdn.pixabay.com/photo/2016/11/20/09/06/bowl-1842294_1280.jpg', 'Acompañamientos', 2500, 'porción', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Aros de Cebolla', 'Aros de cebolla empanizados', 'https://images.unsplash.com/photo-1639024471283-03518883512d', 'Acompañamientos', 2800, 'porción', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    
    -- Bebidas
    (gen_random_uuid(), 'Refresco', 'Refresco cola', 'https://cdn.pixabay.com/photo/2016/07/21/11/17/drink-1532300_1280.jpg', 'Bebidas', 1200, 'ml', 500, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Té Helado', 'Té negro con limón', 'https://images.unsplash.com/photo-1499638673689-79a0b5115d87', 'Bebidas', 1500, 'ml', 500, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE);

-- 3. Insertar los productos de la Farmacia (ID: 2)
INSERT INTO public.products (id, name, description, image_url, category, price, unit, quantity, store_id, status, created_at, updated_at, is_deleted)
VALUES
    -- Medicamentos
    (gen_random_uuid(), 'Paracetamol', 'Analgésico y antipirético', 'https://cdn.pixabay.com/photo/2016/12/05/19/49/syringe-1884784_1280.jpg', 'Medicamentos', 2000, 'caja', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Ibuprofeno', 'Antiinflamatorio no esteroideo', 'https://cdn.pixabay.com/photo/2016/12/09/08/53/medicines-1893982_1280.jpg', 'Medicamentos', 2200, 'caja', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    
    -- Primeros Auxilios
    (gen_random_uuid(), 'Vendas Elásticas', 'Vendas para lesiones', 'https://cdn.pixabay.com/photo/2014/12/10/21/01/doctor-563429_1280.jpg', 'Primeros Auxilios', 3500, 'paquete', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Curitas', 'Bandas adhesivas para pequeñas heridas', 'https://cdn.pixabay.com/photo/2015/08/24/13/22/adhesive-bandage-905457_1280.jpg', 'Primeros Auxilios', 1500, 'caja', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE);

-- 4. Insertar los productos del Supermercado (ID: 3)
INSERT INTO public.products (id, name, description, image_url, category, price, unit, quantity, store_id, status, created_at, updated_at, is_deleted)
VALUES
    -- Frutas
    (gen_random_uuid(), 'Manzanas Rojas', 'Manzanas rojas frescas', 'https://cdn.pixabay.com/photo/2016/12/06/18/27/apples-1887337_1280.jpg', 'Frutas', 2500, 'kg', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Plátanos', 'Plátanos frescos', 'https://cdn.pixabay.com/photo/2016/01/03/17/59/bananas-1119790_1280.jpg', 'Frutas', 1200, 'kg', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Verduras
    (gen_random_uuid(), 'Tomates', 'Tomates frescos', 'https://cdn.pixabay.com/photo/2011/03/16/16/01/tomatoes-5356_1280.jpg', 'Verduras', 1800, 'kg', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Lácteos
    (gen_random_uuid(), 'Yogurt Natural', 'Yogurt natural', 'https://cdn.pixabay.com/photo/2016/06/07/17/15/yogurt-1442034_1280.jpg', 'Lácteos', 3200, 'L', 1, '00000000-0000-0000-0000-000000000003', 1, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Leche Entera', 'Leche entera', 'https://cdn.pixabay.com/photo/2017/07/05/15/41/milk-2474993_1280.jpg', 'Lácteos', 1500, 'L', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE);

-- 5. Crear registros de inventario para todos los productos
INSERT INTO public.inventory (id, store_id, product_id, current_stock, min_stock, max_stock, created_at, updated_at, is_deleted)
SELECT 
    gen_random_uuid(), 
    p.store_id, 
    p.id, 
    CASE WHEN p.status = 0 THEN 100 WHEN p.status = 1 THEN 10 ELSE 0 END, 
    10, 
    200, 
    NOW(), 
    NOW(), 
    false
FROM 
    public.products p
WHERE
    NOT EXISTS (
        SELECT 1 
        FROM public.inventory i 
        WHERE i.product_id = p.id
    ); 