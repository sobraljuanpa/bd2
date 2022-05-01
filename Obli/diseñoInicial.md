# Restricciones no estructurales

## Suscripciones
Este subsistema debe ser transaccional y asegurar la consistencia de los datos en todo momento

## Contenido
Si bien el sistema no presenta volatilidad en cuanto a las estructuras de datos, es deseable contar con
cierto nivel de flexibilidad que permita agregar nuevos atributos de una manera simple y que evite
tiempos muertos o fuera de línea.

# Requerimientos extra

## Para el subsistema Usuarios, canales y suscripciones

### Requerimiento 1
Proveer un servicio que dado un rango de fechas y un usuario, retorne las donaciones en Bits
recibidas por el usuario en ese periodo. Además, se espera que retorne la cantidad total de
donaciones y el total en Bits al usuario en el periodo.

### Requerimiento 2
Proveer un servicio que reciba por parámetro una cantidad X y retorne el top X de canales por número
de suscriptores activos a la fecha

### Requerimiento 3
Proveer un servicio que dada una fecha, renueve las suscripciones vigentes que corresponda. Se debe
considerar que la suscripción tenga un medio de pago asociado, si no es así, entonces se cancela.

Nota: Este servicio será agendado para ser ejecutado diariamente (por fuera del alcance de esta entrega).

Importante: Se recomienda prestar especial atención a la integridad transaccional. Una falla en la ejecución no
debe permitir que queden datos inconsistentes. Además, si el proceso se interrumpe por algún motivo, se espera
que cuando se vuelva a ejecutar no se deba comenzar desde 0

## Para el subsistema Contenido

### Requerimiento 4
Proveer una consulta que dada una categoría determinada, retorne la lista de streamers que hayan
emitido contenido de dicha categoría.

### Requerimiento 5
Proveer una consulta que dado un contenido retorne la cantidad de visualizaciones por país.

### Requerimiento 6: Prueba de concepto
Se desea contar con una interacción entre ambos subsistemas.
Se propone que exploren alternativas para comunicar ambas bases de datos. Se podrá utilizar algún
lenguaje de programación o tecnología fuera de los utilizados en el curso.
Se deberá agregar a la documentación un informe con la propuesta. Se valorará que se adjunte
evidencia en el informe. Como evidencia se puede considerar incluir diagramas, capturas de pantalla u
otros elementos que consideren relevantes para ayudar a la interpretación de la propuesta.
Lo que se espera es una prueba de concepto, no se pide una interacción activa y funcional de ambos
subsistemas.

# Usuarios, canales y suscripciones

## Perfil de usuario
Al momento de registrarse en la plataforma cada usuario debe ingresar los siguientes datos para crear
su perfil: nombre de usuario, nombre público, contraseña, biografía y fecha de nacimiento (que debe
ser mayor a 13 años). A su vez, se requiere que seleccione la forma de recuperación, que puede ser
un número de teléfono o una dirección de correo electrónico, pero no ambos. También puede subir su
foto y banner de perfil, que pueden ser archivos JPEG, PNG o GIF de máximo 10 MB. También se
registra la fecha de creación de la cuenta

A medida que se avanza en la generación de contenido y en el uso de la plataforma los usuarios van
alcanzando “logros”. Algunos ejemplos de logros son: emitir 7 horas, emitir 8 días distintos, etc.
Cuando se cumplen determinados logros el usuario sube de nivel. Se comienza por el nivel “Streamer”,
luego se pasa a “Afiliado” y por último al nivel “Partner”. Es importante poder consultar los logros de un
usuario y su nivel alcanzado.

### Usuario-canal
Cuando un usuario alcanza el nivel “Afiliado” se permite que otros usuarios de Twitch se suscriban a
su canal. Cuando el usuario se suscribe debe seleccionar cada cuántos meses se renueva y el país de
residencia, ya que el precio varía de acuerdo al país

## Canales
Cada usuario tiene un único canal en el que puede emitir contenido en vivo y además puede seguir los
canales de sus streamers favoritos.

## Suscripciones/donaciones
Los usuarios pueden comprar Bits (moneda virtual) con los que pueden hacer donaciones a otros
usuarios. Existen tres posibles compras de bits:
- 300 bits por U$S 3,00
- 5.000 bits por U$S 64,40
- 25.000 bits por U$S 308,00
El medio de pago puede ser Paypal o tarjeta de crédito y se selecciona al momento de la compra. Se
desea poder consultar qué usuario hizo cada donación, la cantidad de bits donados y la fecha.

El usuario puede
cancelar la suscripción cuando lo desee. Al igual que con la compra de Bits, el medio de pago puede
ser Paypal o tarjeta de crédito y se selecciona al momento de la compra. Este medio de pago será
considerado el predeterminado para la renovación y el usuario lo puede modificar cuando lo desee.


# Contenido

Cada contenido tiene un título, que el streamer puede cambiar las veces que desee durante su
emisión. De cada emisión interesa conocer la fecha y hora de inicio, la fecha y hora de fin, el tiempo de
emisión, la cantidad de espectadores máxima y la calidad de la trasmisión. La calidad puede ser UHD,
QHD, 1080p60, 720p60, 480p, 360p o 160p.

Además, al contenido se le puede asignar una categoría, que
permite conocer su temática. Las más vistas por los usuarios
son: “Conversando”, “League of Legends”, “Minecraft”, etc. A
su vez, las categorías están agrupadas en: “Juegos”, “IRL”,
“Música”, “Esports” y “Creative”. A lo largo de una emisión, el
streamer podría cambiar la categoría de su contenido.

Durante una emisión se abre una sala de chat que permite a
los usuarios interactuar y enviar mensajes. De cada mensaje
se guarda el texto, fecha y usuario que lo envió.
Para cada contenido se desea registrar qué usuarios
visualizaron su emisión en vivo y desde qué país se
conectaron.
Una vez finalizada la emisión en vivo, el video puede quedar
público, para que los usuarios puedan verlo en otro momento.
También interesa identificar qué usuarios visualizaron el
contenido on demand y desde qué país lo visualizaron.

