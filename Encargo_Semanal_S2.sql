/* ============================================================
   PRY2205 - CONSULTA DE BASES DE DATOS
   ACTIVIDAD SUMATIVA - SEMANA 3 (FORMA B)
   EMPRESA ASOCIADOS
   ============================================================ */

SET VERIFY OFF;

/* ============================================================
   CASO 1 - ANALISIS DE PROPIEDADES
   Ingresar 100000 para reproducir el umbral del ejemplo.
   ============================================================ */

SELECT
    p.id_tipo_propiedad AS "TIPO",
    COUNT(*) AS "TOTAL_PROPIEDADES",
    TO_CHAR(MAX(p.valor_arriendo), 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') AS "MAX_ARRIENDO",
    TO_CHAR(ROUND(AVG(p.valor_arriendo)), 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') AS "PROMEDIO_ARRIENDO",
    TO_CHAR(MIN(p.valor_arriendo), 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') AS "MIN_ARRIENDO",
    CASE WHEN MAX(p.valor_arriendo) <= 1000000
         THEN 'ESTÁNDAR' ELSE 'PREMIUM' END AS "CLASIFICACION",
    TO_CHAR(SUM(NVL(p.valor_gasto_comun, 0)), 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') AS "TOTAL_GASTOS_COMUNES"
FROM propiedad p
GROUP BY p.id_tipo_propiedad
HAVING SUM(NVL(p.valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(p.valor_gasto_comun, 0)) DESC;

/* ============================================================
   CASO 2 - ANTIGUEDAD DE EMPLEADOS
   Ingresar 30 para excluir la sucursal Providencia.
   ============================================================ */

SELECT
    UPPER(TRIM(e.nombre_emp || ' ' || e.appaterno_emp)) AS "Nombre Empleado",
    TO_CHAR(e.sueldo_emp, 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Sueldo con Formato",
    CASE WHEN e.sueldo_emp > 2000000 THEN 'ALTO' ELSE 'MEDIO' END AS "Clasificación Sueldo",
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) AS "Años Antigüedad",
    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) > 20
            THEN 'Corresponde bono 15%: ' || TO_CHAR(ROUND(e.sueldo_emp * 0.15), 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''')
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12) >= 11
            THEN 'Corresponde bono 10%: ' || TO_CHAR(ROUND(e.sueldo_emp * 0.10), 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''')
        ELSE 'Corresponde bono 5%: ' || TO_CHAR(ROUND(e.sueldo_emp * 0.05), 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''')
    END AS "BONO"
FROM empleado e
WHERE e.id_categoria_emp = 3
  AND e.id_sucursal <> &CODIGO_SUCURSAL
  AND MONTHS_BETWEEN(SYSDATE, e.fecing_emp) > 60
ORDER BY e.sueldo_emp DESC;

/* ============================================================
   CASO 3 - LISTA DE CLIENTES POR RENTA
   La disponibilidad de teléfono se evalúa con celular_cli.
   ============================================================ */

SELECT
    CASE
        WHEN c.renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN c.renta_cli >= 600000 THEN 'ALTA'
        WHEN c.renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END AS "CLASIFICACION_RENTA",
    COUNT(*) AS "CANTIDAD_CLIENTES",
    TO_CHAR(ROUND(AVG(c.renta_cli)), 'FM$999G999G990', 'NLS_NUMERIC_CHARACTERS='',.''') AS "RENTA_PROMEDIO",
    CASE WHEN COUNT(c.celular_cli) = 0
         THEN 'Clientes sin Teléfono'
         ELSE 'Clientes con Teléfono' END AS "ESTADO_TELEFONO"
FROM cliente c
GROUP BY CASE
        WHEN c.renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN c.renta_cli >= 600000 THEN 'ALTA'
        WHEN c.renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END
HAVING AVG(c.renta_cli) > 200000
ORDER BY "CLASIFICACION_RENTA";
