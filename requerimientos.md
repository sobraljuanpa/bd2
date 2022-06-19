# Requerimientos

## Requerimiento 1
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


## Requerimiento 2
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
## Requerimiento 3

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

## Requerimiento 6
### SQL Server y MongoDB trabajando en conjunto

Como primera medida debemos de establecer el lenguaje en el que vamos a interactuar con nuestras bases de datos.
Al menos el lenguaje en el cual queremos nuestra interación, lo cual no quiere decir que nuestra app esté limitado sólo al leguaje selecionado a continuacion.
Pyhton es el lenugaje selecionado para el trabajo.

#### ¿Porqué Python?
- Posee una enorme cantidad de de librerías de calidad que nos facilita muchisimo las conexiones con las bases
- Una enorme comunidad detrás que ha madurado muchísimo
- Muy versatil, eficiente y confiable
- El preferido para BigData el cual puede ser de futuro interés para la información alojada en MongoDB


### ¿Cómo integrarlo?

Prerequisito:
- Python 3+

#### Conexión con SQL Server

Para la conexión con SQL Server haremos uso de la librería de python, **pyodbc**
Se puede instalar usando `pip install pyodbc` o `python -m pip install pyodbc`

Crearemos la conexión entre Python y SQL Server de la siguiente manera:
```python
import pyodbc

conexion = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost:1521;DATABASE=BD2;UID=araujo-sobral;PWD=obligatorio123')
```

Luego para poder hacer consultas necesitamos de un `cursor`. El cual obtenemos de la siguiente manera:
```python
cursor = conexion.cursor()
# Ejemplo de una consulta
cursor.execute(SELECT * Usuario)
usuarios = cursor.fetchall()
```

#### Conexión con MongoDB

Para la conexión con MongoDB haremos uso de la librería python `pymongo`.
> Se puede instalar usando `pip install pymongo` o `python -m pip install pymongo`

Para la conexión usaremos un esquema URI. Por ende tenemos la necesidad de manejar la URI.
Surge la necesidad de utilizar otra librería python llamda `dnspython`.
> Se puede instalar usando `pip install dnspython` o `python -m pip install dnspython`

Crearemos la conexión entre Python y MongoDB de la siguiente manera:
```python
import pymongo
URI = 'mongodb://araujo-sobral:obligatorio123@localhost:2324/BD2'
client = pymongo.MongoClient(URI)
```

Una vez que tenemos el cliente, podemos acceder a cualquier documento de la MongoDB


### Ejemplo de los dos sistemas trabajando en conjunto

Haremos una consulta de un nombre de usuario a la base relacional y pediremos todos los streams que éste ha realizado los cuales se encuentran el la no relacional.

```
import pymongo
import pyodbc

publicUserName = "Araujo Sobral"
if getFromSqlUserByName(publicUserName):
	# Significa que el usuario existe en la base transacional
	# por ende podré pedirle los streams que éste tiene almacenados
	# en la MongoDB
	streams = getStreamsByName(publicUserName)
	for stream in streams:
		print(f"{publicUserName} realizó un stream el día ${stream['Inicio']} de categoría ${stream['Categoria'] titulado ${strem['Titulo']})


def getStreamsByName(name):
	client = getMongoClient()
	streams = client['Streams']
	return streams.find({"NombreStreamer": name}):
	
def _getMongoClient():
	URI = 'mongodb://araujo-sobral:obligatorio123@localhost:2324/BD2'
	client = pymongo.MongoClient(URI)

def getFromSqlUserByName(name):
	cursor = getSqlQueryCursor()
	cursor.execute(SELECT nombrePublico Usuario WHERE nombrePublico = name)
	return cursor.fetchone()[0];

def _getSqlQueryCursor():
	conexion = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost:1521;DATABASE=BD2;UID=araujo-sobral;PWD=obligatorio123')
	return conexion.cursor()
```

