# SQL Server y MongoDB trabajando en conjunto

Como primera medida debemos de establecer el lenguaje en el que vamos a interactuar con nuestras bases de datos.
Al menos el lenguaje en el cual queremos nuestra interación, lo cual no quiere decir que nuestra app esté limitado sólo al leguaje selecionado a continuacion.
Pyhton es el lenugaje selecionado para el trabajo.

### ¿Porqué Python?
- Posee una enorme cantidad de de librerías de calidad que nos facilita muchisimo las conexiones con las bases
- Una enorme comunidad detrás que ha madurado muchísimo
- Muy versatil, eficiente y confiable
- El preferido para BigData el cual puede ser de futuro interés para la información alojada en MongoDB


## ¿Cómo integrarlo?

Prerequisito:
- Python 3+

### Conexión con SQL Server

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

### Conexión con MongoDB

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


## Ejemplo de los dos sistemas trabajando en conjunto

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
