-- ============================================================================
-- DATOS INICIALES - TILARÁN EN LÍNEA
-- ============================================================================
-- Este script inserta las 8 tiendas y sus productos
-- Ejecutar DESPUÉS de 01_complete_database_setup.sql
-- ============================================================================

-- ============================================================================
-- TIENDAS (8 en total)
-- ============================================================================

-- 1. SUPERMERCADO MEGA SUPER
INSERT INTO public.stores (id, name, description, image_url, category, rating, delivery_time_minutes, delivery_fee, is_open, is_featured)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'Mega Super Tilarán',
  'Tu supermercado de confianza con los mejores precios y productos frescos',
  'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800',
  'Supermercado',
  4.5,
  35,
  2.50,
  true,
  true
);

-- 2. SUPERMERCADO PALI
INSERT INTO public.stores (id, name, description, image_url, category, rating, delivery_time_minutes, delivery_fee, is_open, is_featured)
VALUES (
  '22222222-2222-2222-2222-222222222222',
  'Pali Tilarán',
  'Precios bajos todos los días. Tu economía es nuestra prioridad',
  'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800',
  'Supermercado',
  4.3,
  30,
  2.00,
  true,
  false
);

-- 3. SUPERMERCADO COMPRE BIEN
INSERT INTO public.stores (id, name, description, image_url, category, rating, delivery_time_minutes, delivery_fee, is_open, is_featured)
VALUES (
  '33333333-3333-3333-3333-333333333333',
  'Compre Bien',
  'Calidad y variedad para toda la familia',
  'https://images.unsplash.com/photo-1583258292688-d0213dc5a3a8?w=800',
  'Supermercado',
  4.4,
  40,
  2.75,
  true,
  false
);

-- 4. FARMACIA VIDA SANA
INSERT INTO public.stores (id, name, description, image_url, category, rating, delivery_time_minutes, delivery_fee, is_open, is_featured)
VALUES (
  '44444444-4444-4444-4444-444444444444',
  'Farmacia Vida Sana',
  'Tu salud es nuestra prioridad. Medicamentos y productos de cuidado personal',
  'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=800',
  'Farmacia',
  4.8,
  20,
  1.50,
  true,
  true
);

-- 5. TIENDA DE MASCOTAS PATITAS FELICES
INSERT INTO public.stores (id, name, description, image_url, category, rating, delivery_time_minutes, delivery_fee, is_open, is_featured)
VALUES (
  '55555555-5555-5555-5555-555555555555',
  'Patitas Felices',
  'Todo para el bienestar de tu mascota. Alimentos, accesorios y más',
  'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=800',
  'Mascotas',
  4.7,
  35,
  2.50,
  true,
  false
);

-- 6. RESTAURANTE SABOR TICO
INSERT INTO public.stores (id, name, description, image_url, category, rating, delivery_time_minutes, delivery_fee, is_open, is_featured)
VALUES (
  '66666666-6666-6666-6666-666666666666',
  'Sabor Tico',
  'Comida típica costarricense. El auténtico sabor de Costa Rica',
  'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
  'Restaurante',
  4.9,
  45,
  3.00,
  true,
  true
);

-- 7. RESTAURANTE PIZZA EXPRESS
INSERT INTO public.stores (id, name, description, image_url, category, rating, delivery_time_minutes, delivery_fee, is_open, is_featured)
VALUES (
  '77777777-7777-7777-7777-777777777777',
  'Pizza Express',
  'Las mejores pizzas artesanales de Tilarán. Masa fresca todos los días',
  'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
  'Restaurante',
  4.6,
  40,
  2.50,
  true,
  false
);

-- 8. CAFETERÍA AROMA
INSERT INTO public.stores (id, name, description, image_url, category, rating, delivery_time_minutes, delivery_fee, is_open, is_featured)
VALUES (
  '88888888-8888-8888-8888-888888888888',
  'Cafetería Aroma',
  'El mejor café de Tilarán. Repostería artesanal y ambiente acogedor',
  'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
  'Cafetería',
  4.8,
  25,
  1.75,
  true,
  false
);

-- ============================================================================
-- PRODUCTOS - MEGA SUPER TILARÁN
-- ============================================================================

INSERT INTO public.products (name, description, image_url, category, price, unit, quantity, store_id, status) VALUES
('Arroz Tío Pelón 1kg', 'Arroz blanco de primera calidad', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400', 'Granos', 1850.00, 'kg', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Frijoles Negros 900g', 'Frijoles negros seleccionados', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400', 'Granos', 1250.00, 'bolsa', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Aceite Vegetal 1L', 'Aceite vegetal 100% puro', 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400', 'Aceites', 2350.00, 'litro', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Azúcar Blanca 1kg', 'Azúcar refinada', 'https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=400', 'Endulzantes', 950.00, 'kg', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Leche Dos Pinos 1L', 'Leche entera pasteurizada', 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400', 'Lácteos', 1450.00, 'litro', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Pan Bimbo Blanco', 'Pan de molde blanco', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400', 'Panadería', 1650.00, 'unidad', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Huevos Blancos x12', 'Huevos frescos de granja', 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400', 'Huevos', 2150.00, 'docena', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Pollo Entero', 'Pollo fresco nacional', 'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=400', 'Carnes', 4500.00, 'kg', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Tomate Fresco', 'Tomates rojos maduros', 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400', 'Verduras', 1200.00, 'kg', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Cebolla Blanca', 'Cebolla fresca nacional', 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400', 'Verduras', 1100.00, 'kg', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Plátano Maduro', 'Plátanos maduros dulces', 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=400', 'Frutas', 850.00, 'kg', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Banano', 'Bananos frescos', 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400', 'Frutas', 750.00, 'kg', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Papel Higiénico Scott x4', 'Papel higiénico doble hoja', 'https://images.unsplash.com/photo-1584556326561-c8746083993b?w=400', 'Higiene', 3250.00, 'paquete', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Jabón Protex', 'Jabón antibacterial', 'https://images.unsplash.com/photo-1622122201714-77da0ca8e5d2?w=400', 'Higiene', 1450.00, 'unidad', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Detergente Ariel 1kg', 'Detergente en polvo', 'https://images.unsplash.com/photo-1610557892470-55d9e80c0bce?w=400', 'Limpieza', 3850.00, 'kg', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Coca Cola 2L', 'Refresco de cola', 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400', 'Bebidas', 2250.00, 'litro', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Agua Cristal 600ml', 'Agua purificada', 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400', 'Bebidas', 650.00, 'unidad', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Café Volio 500g', 'Café molido tradicional', 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400', 'Bebidas', 3450.00, 'bolsa', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Galletas Pozuelo', 'Galletas surtidas', 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400', 'Snacks', 1850.00, 'paquete', 1.0, '11111111-1111-1111-1111-111111111111', 0),
('Atún Lomitos 140g', 'Atún en agua', 'https://images.unsplash.com/photo-1580127639036-4cfdb2d6f7e9?w=400', 'Enlatados', 1650.00, 'lata', 1.0, '11111111-1111-1111-1111-111111111111', 0);

-- ============================================================================
-- PRODUCTOS - PALI TILARÁN
-- ============================================================================

INSERT INTO public.products (name, description, image_url, category, price, unit, quantity, store_id, status) VALUES
('Arroz Barato 1kg', 'Arroz económico de calidad', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400', 'Granos', 1550.00, 'kg', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Frijoles Rojos 900g', 'Frijoles rojos económicos', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400', 'Granos', 1050.00, 'bolsa', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Aceite Girasol 1L', 'Aceite de girasol', 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400', 'Aceites', 1950.00, 'litro', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Azúcar Morena 1kg', 'Azúcar morena natural', 'https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=400', 'Endulzantes', 850.00, 'kg', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Leche en Polvo 400g', 'Leche en polvo fortificada', 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400', 'Lácteos', 2850.00, 'bolsa', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Pan Integral', 'Pan integral de molde', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400', 'Panadería', 1450.00, 'unidad', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Salchichas Viena', 'Salchichas de pollo', 'https://images.unsplash.com/photo-1612892483236-52d32a0e0ac1?w=400', 'Embutidos', 1850.00, 'paquete', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Pasta Espagueti 500g', 'Pasta de trigo', 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400', 'Pastas', 950.00, 'paquete', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Salsa de Tomate', 'Salsa de tomate natural', 'https://images.unsplash.com/photo-1599899424500-c5e9f9f5c7a7?w=400', 'Salsas', 1250.00, 'frasco', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Mayonesa 500g', 'Mayonesa cremosa', 'https://images.unsplash.com/photo-1472476443507-c7a5948772fc?w=400', 'Salsas', 1650.00, 'frasco', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Papas 1kg', 'Papas frescas', 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400', 'Verduras', 950.00, 'kg', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Zanahoria', 'Zanahorias frescas', 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400', 'Verduras', 850.00, 'kg', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Manzanas Rojas', 'Manzanas importadas', 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400', 'Frutas', 2250.00, 'kg', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Naranjas', 'Naranjas dulces', 'https://images.unsplash.com/photo-1547514701-42782101795e?w=400', 'Frutas', 1150.00, 'kg', 1.0, '22222222-2222-2222-2222-222222222222', 0),
('Servilletas x100', 'Servilletas de papel', 'https://images.unsplash.com/photo-1584556326561-c8746083993b?w=400', 'Higiene', 850.00, 'paquete', 1.0, '22222222-2222-2222-2222-222222222222', 0);

-- ============================================================================
-- PRODUCTOS - COMPRE BIEN
-- ============================================================================

INSERT INTO public.products (name, description, image_url, category, price, unit, quantity, store_id, status) VALUES
('Arroz Premium 2kg', 'Arroz de grano largo premium', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400', 'Granos', 3650.00, 'kg', 2.0, '33333333-3333-3333-3333-333333333333', 0),
('Quinoa Orgánica 500g', 'Quinoa orgánica importada', 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400', 'Granos', 4850.00, 'bolsa', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Aceite de Oliva Extra Virgen', 'Aceite de oliva premium', 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400', 'Aceites', 6850.00, 'botella', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Miel de Abeja Pura 500g', 'Miel natural de abeja', 'https://images.unsplash.com/photo-1587049352846-4a222e784720?w=400', 'Endulzantes', 4250.00, 'frasco', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Yogurt Griego Natural', 'Yogurt griego sin azúcar', 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400', 'Lácteos', 2850.00, 'unidad', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Queso Mozzarella 400g', 'Queso mozzarella fresco', 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400', 'Lácteos', 3950.00, 'paquete', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Salmón Fresco', 'Filete de salmón fresco', 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400', 'Pescados', 8500.00, 'kg', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Espárragos Verdes', 'Espárragos frescos', 'https://images.unsplash.com/photo-1565098772267-60af42b81ef2?w=400', 'Verduras', 3250.00, 'manojo', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Aguacate Hass', 'Aguacates premium', 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400', 'Frutas', 2850.00, 'kg', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Fresas Orgánicas', 'Fresas orgánicas frescas', 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400', 'Frutas', 3450.00, 'caja', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Arándanos Frescos', 'Arándanos importados', 'https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=400', 'Frutas', 4850.00, 'caja', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Vino Tinto Reserva', 'Vino tinto de reserva', 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=400', 'Bebidas', 12500.00, 'botella', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Chocolate Lindt 100g', 'Chocolate suizo premium', 'https://images.unsplash.com/photo-1511381939415-e44015466834?w=400', 'Snacks', 3850.00, 'barra', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Té Verde Orgánico', 'Té verde en bolsitas', 'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=400', 'Bebidas', 2650.00, 'caja', 1.0, '33333333-3333-3333-3333-333333333333', 0),
('Granola Artesanal 500g', 'Granola con frutos secos', 'https://images.unsplash.com/photo-1526318896980-cf78c088247c?w=400', 'Cereales', 3950.00, 'bolsa', 1.0, '33333333-3333-3333-3333-333333333333', 0);

-- ============================================================================
-- PRODUCTOS - FARMACIA VIDA SANA
-- ============================================================================

INSERT INTO public.products (name, description, image_url, category, price, unit, quantity, store_id, status) VALUES
('Acetaminofén 500mg', 'Analgésico y antipirético', 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400', 'Medicamentos', 2850.00, 'caja', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Ibuprofeno 400mg', 'Antiinflamatorio', 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400', 'Medicamentos', 3250.00, 'caja', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Vitamina C 1000mg', 'Suplemento vitamínico', 'https://images.unsplash.com/photo-1550572017-4d93c4441e0f?w=400', 'Vitaminas', 4850.00, 'frasco', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Multivitamínico Centrum', 'Vitaminas y minerales', 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=400', 'Vitaminas', 8950.00, 'frasco', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Alcohol en Gel 500ml', 'Desinfectante de manos', 'https://images.unsplash.com/photo-1584744982491-665216d95f8b?w=400', 'Higiene', 2450.00, 'botella', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Mascarillas Quirúrgicas x50', 'Mascarillas desechables', 'https://images.unsplash.com/photo-1584634731339-252c581abfc5?w=400', 'Higiene', 3850.00, 'caja', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Termómetro Digital', 'Termómetro infrarrojo', 'https://images.unsplash.com/photo-1584555613497-9ecf9dd06f68?w=400', 'Equipos', 12500.00, 'unidad', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Tensiómetro Digital', 'Medidor de presión arterial', 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=400', 'Equipos', 18500.00, 'unidad', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Curitas Surtidas x100', 'Apósitos adhesivos', 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?w=400', 'Primeros Auxilios', 1850.00, 'caja', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Algodón 100g', 'Algodón hidrófilo', 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=400', 'Primeros Auxilios', 1250.00, 'bolsa', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Shampoo Anticaspa', 'Shampoo medicado', 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=400', 'Cuidado Personal', 4850.00, 'botella', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Crema Hidratante Facial', 'Crema para rostro', 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400', 'Cuidado Personal', 6850.00, 'frasco', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Protector Solar FPS 50', 'Bloqueador solar', 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400', 'Cuidado Personal', 8950.00, 'botella', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Pasta Dental Colgate', 'Pasta dental con flúor', 'https://images.unsplash.com/photo-1622650861787-5eee871e9a85?w=400', 'Higiene Bucal', 2450.00, 'tubo', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Enjuague Bucal Listerine', 'Enjuague antiséptico', 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=400', 'Higiene Bucal', 3850.00, 'botella', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Hilo Dental', 'Hilo dental encerado', 'https://images.unsplash.com/photo-1598256989800-fe5f95da9787?w=400', 'Higiene Bucal', 1650.00, 'unidad', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Gotas para Ojos', 'Lágrimas artificiales', 'https://images.unsplash.com/photo-1631549916768-4119b2e5f926?w=400', 'Medicamentos', 4250.00, 'frasco', 1.0, '44444444-4444-4444-4444-444444444444', 0),
('Jarabe para la Tos', 'Expectorante natural', 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400', 'Medicamentos', 5850.00, 'frasco', 1.0, '44444444-4444-4444-4444-444444444444', 0);

-- ============================================================================
-- PRODUCTOS - PATITAS FELICES (Mascotas)
-- ============================================================================

INSERT INTO public.products (name, description, image_url, category, price, unit, quantity, store_id, status) VALUES
('Alimento para Perro Adulto 15kg', 'Alimento balanceado para perros', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400', 'Alimentos Perros', 18500.00, 'bolsa', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Alimento para Cachorro 3kg', 'Alimento especial para cachorros', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400', 'Alimentos Perros', 8950.00, 'bolsa', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Alimento para Gato Adulto 7kg', 'Alimento balanceado para gatos', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400', 'Alimentos Gatos', 12500.00, 'bolsa', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Alimento Húmedo para Gato', 'Paté de pollo para gatos', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400', 'Alimentos Gatos', 1850.00, 'lata', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Arena para Gato 5kg', 'Arena aglomerante', 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=400', 'Higiene Gatos', 4850.00, 'bolsa', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Collar Antipulgas Perro', 'Collar antiparasitario', 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400', 'Salud', 6850.00, 'unidad', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Collar Antipulgas Gato', 'Collar antiparasitario para gatos', 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400', 'Salud', 5850.00, 'unidad', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Shampoo para Perro', 'Shampoo hipoalergénico', 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400', 'Higiene Perros', 3850.00, 'botella', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Juguete Pelota para Perro', 'Pelota de goma resistente', 'https://images.unsplash.com/photo-1535294435445-d7249524ef2e?w=400', 'Juguetes', 2450.00, 'unidad', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Juguete Ratón para Gato', 'Ratón de peluche con catnip', 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=400', 'Juguetes', 1850.00, 'unidad', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Plato para Comida Perro', 'Plato de acero inoxidable', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400', 'Accesorios', 3250.00, 'unidad', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Bebedero Automático', 'Bebedero con dispensador', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400', 'Accesorios', 8500.00, 'unidad', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Correa para Perro', 'Correa retráctil 5 metros', 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400', 'Accesorios', 4850.00, 'unidad', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Cama para Perro Mediano', 'Cama acolchada', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400', 'Accesorios', 12500.00, 'unidad', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Transportadora para Gato', 'Transportadora plástica', 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=400', 'Accesorios', 15500.00, 'unidad', 1.0, '55555555-5555-5555-5555-555555555555', 0),
('Snacks Dentales para Perro', 'Premios para limpieza dental', 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400', 'Snacks', 3850.00, 'bolsa', 1.0, '55555555-5555-5555-5555-555555555555', 0);

-- ============================================================================
-- PRODUCTOS - SABOR TICO (Restaurante)
-- ============================================================================

INSERT INTO public.products (name, description, image_url, category, price, unit, quantity, store_id, status) VALUES
('Casado Tradicional', 'Arroz, frijoles, carne, plátano maduro, ensalada y picadillo', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400', 'Platos Fuertes', 4500.00, 'plato', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Gallo Pinto con Huevo', 'Gallo pinto tradicional con huevo frito y natilla', 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400', 'Desayunos', 3500.00, 'plato', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Olla de Carne', 'Sopa tradicional con carne y vegetales', 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400', 'Sopas', 4000.00, 'plato', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Arroz con Pollo', 'Arroz amarillo con pollo y vegetales', 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400', 'Platos Fuertes', 4800.00, 'plato', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Chifrijo', 'Frijoles, chicharrón, pico de gallo y tortillas', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400', 'Bocas', 3800.00, 'plato', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Tamal de Cerdo', 'Tamal tradicional costarricense', 'https://images.unsplash.com/photo-1618040996337-56904b7850b9?w=400', 'Bocas', 2500.00, 'unidad', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Picadillo de Papa', 'Picadillo tradicional de papa con carne molida', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400', 'Acompañamientos', 2000.00, 'porción', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Plátanos Maduros Fritos', 'Plátanos maduros con natilla', 'https://images.unsplash.com/photo-1587334207863-c652e1f5c1e1?w=400', 'Acompañamientos', 1500.00, 'porción', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Ceviche de Pescado', 'Ceviche fresco estilo tico', 'https://images.unsplash.com/photo-1534604973900-c43ab4c2e0ab?w=400', 'Mariscos', 5500.00, 'plato', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Patacones con Frijoles', 'Plátano verde frito con frijoles molidos', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400', 'Bocas', 3200.00, 'plato', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Tortillas Caseras (5 unidades)', 'Tortillas de maíz hechas a mano', 'https://images.unsplash.com/photo-1593759608136-45eb2ad9507d?w=400', 'Acompañamientos', 1000.00, 'orden', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Refresco Natural de Cas', 'Refresco natural de cas', 'https://images.unsplash.com/photo-1546173159-315724a31696?w=400', 'Bebidas', 1500.00, 'vaso', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Refresco Natural de Tamarindo', 'Refresco natural de tamarindo', 'https://images.unsplash.com/photo-1546173159-315724a31696?w=400', 'Bebidas', 1500.00, 'vaso', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Horchata', 'Horchata tradicional', 'https://images.unsplash.com/photo-1546173159-315724a31696?w=400', 'Bebidas', 1800.00, 'vaso', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Tres Leches', 'Pastel tres leches casero', 'https://images.unsplash.com/photo-1588195538326-c5b1e5b80c7d?w=400', 'Postres', 2800.00, 'porción', 1.0, '66666666-6666-6666-6666-666666666666', 0),
('Flan de Coco', 'Flan casero de coco', 'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=400', 'Postres', 2500.00, 'porción', 1.0, '66666666-6666-6666-6666-666666666666', 0);

-- ============================================================================
-- PRODUCTOS - PIZZA EXPRESS
-- ============================================================================

INSERT INTO public.products (name, description, image_url, category, price, unit, quantity, store_id, status) VALUES
('Pizza Margarita Personal', 'Salsa de tomate, mozzarella y albahaca', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400', 'Pizzas', 4500.00, 'unidad', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Pizza Margarita Mediana', 'Salsa de tomate, mozzarella y albahaca', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400', 'Pizzas', 7500.00, 'unidad', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Pizza Margarita Familiar', 'Salsa de tomate, mozzarella y albahaca', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400', 'Pizzas', 11000.00, 'unidad', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Pizza Pepperoni Personal', 'Mozzarella y pepperoni', 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400', 'Pizzas', 5000.00, 'unidad', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Pizza Pepperoni Mediana', 'Mozzarella y pepperoni', 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400', 'Pizzas', 8500.00, 'unidad', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Pizza Hawaiana Personal', 'Jamón, piña y mozzarella', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400', 'Pizzas', 5000.00, 'unidad', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Pizza Cuatro Quesos Mediana', 'Mozzarella, parmesano, gorgonzola y provolone', 'https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=400', 'Pizzas', 9500.00, 'unidad', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Pizza Vegetariana Mediana', 'Vegetales frescos y mozzarella', 'https://images.unsplash.com/photo-1511689660979-10d2b1aada49?w=400', 'Pizzas', 8000.00, 'unidad', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Pizza BBQ Chicken Mediana', 'Pollo, salsa BBQ, cebolla y mozzarella', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400', 'Pizzas', 9000.00, 'unidad', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Lasagna de Carne', 'Lasagna tradicional con carne molida', 'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=400', 'Pastas', 6500.00, 'porción', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Espagueti a la Boloñesa', 'Espagueti con salsa de carne', 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400', 'Pastas', 5500.00, 'plato', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Ravioles de Ricotta', 'Ravioles rellenos con salsa de tomate', 'https://images.unsplash.com/photo-1587740908075-9ea4d0f8b6c0?w=400', 'Pastas', 6000.00, 'plato', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Alitas BBQ (8 unidades)', 'Alitas de pollo con salsa BBQ', 'https://images.unsplash.com/photo-1527477396000-e27163b481c2?w=400', 'Entradas', 4500.00, 'orden', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Pan de Ajo', 'Pan artesanal con mantequilla de ajo', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400', 'Entradas', 2500.00, 'orden', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Ensalada César', 'Lechuga, crutones, parmesano y aderezo césar', 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400', 'Ensaladas', 3500.00, 'plato', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Coca Cola 500ml', 'Refresco de cola', 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400', 'Bebidas', 1500.00, 'botella', 1.0, '77777777-7777-7777-7777-777777777777', 0),
('Agua Mineral 600ml', 'Agua purificada', 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400', 'Bebidas', 1000.00, 'botella', 1.0, '77777777-7777-7777-7777-777777777777', 0);

-- ============================================================================
-- PRODUCTOS - CAFETERÍA AROMA
-- ============================================================================

INSERT INTO public.products (name, description, image_url, category, price, unit, quantity, store_id, status) VALUES
('Café Americano', 'Café negro tradicional', 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400', 'Cafés', 1800.00, 'taza', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Café Latte', 'Espresso con leche vaporizada', 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400', 'Cafés', 2500.00, 'taza', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Cappuccino', 'Espresso con leche y espuma', 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400', 'Cafés', 2500.00, 'taza', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Mocha', 'Café con chocolate y crema', 'https://images.unsplash.com/photo-1578374173703-26bf4e6e0e2e?w=400', 'Cafés', 3000.00, 'taza', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Frappé de Vainilla', 'Café frío con helado de vainilla', 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=400', 'Bebidas Frías', 3500.00, 'vaso', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Frappé de Caramelo', 'Café frío con caramelo', 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=400', 'Bebidas Frías', 3500.00, 'vaso', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Chocolate Caliente', 'Chocolate artesanal con crema', 'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?w=400', 'Bebidas Calientes', 2800.00, 'taza', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Té Chai Latte', 'Té chai con leche vaporizada', 'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=400', 'Tés', 2500.00, 'taza', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Croissant de Mantequilla', 'Croissant francés artesanal', 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400', 'Repostería', 2000.00, 'unidad', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Croissant de Chocolate', 'Croissant relleno de chocolate', 'https://images.unsplash.com/photo-1623334044303-241021148842?w=400', 'Repostería', 2500.00, 'unidad', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Muffin de Arándanos', 'Muffin casero con arándanos frescos', 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400', 'Repostería', 2200.00, 'unidad', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Cheesecake de Fresa', 'Pastel de queso con fresas', 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=400', 'Postres', 3500.00, 'porción', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Brownie de Chocolate', 'Brownie casero con nueces', 'https://images.unsplash.com/photo-1607920591413-4ec007e70023?w=400', 'Postres', 2800.00, 'porción', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Galletas de Avena (3 unidades)', 'Galletas artesanales de avena', 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400', 'Repostería', 1800.00, 'orden', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Sándwich de Jamón y Queso', 'Sándwich en pan ciabatta', 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400', 'Sándwiches', 3200.00, 'unidad', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Sándwich Vegetariano', 'Vegetales asados con queso', 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=400', 'Sándwiches', 3500.00, 'unidad', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Jugo Natural de Naranja', 'Jugo recién exprimido', 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400', 'Bebidas Frías', 2000.00, 'vaso', 1.0, '88888888-8888-8888-8888-888888888888', 0),
('Smoothie de Frutas Tropicales', 'Batido de mango, piña y fresa', 'https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=400', 'Bebidas Frías', 3200.00, 'vaso', 1.0, '88888888-8888-8888-8888-888888888888', 0);

-- ============================================================================
-- INVENTARIO INICIAL
-- ============================================================================
-- Crear registros de inventario para todos los productos con stock inicial

INSERT INTO public.inventory (product_id, quantity, min_quantity, max_quantity)
SELECT id, 50, 10, 200 FROM public.products;

-- ============================================================================
-- FIN DEL SCRIPT DE DATOS
-- ============================================================================
