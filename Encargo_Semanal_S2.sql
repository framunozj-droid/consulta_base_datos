/* ============================================================
   PRY2205 - CONSULTA DE BASES DE DATOS
   SEMANA 2 - SHIVERSALE
   CONSULTAS DE FACTURAS, CLIENTES Y PRODUCTOS
   Ejecutar conectado como PRY2205_S2.
   ============================================================ */

/* ============================================================
   CASO 1: ANALISIS DE FACTURAS DEL ANO ANTERIOR
   ============================================================ */
SELECT
    f.numfactura AS "N° Factura",
    TO_CHAR(f.fecha, 'DD "de" FMMonth YYYY', 'NLS_DATE_LANGUAGE=SPANISH') AS "Fecha Emision",
    LPAD(f.rutcliente, 10, '0') AS "RUT Cliente",
    TO_CHAR(f.neto, 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Monto Neto",
    TO_CHAR(f.iva, 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Monto Iva",
    TO_CHAR(f.total, 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Total Factura",
    CASE
        WHEN f.total <= 50000 THEN 'Bajo'
        WHEN f.total <= 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS "Categoria Monto",
    CASE f.codpago
        WHEN 1 THEN 'EFECTIVO'
        WHEN 2 THEN 'TARJETA DEBITO'
        WHEN 3 THEN 'TARJETA CREDITO'
        ELSE 'CHEQUE'
    END AS "Forma de pago"
FROM factura f
WHERE f.fecha >= ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -12)
  AND f.fecha < TRUNC(SYSDATE, 'YYYY')
ORDER BY f.fecha DESC, f.neto DESC;

/* ============================================================
   CASO 2: CLASIFICACION DE CLIENTES
   ============================================================ */
SELECT
    LPAD(c.rutcliente, 13, '*') AS "RUT",
    INITCAP(c.nombre) AS "Cliente",
    NVL(TO_CHAR(c.telefono), 'Sin telefono') AS "TELEFONO",
    NVL(TO_CHAR(c.codcomuna), 'Sin comuna') AS "COMUNA",
    c.estado AS "ESTADO",
    CASE
        WHEN c.saldo / c.credito < 0.5 THEN
            'Bueno ( ' || TO_CHAR(ROUND(c.credito - c.saldo),
            'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') || ' )'
        WHEN c.saldo / c.credito <= 0.8 THEN
            'Regular ( ' || TO_CHAR(ROUND(c.saldo),
            'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') || ' )'
        ELSE 'Critico'
    END AS "Estado Credito",
    NVL(UPPER(SUBSTR(c.mail, INSTR(c.mail, '@') + 1)),
        'Correo no registrado') AS "Dominio Correo"
FROM cliente c
WHERE c.estado = 'A'
  AND c.credito > 0
ORDER BY c.nombre ASC;

/* ============================================================
   CASO 3: STOCK DE PRODUCTOS
   Valores solicitados al ejecutar: tipo de cambio, umbral bajo y alto.
   Ejemplo: 950, 40, 60.
   ============================================================ */
DEFINE TIPOCAMBIO_DOLAR = 950
DEFINE UMBRAL_BAJO = 40
DEFINE UMBRAL_ALTO = 60

SELECT
    p.codproducto AS "ID",
    INITCAP(p.descripcion) AS "Descripcion de Producto",
    CASE WHEN p.valorcompradolar IS NULL THEN 'Sin registro'
         ELSE TO_CHAR(p.valorcompradolar, 'FM999G990D00', 'NLS_NUMERIC_CHARACTERS='',.''') || ' USD' END AS "Compra en USD",
    CASE WHEN p.valorcompradolar IS NULL THEN 'Sin registro'
         ELSE TO_CHAR(ROUND(p.valorcompradolar * &TIPOCAMBIO_DOLAR), 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') || ' PESOS' END AS "USD convertido",
    NVL(TO_CHAR(p.totalstock), 'Sin datos') AS "Stock",
    CASE
        WHEN p.totalstock IS NULL THEN 'Sin datos'
        WHEN p.totalstock < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
        WHEN p.totalstock <= &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END AS "Alerta Stock",
    CASE
        WHEN p.totalstock > 80 THEN
            TO_CHAR(ROUND(p.vunitario * 0.9),
            'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''')
        ELSE 'N/A'
    END AS "Precio Oferta"
FROM producto p
WHERE LOWER(p.descripcion) LIKE '%zapato%'
  AND UPPER(p.procedencia) = 'I'
ORDER BY p.codproducto DESC;
