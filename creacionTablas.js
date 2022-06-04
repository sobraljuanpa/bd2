let db;

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

let VODViewSchema = {
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


db.createCollection("Emisiones", {
    validator: {
        $jsonSchema: SchemaEmisiones 
    }
});