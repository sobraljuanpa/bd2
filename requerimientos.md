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
