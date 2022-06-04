Este subsistema gestiona la información relacionada con el contenido. Maneja un gran volumen de datos, que escala a gran velocidad, con alta disponibilidad y tolerancia a fallas, todo esto en pos de ofrecer la mejor experiencia al usuario.

=> NADA

Cada contenido tiene un título, que el streamer puede cambiar las veces que desee durante su emisión. De cada emisión interesa conocer la fecha y hora de inicio, la fecha y hora de fin, el tiempo de emisión, la cantidad de espectadores máxima y la calidad de la trasmisión. La calidad puede ser UHD, QHD, 1080p60, 720p60, 480p, 360p o 160p.
Además, al contenido se le puede asignar una categoría, que permite conocer su temática. Las más vistas por los usuarios son: “Conversando”, “League of Legends”, “Minecraft”, etc. A su vez, las categorías están agrupadas en: “Juegos”, “IRL”, “Música”, “Esports” y “Creative”. A lo largo de una emisión, el streamer podría cambiar la categoría de su contenido.

- Titulo (variable no PK, uso autogenerado)
- DateTime inicio
- DateTime fin
- Time tiempoEmision, ver si hay forma de calcular automaticamente
- cantidad de espectadores maxima
- calidad de la transmision, pertenece a un enum de:
    - UHD
    - QHD
    - 1080p60
    - 720p60
    - 480p
    - 360p
    - 160p

- categoria, pertenece a un enum de:
    - Juegos
    - IRL
    - Musica
    - Esports
    - Creativos

Durante una emisión se abre una sala de chat que permite a los usuarios interactuar y enviar mensajes. De cada mensaje se guarda el texto, fecha y usuario que lo envió.

- EmisionId
- Texto
- NombreUsuario
- DateTime

Para cada contenido se desea registrar qué usuarios visualizaron su emisión en vivo y desde qué país se conectaron.

DOCUMENTO VISUALIZACIONES_STREAM
- EmisionId
- NombreUsuario
- Pais (si nos ponemos pillos podemos hacer un enum para paises)

Una vez finalizada la emisión en vivo, el video puede quedar público, para que los usuarios puedan verlo en otro momento. También interesa identificar qué usuarios visualizaron el contenido on demand y desde qué país lo visualizaron.

DOCUMENTO VISUALIZACIONES_VOD
- EmisionId
- NombreUsuario
- Pais (si nos ponemos pillos podemos hacer un enum para paises)

Para el subsistema Contenido
Requerimiento 4
Proveer una consulta que dada una categoría determinada, retorne la lista de streamers que hayan emitido contenido de dicha categoría.
Requerimiento 5
Proveer una consulta que dado un contenido retorne la cantidad de visualizaciones por país.
Sumar ocurrencias entre VISUALIZACIONES_VOD Y VISUALIZACIONES_STREAM


LINKS UTILES
https://www.mongodb.com/docs/manual/core/schema-validation/
https://www.mongodb.com/docs/manual/reference/bson-types/
