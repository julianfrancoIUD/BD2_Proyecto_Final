-- PRUEBAS DE CALIDAD DE DATOS

-- 1. Valores nulos en clientes
SELECT * FROM dim_cliente WHERE nombre_cliente IS NULL;

-- 2. Productos duplicados
SELECT codigo_producto, COUNT(*)
FROM dim_producto
GROUP BY codigo_producto
HAVING COUNT(*) > 1;

-- 3. Ventas negativas
SELECT * FROM hechos_ventas WHERE total_venta < 0;

-- 4. Integridad referencial cliente
SELECT *
FROM hechos_ventas hv
LEFT JOIN dim_cliente dc ON hv.id_cliente = dc.id_cliente
WHERE dc.id_cliente IS NULL;

-- 5. Integridad producto
SELECT *
FROM hechos_ventas hv
LEFT JOIN dim_producto dp ON hv.id_producto = dp.id_producto
WHERE dp.id_producto IS NULL;

-- 6. Cantidad negativa
SELECT * FROM hechos_ventas WHERE cantidad < 0;

-- 7. Precio en 0 (posible error)
SELECT * FROM hechos_ventas WHERE precio_unitario = 0;