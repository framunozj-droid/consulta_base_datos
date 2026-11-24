/* ============================================================
   PRY2205 - CONSULTA DE BASES DE DATOS
   SEMANA 5 - FINANCORP
   Utilizando subconsultas para resolver requerimientos.
   Ejecutar conectado como PRY2205_S5.
   ============================================================ */

/* CASO 1 - LISTADO DE CLIENTES
   Se obtiene el promedio de los anios de inscripcion mediante
   una subconsulta y se filtran las profesiones solicitadas. */
SELECT
    TO_CHAR(c.numrun, 'FM99G999G990', 'NLS_NUMERIC_CHARACTERS='',.''')
        || '-' || UPPER(c.dvrun) AS "RUT Cliente",
    INITCAP(TRIM(c.pnombre) || ' ' || TRIM(c.appaterno)) AS "Nombre Cliente",
    UPPER(p.nombre_prof_ofic) AS "Profesión Cliente",
    TO_CHAR(c.fecha_inscripcion, 'DD-MM-YYYY') AS "Fecha de Inscripción",
    c.direccion AS "Dirección Cliente"
FROM cliente c
JOIN profesion_oficio p ON c.cod_prof_ofic = p.cod_prof_ofic
JOIN tipo_cliente t ON c.cod_tipo_cliente = t.cod_tipo_cliente
WHERE UPPER(t.nombre_tipo_cliente) = 'TRABAJADORES DEPENDIENTES'
  AND UPPER(p.nombre_prof_ofic) IN ('CONTADOR', 'VENDEDOR')
  AND EXTRACT(YEAR FROM c.fecha_inscripcion) > (
      SELECT ROUND(AVG(EXTRACT(YEAR FROM fecha_inscripcion)))
      FROM cliente
  )
ORDER BY c.numrun ASC;

/* CASO 2 - AUMENTO DE CREDITO
   Se crea una tabla con los clientes cuyo cupo disponible
   alcanza o supera el maximo de las tarjetas solicitadas
   durante el anio anterior. La edad se expresa por anio,
   siguiendo el formato del ejemplo de la actividad. */
CREATE TABLE clientes_cupos_compra AS
SELECT
    CONCAT(CONCAT(TO_CHAR(c.numrun), '-'), UPPER(c.dvrun)) AS RUT_CLIENTE,
    EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM c.fecha_nacimiento) AS EDAD,
    TO_CHAR(tc.cupo_disp_compra, 'FM$999G999G990',
        'NLS_NUMERIC_CHARACTERS='',.''') AS CUPO_DISPONIBLE_COMPRA,
    UPPER(t.nombre_tipo_cliente) AS TIPO_CLIENTE
FROM cliente c
JOIN tarjeta_cliente tc ON c.numrun = tc.numrun
JOIN tipo_cliente t ON c.cod_tipo_cliente = t.cod_tipo_cliente
WHERE tc.cupo_disp_compra >= (
    SELECT MAX(cupo_disp_compra)
    FROM tarjeta_cliente
    WHERE EXTRACT(YEAR FROM fecha_solic_tarjeta) = EXTRACT(YEAR FROM SYSDATE) - 1
)
ORDER BY EDAD ASC;

-- Visualizacion de la tabla creada, ordenada por edad.
SELECT RUT_CLIENTE, EDAD, CUPO_DISPONIBLE_COMPRA, TIPO_CLIENTE
FROM clientes_cupos_compra
ORDER BY EDAD ASC;
