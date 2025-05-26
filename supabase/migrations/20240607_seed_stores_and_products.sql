-- Script para llenar las tiendas y sus productos en Supabase
-- Este script toma los datos del repositorio local y los inserta en las tablas correspondientes

-- 1. Insertar tiendas (negocios) adicionales para completar las que hay en la tabla
INSERT INTO public.negocios (id, nombre, imagen_url, calificacion, tiempo_entrega_min, tiempo_entrega_max, costo_envio, categoria, ciudad, es_destacado, activo)
VALUES 
    -- ID 1: Restaurante (ya existe 'Restaurante El Buen Sabor' pero aseguramos el ID)
    ('00000000-0000-0000-0000-000000000001', 'Restaurante El Buen Sabor', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4', 4.5, 25, 35, 1500, 'Restaurante', 'Tilarán', TRUE, TRUE),
    
    -- ID 2: Farmacia
    ('00000000-0000-0000-0000-000000000002', 'Farmacia Santa María', 'https://images.unsplash.com/photo-1573883429746-084be9b5cfba', 4.8, 10, 20, 1000, 'Farmacia', 'Tilarán', TRUE, TRUE),
    
    -- ID 3: Supermercado (ya existe 'Supermercado La Esquina' pero aseguramos el ID)
    ('00000000-0000-0000-0000-000000000003', 'Supermercado La Esquina', 'https://images.unsplash.com/photo-1578916171728-46686eac8d58', 4.2, 15, 25, 1200, 'Supermercado', 'Tilarán', TRUE, TRUE)
ON CONFLICT (id) DO UPDATE 
SET nombre = EXCLUDED.nombre,
    imagen_url = EXCLUDED.imagen_url,
    calificacion = EXCLUDED.calificacion;

-- 2. Crear las tiendas correspondientes en marketplace (uniendo datos entre marketplace.stores y public.negocios)
INSERT INTO marketplace.stores (id, name, description, owner_id, created_at, updated_at, is_deleted)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'Restaurante El Buen Sabor', 'Restaurante con los mejores platillos de la ciudad', NULL, NOW(), NOW(), FALSE),
    ('00000000-0000-0000-0000-000000000002', 'Farmacia Santa María', 'Farmacia con atención personalizada y productos de calidad', NULL, NOW(), NOW(), FALSE),
    ('00000000-0000-0000-0000-000000000003', 'Supermercado La Esquina', 'Supermercado con variedad de productos frescos y de calidad', NULL, NOW(), NOW(), FALSE)
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    updated_at = NOW();

-- 3. Insertar los productos del Restaurante (ID: 1)
INSERT INTO marketplace.products (id, name, description, image_url, category, price, unit, quantity, store_id, status, created_at, updated_at, is_deleted)
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
    (gen_random_uuid(), 'Té Helado', 'Té negro con limón', 'https://images.unsplash.com/photo-1499638673689-79a0b5115d87', 'Bebidas', 1500, 'ml', 500, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    
    -- Ensaladas
    (gen_random_uuid(), 'Ensalada César', 'Ensalada con lechuga, pollo, queso parmesano y croutones', 'https://cdn.pixabay.com/photo/2017/08/13/10/58/caesar-salad-2636938_1280.jpg', 'Ensaladas', 4500, 'porción', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Ensalada Mixta', 'Ensalada con verduras variadas y aderezo', 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd', 'Ensaladas', 3800, 'porción', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    
    -- Sopas
    (gen_random_uuid(), 'Sopa de Tomate', 'Sopa casera de tomate con albahaca', 'https://cdn.pixabay.com/photo/2016/06/01/21/40/soup-1429793_1280.jpg', 'Sopas', 3200, 'porción', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    
    -- Mexicana
    (gen_random_uuid(), 'Tacos de Carne', 'Tacos de carne asada con cilantro y cebolla', 'https://cdn.pixabay.com/photo/2016/08/23/08/53/tacos-1613795_1280.jpg', 'Mexicana', 4800, 'orden', 3, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE),
    
    -- Pastas
    (gen_random_uuid(), 'Pasta Carbonara', 'Pasta con salsa cremosa, tocino y queso parmesano', 'https://cdn.pixabay.com/photo/2020/05/11/15/06/pasta-5158504_1280.jpg', 'Pastas', 6500, 'porción', 1, '00000000-0000-0000-0000-000000000001', 0, NOW(), NOW(), FALSE);

-- 4. Insertar los productos de la Farmacia (ID: 2)
INSERT INTO marketplace.products (id, name, description, image_url, category, price, unit, quantity, store_id, status, created_at, updated_at, is_deleted)
VALUES
    -- Medicamentos
    (gen_random_uuid(), 'Paracetamol', 'Analgésico y antipirético', 'https://cdn.pixabay.com/photo/2016/12/05/19/49/syringe-1884784_1280.jpg', 'Medicamentos', 2000, 'caja', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Ibuprofeno', 'Antiinflamatorio no esteroideo', 'https://cdn.pixabay.com/photo/2016/12/09/08/53/medicines-1893982_1280.jpg', 'Medicamentos', 2200, 'caja', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Pastillas para la Tos', 'Pastillas para aliviar la tos', 'https://cdn.pixabay.com/photo/2014/07/10/15/59/pills-389714_1280.jpg', 'Medicamentos', 1800, 'caja', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    
    -- Primeros Auxilios
    (gen_random_uuid(), 'Vendas Elásticas', 'Vendas para lesiones', 'https://cdn.pixabay.com/photo/2014/12/10/21/01/doctor-563429_1280.jpg', 'Primeros Auxilios', 3500, 'paquete', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Curitas', 'Bandas adhesivas para pequeñas heridas', 'https://cdn.pixabay.com/photo/2015/08/24/13/22/adhesive-bandage-905457_1280.jpg', 'Primeros Auxilios', 1500, 'caja', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    
    -- Suplementos
    (gen_random_uuid(), 'Vitamina C', 'Suplemento vitamínico', 'https://cdn.pixabay.com/photo/2015/09/21/22/52/vitamin-951503_1280.jpg', 'Suplementos', 5000, 'frasco', 1, '00000000-0000-0000-0000-000000000002', 1, NOW(), NOW(), FALSE),
    
    -- Dispositivos Médicos
    (gen_random_uuid(), 'Termómetro Digital', 'Termómetro digital de precisión', 'https://cdn.pixabay.com/photo/2020/04/19/13/33/virus-5064169_1280.jpg', 'Dispositivos Médicos', 7500, 'unidad', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    
    -- Higiene
    (gen_random_uuid(), 'Alcohol en Gel', 'Alcohol en gel antibacterial', 'https://cdn.pixabay.com/photo/2020/05/23/08/54/hand-sanitizer-5209663_1280.jpg', 'Higiene', 2500, 'botella', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Jabón Antibacterial', 'Jabón líquido antibacterial para manos', 'https://cdn.pixabay.com/photo/2020/04/10/13/22/coronavirus-5025651_1280.jpg', 'Higiene', 2800, 'botella', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    
    -- Protección
    (gen_random_uuid(), 'Mascarillas Desechables', 'Paquete de mascarillas quirúrgicas', 'https://cdn.pixabay.com/photo/2020/04/25/20/34/mouth-guard-5092086_1280.jpg', 'Protección', 3000, 'paquete', 10, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE),
    
    -- Dermatología
    (gen_random_uuid(), 'Protector Solar', 'Protector solar FPS 50', 'https://cdn.pixabay.com/photo/2018/06/25/18/29/sun-3497588_1280.jpg', 'Dermatología', 8500, 'botella', 1, '00000000-0000-0000-0000-000000000002', 0, NOW(), NOW(), FALSE);

-- 5. Insertar los productos del Supermercado (ID: 3)
INSERT INTO marketplace.products (id, name, description, image_url, category, price, unit, quantity, store_id, status, created_at, updated_at, is_deleted)
VALUES
    -- Frutas
    (gen_random_uuid(), 'Manzanas Rojas', 'Manzanas rojas frescas', 'https://cdn.pixabay.com/photo/2016/12/06/18/27/apples-1887337_1280.jpg', 'Frutas', 2500, 'kg', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Plátanos', 'Plátanos frescos', 'https://cdn.pixabay.com/photo/2016/01/03/17/59/bananas-1119790_1280.jpg', 'Frutas', 1200, 'kg', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Verduras
    (gen_random_uuid(), 'Tomates', 'Tomates frescos', 'https://cdn.pixabay.com/photo/2011/03/16/16/01/tomatoes-5356_1280.jpg', 'Verduras', 1800, 'kg', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Lácteos
    (gen_random_uuid(), 'Yogurt Natural', 'Yogurt natural', 'https://cdn.pixabay.com/photo/2016/06/07/17/15/yogurt-1442034_1280.jpg', 'Lácteos', 3200, 'L', 1, '00000000-0000-0000-0000-000000000003', 1, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Leche Entera', 'Leche entera', 'https://cdn.pixabay.com/photo/2017/07/05/15/41/milk-2474993_1280.jpg', 'Lácteos', 1500, 'L', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Huevos', 'Huevos frescos de gallina', 'https://cdn.pixabay.com/photo/2015/09/17/17/19/egg-944495_1280.jpg', 'Lácteos', 2800, 'docena', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Carnes
    (gen_random_uuid(), 'Pechuga de Pollo', 'Pechuga de pollo fresca', 'https://cdn.pixabay.com/photo/2016/05/30/15/31/poultry-1424979_1280.jpg', 'Carnes', 4500, 'g', 500, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Granos
    (gen_random_uuid(), 'Arroz', 'Arroz blanco de primera calidad', 'https://cdn.pixabay.com/photo/2014/10/22/16/38/ingrediant-498199_1280.jpg', 'Granos', 2200, 'kg', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    (gen_random_uuid(), 'Frijoles Negros', 'Frijoles negros de alta calidad', 'https://cdn.pixabay.com/photo/2016/09/15/19/24/black-bean-1672136_1280.jpg', 'Granos', 1800, 'kg', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Aceites
    (gen_random_uuid(), 'Aceite de Oliva', 'Aceite de oliva extra virgen', 'https://cdn.pixabay.com/photo/2020/05/25/22/49/oil-5220801_1280.jpg', 'Aceites', 5500, 'L', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Repostería
    (gen_random_uuid(), 'Azúcar', 'Azúcar blanca refinada', 'https://cdn.pixabay.com/photo/2016/07/28/19/03/sugar-1548749_1280.jpg', 'Repostería', 1200, 'kg', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Pastas
    (gen_random_uuid(), 'Pasta de Tornillos', 'Pasta de trigo de alta calidad', 'https://cdn.pixabay.com/photo/2015/05/01/11/30/pasta-748895_1280.jpg', 'Pastas', 950, 'paquete', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Panadería
    (gen_random_uuid(), 'Pan Integral', 'Pan integral recién horneado', 'https://cdn.pixabay.com/photo/2016/07/10/19/19/bread-1508166_1280.jpg', 'Panadería', 1500, 'unidad', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Desayuno
    (gen_random_uuid(), 'Cereal Integral', 'Cereal de granos integrales con miel', 'https://cdn.pixabay.com/photo/2016/11/06/23/31/breakfast-1804457_1280.jpg', 'Desayuno', 3500, 'caja', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE),
    
    -- Enlatados
    (gen_random_uuid(), 'Atún en Lata', 'Atún en aceite de oliva', 'https://cdn.pixabay.com/photo/2016/05/31/13/01/sardines-1426708_1280.jpg', 'Enlatados', 1800, 'lata', 1, '00000000-0000-0000-0000-000000000003', 0, NOW(), NOW(), FALSE);

-- 6. Crear registros de inventario para todos los productos
INSERT INTO marketplace.inventory (id, store_id, product_id, current_stock, min_stock, max_stock, created_at, updated_at, is_deleted)
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
    marketplace.products p
WHERE
    NOT EXISTS (
        SELECT 1 
        FROM marketplace.inventory i 
        WHERE i.product_id = p.id
    ); 