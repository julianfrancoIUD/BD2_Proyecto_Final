-- =========================================================
-- EA2 - BASES DE DATOS 2
-- CREACION BASE DE DATOS STAGING - JARDINERIA
-- =========================================================

-- =========================================================
-- CREACION DE LA BASE DE DATOS STAGING
-- =========================================================
DROP DATABASE IF EXISTS Staging;
CREATE DATABASE Staging;
USE Staging;

-- =========================================================
-- ELIMINACION PREVIA DE TABLAS BK Y STG
-- =========================================================
DROP TABLE IF EXISTS bk_src_pago;
DROP TABLE IF EXISTS bk_src_detalle_pedido;
DROP TABLE IF EXISTS bk_src_producto;
DROP TABLE IF EXISTS bk_src_pedido;
DROP TABLE IF EXISTS bk_src_cliente;
DROP TABLE IF EXISTS bk_src_categoria_producto;
DROP TABLE IF EXISTS bk_src_empleado;
DROP TABLE IF EXISTS bk_src_oficina;

DROP TABLE IF EXISTS bk_stg_pago;
DROP TABLE IF EXISTS bk_stg_detalle_pedido;
DROP TABLE IF EXISTS bk_stg_producto;
DROP TABLE IF EXISTS bk_stg_pedido;
DROP TABLE IF EXISTS bk_stg_cliente;
DROP TABLE IF EXISTS bk_stg_categoria_producto;
DROP TABLE IF EXISTS bk_stg_empleado;
DROP TABLE IF EXISTS bk_stg_oficina;

DROP TABLE IF EXISTS stg_pago;
DROP TABLE IF EXISTS stg_detalle_pedido;
DROP TABLE IF EXISTS stg_producto;
DROP TABLE IF EXISTS stg_pedido;
DROP TABLE IF EXISTS stg_cliente;
DROP TABLE IF EXISTS stg_categoria_producto;
DROP TABLE IF EXISTS stg_empleado;
DROP TABLE IF EXISTS stg_oficina;

-- =========================================================
-- CREACION DE TABLAS STAGING
-- Estructura basada en la base de datos jardineria
-- =========================================================
CREATE TABLE stg_oficina (
    ID_oficina         INT          NOT NULL,
    Descripcion        VARCHAR(10)  NOT NULL,
    ciudad             VARCHAR(30)  NOT NULL,
    pais               VARCHAR(50)  NOT NULL,
    region             VARCHAR(50)  DEFAULT NULL,
    codigo_postal      VARCHAR(10)  NOT NULL,
    telefono           VARCHAR(20)  NOT NULL,
    linea_direccion1   VARCHAR(50)  NOT NULL,
    linea_direccion2   VARCHAR(50)  DEFAULT NULL,
    PRIMARY KEY (ID_oficina)
);

CREATE TABLE stg_empleado (
    ID_empleado        INT           NOT NULL,
    nombre             VARCHAR(50)   NOT NULL,
    apellido1          VARCHAR(50)   NOT NULL,
    apellido2          VARCHAR(50)   DEFAULT NULL,
    extension          VARCHAR(10)   NOT NULL,
    email              VARCHAR(100)  NOT NULL,
    ID_oficina         INT           NOT NULL,
    ID_jefe            INT           DEFAULT NULL,
    puesto             VARCHAR(50)   DEFAULT NULL,
    PRIMARY KEY (ID_empleado)
);

CREATE TABLE stg_categoria_producto (
    Id_Categoria        INT           NOT NULL,
    Desc_Categoria      VARCHAR(50)   NOT NULL,
    descripcion_texto   TEXT,
    descripcion_html    TEXT,
    imagen              VARCHAR(256),
    PRIMARY KEY (Id_Categoria)
);

CREATE TABLE stg_cliente (
    ID_cliente                INT            NOT NULL,
    nombre_cliente            VARCHAR(50)    NOT NULL,
    nombre_contacto           VARCHAR(30)    DEFAULT NULL,
    apellido_contacto         VARCHAR(30)    DEFAULT NULL,
    telefono                  VARCHAR(15)    NOT NULL,
    fax                       VARCHAR(15)    NOT NULL,
    linea_direccion1          VARCHAR(50)    NOT NULL,
    linea_direccion2          VARCHAR(50)    DEFAULT NULL,
    ciudad                    VARCHAR(50)    NOT NULL,
    region                    VARCHAR(50)    DEFAULT NULL,
    pais                      VARCHAR(50)    DEFAULT NULL,
    codigo_postal             VARCHAR(10)    DEFAULT NULL,
    ID_empleado_rep_ventas    INT            DEFAULT NULL,
    limite_credito            DECIMAL(15,2)  DEFAULT NULL,
    PRIMARY KEY (ID_cliente)
);

CREATE TABLE stg_pedido (
    ID_pedido          INT           NOT NULL,
    fecha_pedido       DATE          NOT NULL,
    fecha_esperada     DATE          NOT NULL,
    fecha_entrega      DATE          DEFAULT NULL,
    estado             VARCHAR(15)   NOT NULL,
    comentarios        TEXT,
    ID_cliente         INT           NOT NULL,
    PRIMARY KEY (ID_pedido)
);

CREATE TABLE stg_producto (
    ID_producto         VARCHAR(15)    NOT NULL,
    nombre              VARCHAR(70)    NOT NULL,
    Categoria           INT            NOT NULL,
    dimensiones         VARCHAR(25)    DEFAULT NULL,
    proveedor           VARCHAR(50)    DEFAULT NULL,
    descripcion         TEXT,
    cantidad_en_stock   SMALLINT       NOT NULL,
    precio_venta        DECIMAL(15,2)  NOT NULL,
    precio_proveedor    DECIMAL(15,2)  DEFAULT NULL,
    PRIMARY KEY (ID_producto)
);

CREATE TABLE stg_detalle_pedido (
    ID_pedido         INT            NOT NULL,
    ID_producto       VARCHAR(15)    NOT NULL,
    cantidad          INT            NOT NULL,
    precio_unidad     DECIMAL(15,2)  NOT NULL,
    numero_linea      SMALLINT       NOT NULL,
    PRIMARY KEY (ID_pedido, ID_producto),
    UNIQUE KEY uk_stg_detalle_linea (ID_pedido, numero_linea)
);

CREATE TABLE stg_pago (
    ID_cliente         INT            NOT NULL,
    forma_pago         VARCHAR(40)    NOT NULL,
    id_transaccion     VARCHAR(50)    NOT NULL,
    fecha_pago         DATE           NOT NULL,
    total              DECIMAL(15,2)  NOT NULL,
    PRIMARY KEY (ID_cliente, id_transaccion)
);

-- =========================================================
-- CREACION DE RELACIONES EN STAGING
-- =========================================================
ALTER TABLE stg_empleado
    ADD CONSTRAINT fk_stg_empleado_oficina
    FOREIGN KEY (ID_oficina) REFERENCES stg_oficina(ID_oficina);

ALTER TABLE stg_empleado
    ADD CONSTRAINT fk_stg_empleado_jefe
    FOREIGN KEY (ID_jefe) REFERENCES stg_empleado(ID_empleado);

ALTER TABLE stg_cliente
    ADD CONSTRAINT fk_stg_cliente_empleado
    FOREIGN KEY (ID_empleado_rep_ventas) REFERENCES stg_empleado(ID_empleado);

ALTER TABLE stg_pedido
    ADD CONSTRAINT fk_stg_pedido_cliente
    FOREIGN KEY (ID_cliente) REFERENCES stg_cliente(ID_cliente);

ALTER TABLE stg_producto
    ADD CONSTRAINT fk_stg_producto_categoria
    FOREIGN KEY (Categoria) REFERENCES stg_categoria_producto(Id_Categoria);

ALTER TABLE stg_detalle_pedido
    ADD CONSTRAINT fk_stg_detalle_pedido_pedido
    FOREIGN KEY (ID_pedido) REFERENCES stg_pedido(ID_pedido);

ALTER TABLE stg_detalle_pedido
    ADD CONSTRAINT fk_stg_detalle_pedido_producto
    FOREIGN KEY (ID_producto) REFERENCES stg_producto(ID_producto);

ALTER TABLE stg_pago
    ADD CONSTRAINT fk_stg_pago_cliente
    FOREIGN KEY (ID_cliente) REFERENCES stg_cliente(ID_cliente);

-- =========================================================
-- RESPALDO DE LA BASE ORIGEN (BK DE LA BASE JARDINERIA)
-- Se almacena una copia del origen dentro de Staging
-- =========================================================
CREATE TABLE bk_src_oficina            AS SELECT * FROM jardineria.oficina;
CREATE TABLE bk_src_empleado           AS SELECT * FROM jardineria.empleado;
CREATE TABLE bk_src_categoria_producto AS SELECT * FROM jardineria.Categoria_producto;
CREATE TABLE bk_src_cliente            AS SELECT * FROM jardineria.cliente;
CREATE TABLE bk_src_pedido             AS SELECT * FROM jardineria.pedido;
CREATE TABLE bk_src_producto           AS SELECT * FROM jardineria.producto;
CREATE TABLE bk_src_detalle_pedido     AS SELECT * FROM jardineria.detalle_pedido;
CREATE TABLE bk_src_pago               AS SELECT * FROM jardineria.pago;

-- =========================================================
-- CARGA DE DATOS DESDE LA BASE ORIGEN JARDINERIA
-- Limpieza basica con TRIM, LOWER y NULLIF
-- =========================================================
INSERT INTO stg_oficina (
    ID_oficina,
    Descripcion,
    ciudad,
    pais,
    region,
    codigo_postal,
    telefono,
    linea_direccion1,
    linea_direccion2
)
SELECT
    o.ID_oficina,
    TRIM(o.Descripcion),
    TRIM(o.ciudad),
    TRIM(o.pais),
    NULLIF(TRIM(o.region), ''),
    TRIM(o.codigo_postal),
    TRIM(o.telefono),
    TRIM(o.linea_direccion1),
    NULLIF(TRIM(o.linea_direccion2), '')
FROM jardineria.oficina o;

INSERT INTO stg_empleado (
    ID_empleado,
    nombre,
    apellido1,
    apellido2,
    extension,
    email,
    ID_oficina,
    ID_jefe,
    puesto
)
SELECT
    e.ID_empleado,
    TRIM(e.nombre),
    TRIM(e.apellido1),
    NULLIF(TRIM(e.apellido2), ''),
    TRIM(e.extension),
    LOWER(TRIM(e.email)),
    e.ID_oficina,
    e.ID_jefe,
    NULLIF(TRIM(e.puesto), '')
FROM jardineria.empleado e;

INSERT INTO stg_categoria_producto (
    Id_Categoria,
    Desc_Categoria,
    descripcion_texto,
    descripcion_html,
    imagen
)
SELECT
    cp.Id_Categoria,
    TRIM(cp.Desc_Categoria),
    cp.descripcion_texto,
    cp.descripcion_html,
    cp.imagen
FROM jardineria.Categoria_producto cp;

INSERT INTO stg_cliente (
    ID_cliente,
    nombre_cliente,
    nombre_contacto,
    apellido_contacto,
    telefono,
    fax,
    linea_direccion1,
    linea_direccion2,
    ciudad,
    region,
    pais,
    codigo_postal,
    ID_empleado_rep_ventas,
    limite_credito
)
SELECT
    c.ID_cliente,
    TRIM(c.nombre_cliente),
    NULLIF(TRIM(c.nombre_contacto), ''),
    NULLIF(TRIM(c.apellido_contacto), ''),
    TRIM(c.telefono),
    TRIM(c.fax),
    TRIM(c.linea_direccion1),
    NULLIF(TRIM(c.linea_direccion2), ''),
    TRIM(c.ciudad),
    NULLIF(TRIM(c.region), ''),
    NULLIF(TRIM(c.pais), ''),
    NULLIF(TRIM(c.codigo_postal), ''),
    c.ID_empleado_rep_ventas,
    c.limite_credito
FROM jardineria.cliente c;

INSERT INTO stg_pedido (
    ID_pedido,
    fecha_pedido,
    fecha_esperada,
    fecha_entrega,
    estado,
    comentarios,
    ID_cliente
)
SELECT
    p.ID_pedido,
    p.fecha_pedido,
    p.fecha_esperada,
    p.fecha_entrega,
    TRIM(p.estado),
    p.comentarios,
    p.ID_cliente
FROM jardineria.pedido p;

INSERT INTO stg_producto (
    ID_producto,
    nombre,
    Categoria,
    dimensiones,
    proveedor,
    descripcion,
    cantidad_en_stock,
    precio_venta,
    precio_proveedor
)
SELECT
    pr.ID_producto,
    TRIM(pr.nombre),
    pr.Categoria,
    NULLIF(TRIM(pr.dimensiones), ''),
    NULLIF(TRIM(pr.proveedor), ''),
    pr.descripcion,
    pr.cantidad_en_stock,
    pr.precio_venta,
    pr.precio_proveedor
FROM jardineria.producto pr;

INSERT INTO stg_detalle_pedido (
    ID_pedido,
    ID_producto,
    cantidad,
    precio_unidad,
    numero_linea
)
SELECT
    dp.ID_pedido,
    dp.ID_producto,
    dp.cantidad,
    dp.precio_unidad,
    dp.numero_linea
FROM jardineria.detalle_pedido dp;

INSERT INTO stg_pago (
    ID_cliente,
    forma_pago,
    id_transaccion,
    fecha_pago,
    total
)
SELECT
    pa.ID_cliente,
    TRIM(pa.forma_pago),
    TRIM(pa.id_transaccion),
    pa.fecha_pago,
    pa.total
FROM jardineria.pago pa;

-- =========================================================
-- VALIDACION DE CARGA
-- =========================================================
SELECT 'oficina' AS tabla, COUNT(*) AS registros FROM stg_oficina
UNION ALL
SELECT 'empleado', COUNT(*) FROM stg_empleado
UNION ALL
SELECT 'categoria_producto', COUNT(*) FROM stg_categoria_producto
UNION ALL
SELECT 'cliente', COUNT(*) FROM stg_cliente
UNION ALL
SELECT 'pedido', COUNT(*) FROM stg_pedido
UNION ALL
SELECT 'producto', COUNT(*) FROM stg_producto
UNION ALL
SELECT 'detalle_pedido', COUNT(*) FROM stg_detalle_pedido
UNION ALL
SELECT 'pago', COUNT(*) FROM stg_pago;

SELECT 'oficina' AS tabla,
       (SELECT COUNT(*) FROM jardineria.oficina) AS origen,
       (SELECT COUNT(*) FROM stg_oficina) AS staging
UNION ALL
SELECT 'empleado',
       (SELECT COUNT(*) FROM jardineria.empleado),
       (SELECT COUNT(*) FROM stg_empleado)
UNION ALL
SELECT 'categoria_producto',
       (SELECT COUNT(*) FROM jardineria.Categoria_producto),
       (SELECT COUNT(*) FROM stg_categoria_producto)
UNION ALL
SELECT 'cliente',
       (SELECT COUNT(*) FROM jardineria.cliente),
       (SELECT COUNT(*) FROM stg_cliente)
UNION ALL
SELECT 'pedido',
       (SELECT COUNT(*) FROM jardineria.pedido),
       (SELECT COUNT(*) FROM stg_pedido)
UNION ALL
SELECT 'producto',
       (SELECT COUNT(*) FROM jardineria.producto),
       (SELECT COUNT(*) FROM stg_producto)
UNION ALL
SELECT 'detalle_pedido',
       (SELECT COUNT(*) FROM jardineria.detalle_pedido),
       (SELECT COUNT(*) FROM stg_detalle_pedido)
UNION ALL
SELECT 'pago',
       (SELECT COUNT(*) FROM jardineria.pago),
       (SELECT COUNT(*) FROM stg_pago);

SELECT 'stg_oficina' AS tabla, COUNT(*) AS claves_nulas
FROM stg_oficina
WHERE ID_oficina IS NULL
UNION ALL
SELECT 'stg_empleado', COUNT(*) FROM stg_empleado WHERE ID_empleado IS NULL
UNION ALL
SELECT 'stg_categoria_producto', COUNT(*) FROM stg_categoria_producto WHERE Id_Categoria IS NULL
UNION ALL
SELECT 'stg_cliente', COUNT(*) FROM stg_cliente WHERE ID_cliente IS NULL
UNION ALL
SELECT 'stg_pedido', COUNT(*) FROM stg_pedido WHERE ID_pedido IS NULL
UNION ALL
SELECT 'stg_producto', COUNT(*) FROM stg_producto WHERE ID_producto IS NULL
UNION ALL
SELECT 'stg_pago', COUNT(*) FROM stg_pago WHERE id_transaccion IS NULL;

-- =========================================================
-- RESPALDO BK DE LA BASE STAGING
-- =========================================================
CREATE TABLE bk_stg_oficina            AS SELECT * FROM stg_oficina;
CREATE TABLE bk_stg_empleado           AS SELECT * FROM stg_empleado;
CREATE TABLE bk_stg_categoria_producto AS SELECT * FROM stg_categoria_producto;
CREATE TABLE bk_stg_cliente            AS SELECT * FROM stg_cliente;
CREATE TABLE bk_stg_pedido             AS SELECT * FROM stg_pedido;
CREATE TABLE bk_stg_producto           AS SELECT * FROM stg_producto;
CREATE TABLE bk_stg_detalle_pedido     AS SELECT * FROM stg_detalle_pedido;
CREATE TABLE bk_stg_pago               AS SELECT * FROM stg_pago;

-- =========================================================
-- COMPROBACION DE RESPALDOS
-- =========================================================
SELECT 'bk_src_oficina' AS tabla, COUNT(*) AS registros FROM bk_src_oficina
UNION ALL
SELECT 'bk_src_empleado', COUNT(*) FROM bk_src_empleado
UNION ALL
SELECT 'bk_src_categoria_producto', COUNT(*) FROM bk_src_categoria_producto
UNION ALL
SELECT 'bk_src_cliente', COUNT(*) FROM bk_src_cliente
UNION ALL
SELECT 'bk_src_pedido', COUNT(*) FROM bk_src_pedido
UNION ALL
SELECT 'bk_src_producto', COUNT(*) FROM bk_src_producto
UNION ALL
SELECT 'bk_src_detalle_pedido', COUNT(*) FROM bk_src_detalle_pedido
UNION ALL
SELECT 'bk_src_pago', COUNT(*) FROM bk_src_pago
UNION ALL
SELECT 'bk_stg_oficina', COUNT(*) FROM bk_stg_oficina
UNION ALL
SELECT 'bk_stg_empleado', COUNT(*) FROM bk_stg_empleado
UNION ALL
SELECT 'bk_stg_categoria_producto', COUNT(*) FROM bk_stg_categoria_producto
UNION ALL
SELECT 'bk_stg_cliente', COUNT(*) FROM bk_stg_cliente
UNION ALL
SELECT 'bk_stg_pedido', COUNT(*) FROM bk_stg_pedido
UNION ALL
SELECT 'bk_stg_producto', COUNT(*) FROM bk_stg_producto
UNION ALL
SELECT 'bk_stg_detalle_pedido', COUNT(*) FROM bk_stg_detalle_pedido
UNION ALL
SELECT 'bk_stg_pago', COUNT(*) FROM bk_stg_pago;


