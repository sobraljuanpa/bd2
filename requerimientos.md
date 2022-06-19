# Requerimientos

### Requerimiento 1
```SQL
--- ####### REQUERIMIENTO 1
CREATE OR REPLACE PROCEDURE REQ_1 (nombre IN VARCHAR, fecha_inicio_periodo IN DATE, fecha_fin_periodo IN DATE,
    NOMBRE_RET out VARCHAR,
    TOTAL_DONACIONES out NUMBER,
    MONTO_TOTAL_RECIBIDO out NUMBER) AS
BEGIN
	SELECT u.nombrePrivado , sum(d.monto), count(u.nombrePrivado) into NOMBRE_RET, MONTO_TOTAL_RECIBIDO, TOTAL_DONACIONES
	FROM usuario u JOIN Donaciones d ON u.nombrePrivado = d.nombreDonado
	WHERE d.fechaDonacion  BETWEEN fecha_inicio_periodo AND fecha_fin_periodo AND u.nombrePrivado = nombre group by u.nombrePrivado;
END;
```
Para ejecutar el procedimiento se puede usar como base:

```SQL
set SERVEROUT on;
declare
    nombre VARCHAR(50):= 'prueba1';
    fechaInicio DATE:= TO_DATE('17-JUN-2022');
    fechaFin DATE:= To_DATE('19-JUN-2022');
    nombreRet VARCHAR(50);
    donTotal number;
    bitsTotal number;
begin
REQ_1(nombre, fechaInicio, fechaFin, nombreRet, donTotal, bitsTotal);
    DBMS_OUTPUT.PUT_LINE('Usuario '|| nombreRet||' recibió '|| donTotal||' donaciones generando'||bitsTotal||'bits');
end;
```


### Requerimiento 2
```SQL
CREATE OR REPLACE PROCEDURE REQ_2(x in NUMBER) AS
BEGIN 
	FOR ROW IN (	SELECT u.nombrePrivado, count(u.nombrePrivado) as nrosubscriptores
			From Usuario u JOIN Suscripcion s on s.nombreSuscripto = u.nombrePrivado
			WHERE CURRENT_DATE BETWEEN s.fechaSuscripcion AND s.fechaRenovacion
			Group by (u.nombreprivado)
			Order by (nrosubscriptores) DESC
			fetch first x ROWS ONLY)
	LOOP
	    DBMS_OUTPUT.PUT_LINE('Usuario '|| row.nombrePrivado||' tiene un total de '|| row.nrosubscriptores||' subscriptores');
	END LOOP;
END;
```
Para probar el requerimiento dejamos un ejemplo a continuación.

```
set SERVEROUT on;
declare
    x number:=2;
begin
REQ_2(x);
end;
```
### Requerimiento 3

```
CREATE OR REPLACE PROCEDURE REQ_3 AS
CURSOR CUR_SUBS
IS
	SELECT u.nombrePrivado, s.fechaRenovacion, s.fechasuscripcion
	FROM Usuario u 
    	JOIN Suscripcion s ON s.nombreSuscriptor = u.nombreprivado
    	JOIN Mediodepago m ON m.id = s.mediopago  
	WHERE CURRENT_DATE = s.fechaRenovacion AND m.habilitado = 'Y';
BEGIN
	FOR ROW IN CUR_SUBS
	LOOP
		update SUSCRIPCION  SET fechaRenovacion=ADD_MONTHS(ROW.fechaRenovacion, MONTHS_BETWEEN(ROW.fechaSuscripcion, ROW.fechaRenovacion));
        commit;
	END LOOP;
END;
```
Utilizamos un cursor para almacenar la tabla resultante de la consulta. Por otro lado en cada iteracion materializamos cada subscripcion para que no haya perdida de datos.
En caso de una interrupción del proceso. Los datos ya actualizados permaneceran actualizados. Al correr nuevamente éste procedimiento, obtendremos en la consulta sólo aquellas subscripciones que no se hayan renovado.

