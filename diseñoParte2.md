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


Prueba de documento streams
``` javascript
    
    use oblibd2;

    let StreamsSchema = {
        bsonType: "object",//Fin, Duracion no son un campos requerido dado que no necesariamente van a estar definido siempre (emisiones en curso).
        required: ["Titulo", "NombreStreamer", "Inicio", "Espectadores", "Calidad", "Categoria"],
        properties: {
            Titulo: {
                bsonType: "string",
                description: "Titulo del stream"
            },
            NombreStreamer: {
                bsonType: "string",
                description: "Nombre publico del streamer"
            },
            Inicio: {
                bsonType: "date",
                description: "Fecha de inicio"
            },
            Espectadores: {
                bsonType: "int",
                minimum: 0,
                description: "Cantidad maxima de espectadores"
            },
            Calidad: {
                enum: ["UHD", "QHD", "1080p60", "720p60", "480p", "360p", "160p"],
                description: "Calidad del stream"
            },
            Categoria: {
                enum: ["Juegos", "IRL", "Musica", "Esports", "Creativos"],
                description: "Categoria del stream"
            }
        }
    };

    db.createCollection("Emisiones", {
        validator: {
            $jsonSchema: StreamsSchema 
        }
    });

    show dbs;
    show collections; // se deberia ver como creada la bd y la coleccion dentro de la misma

    db.Emisiones.insertOne(
        { Titulo: "PruebaStream1", NombreStreamer: "juan", Inicio: new Date(), Espectadores: 0, Calidad: "UHD", Categoria: "Juegos" }
    )

    db.Emisiones.insertMany([
        { Titulo: "PruebaStream2", NombreStreamer: "joaco", Inicio: new Date(), Espectadores: 1000, Calidad: "QHD", Categoria: "Juegos" },
        { Titulo: "PruebaStream3", NombreStreamer: "pedro", Inicio: new Date(), Espectadores: 300000, Calidad: "1080p60", Categoria: "Creativos" },
        { Titulo: "PruebaStream4", NombreStreamer: "agus", Inicio: new Date(), Espectadores: 1000, Calidad: "720p60", Categoria: "Esports" },
        { Titulo: "PruebaStream5", NombreStreamer: "fede", Inicio: new Date(), Espectadores: 50000, Calidad: "480p", Categoria: "IRL" },
        { Titulo: "PruebaStream6", NombreStreamer: "luis", Inicio: new Date(), Espectadores: 100000, Calidad: "360p", Categoria: "Musica" },
    ])

    db.Emisiones.insertOne(
        { Titulo: "PruebaStream7", NombreStreamer: "ale", Inicio: new Date(), Espectadores: 20, Calidad: "160p", Categoria: "Juegos" }
    )

    // pruebo inserciones invalidas omitiendo datos clave
    db.Emisiones.insertOne(
        { Titulo: "PruebaStreamInvalido", Inicio: new Date(), Espectadores: 20, Calidad: "160p", Categoria: "Juegos" }
    )// sin nombre => Document failed validation
    db.Emisiones.insertOne(
        { Titulo: "PruebaStreamInvalido", NombreStreamer: "ale", Espectadores: 20, Calidad: "160p", Categoria: "Juegos" }
    )// sin fecha => Document failed validation
    db.Emisiones.insertOne(
        { Titulo: "PruebaStreamInvalido", NombreStreamer: "ale", Inicio: new Date(), Calidad: "160p", Categoria: "Juegos" }
    )// sin espectadores => Document failed validation
    db.Emisiones.insertOne(
        { Titulo: "PruebaStreamInvalido", NombreStreamer: "ale", Inicio: new Date(), Espectadores: 20, Calidad: "1080p", Categoria: "Juegos" }
    )// calidad no en el enum => Document failed validation
    db.Emisiones.insertOne(
        { Titulo: "PruebaStreamInvalido", NombreStreamer: "ale", Inicio: new Date(), Espectadores: 20, Calidad: "160p", Categoria: "Cocina" }
    )// categoria no en el enum => Document failed validation


```

Investigar bien el tema refs, creo que esta bien asi pero habria que pegarle otra vichada seguro

Prueba de documento StreamChat
``` javascript
    let StreamChatSchema = {
        bsonType: "object",
        required: ["StreamId", "Mensaje", "Username", "Hora"],
        properties: {
            StreamId: {
                bsonType: "string",
                description: "Id del stream al que corresponde el mensaje"
            },
            Mensaje: {
                bsonType: "string",
                description: "Contenido del mensaje"
            },
            Username: {
                bsonType: "string",
                description: "Nombre del usuario que envia el mensaje"
            },
            Hora: {
                bsonType: "date",
                description: "Fecha del mensaje"
            }
        }
    };

    db.createCollection("Chats", {
        validator: {
            $jsonSchema: StreamChatSchema 
        }
    });

    show collections;

    db.Chats.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Mensaje: "Probando mensajeria", Username: "juanMalvado", Hora: new Date() }
    )
    db.Chats.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Mensaje: "Probando mensajeria nuevamente", Username: "juanBueno", Hora: new Date() }
    )
    db.Chats.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Mensaje: "Claramente mensajeria funciona", Username: "juanMalvado", Hora: new Date() }
    )
    db.Chats.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Mensaje: "Buen stream rey", Username: "juanBueno", Hora: new Date() }
    )

    //pruebo inserciones invalidas omitiendo parametros clave
    db.Chats.insertOne(
        { Mensaje: "Probando mensajeria", Username: "juanMalvado", Hora: new Date() }
    ) //prueba sin streamId => Document failed validation
    db.Chats.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Username: "juanBueno", Hora: new Date() }
    ) //prueba sin mensaje => Document failed validation
    db.Chats.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Mensaje: "Buen stream rey", Hora: new Date() }
    ) //prueba sin username => Document failed validation
    db.Chats.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Mensaje: "Buen stream rey", Username: "juanBueno" }
    ) //prueba sin hora => Document failed validation

```

Prueba de documento StreamChat
``` javascript

    let StreamViewSchema = {
        bsonType: "object",
        required: ["StreamId", "Pais", "Username"],
        properties: {
            StreamId: {
                bsonType: "string",
                description: "Id del stream al que corresponde el mensaje"
            },
            Pais: {
                bsonType: "string",
                description: "Pais del usuario"
            },
            Username: {
                bsonType: "string",
                description: "Nombre del usuario"
            }
        }
    };

    db.createCollection("Views", {
        validator: {
            $jsonSchema: StreamViewSchema 
        }
    });

    show collections

    db.Views.insertMany([
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "juanMalvado" },
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Brasil", Username: "juanBueno" },
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Argentina", Username: "luis" },
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "pedro" },
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "jose" }
    ])
    db.Views.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Brasil", Username: "juanBueno" }
    )
    db.Views.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Argentina", Username: "luis" }
    )
    db.Views.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "pedro" }
    )
    db.Views.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "jose" }
    )

```

Prueba de documento StreamChat
``` javascript

    let StreamViewSchema = {
        bsonType: "object",
        required: ["StreamId", "Pais", "Username"],
        properties: {
            StreamId: {
                bsonType: "string",
                description: "Id del stream al que corresponde el mensaje"
            },
            Pais: {
                bsonType: "string",
                description: "Pais del usuario"
            },
            Username: {
                bsonType: "string",
                description: "Nombre del usuario"
            }
        }
    };

    db.createCollection("Views", {
        validator: {
            $jsonSchema: StreamViewSchema 
        }
    });

    show collections

    db.Views.insertMany([
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "juanMalvado" },
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Brasil", Username: "juanBueno" },
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Argentina", Username: "luis" },
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "pedro" },
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "jose" }
    ])
    db.Views.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Brasil", Username: "juanBueno" }
    )
    db.Views.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Argentina", Username: "luis" }
    )
    db.Views.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "pedro" }
    )
    db.Views.insertOne(
        { StreamId: "629bb18298dce60358a74ba8", Pais: "Uruguay", Username: "jose" }
    )

```


Requerimiento 4
Proveer una consulta que dada una categoría determinada, retorne la lista de streamers que hayan emitido contenido de dicha categoría.
Requerimiento 5
Proveer una consulta que dado un contenido retorne la cantidad de visualizaciones por país.
Sumar ocurrencias entre VISUALIZACIONES_VOD Y VISUALIZACIONES_STREAM

https://www.mongodb.com/docs/manual/tutorial/project-fields-from-query-results/
https://www.mongodb.com/docs/manual/aggregation/

``` js

    // Cambiar juegos por cualquier otra categoria
    db.Emisiones.find( {Categoria: "Juegos"}, {  NombreStreamer: 1, _id: 0 } )

    // Cambiar streamId por stream deseado
    db.Views.aggregate([
        {
            $match: { StreamId: "629bb18298dce60358a74ba8" }
        },

        { 
            $group:{ _id: "$Pais", count: { $count: { } } } 
        }
    ])

```