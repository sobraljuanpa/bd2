DROP TABLE Usuario;
DROP TABLE Donaciones;
DROP TABLE Logro;
DROP TABLE UsuarioLogro;
DROP TABLE Subscripcion;
DROP TABLE MedioDePago;

CREATE TABLE Usuario(
    nombrePrivado   varchar(50)  not null primary key,
    nombrePublico   varchar(50)  not null unique,
    contraseña      varchar(50)  not null,
    biografia       varchar(500) not null,
    fechaNacimiento date         not null,
    numTelefono     number(20),
    email           varchar(50),
    URIFoto         varchar(50),
    URIBanner       varchar(50),
    fechaCreacion   date         not null,
    bits            number(20)   not null,
    nivel           number(1)    not null check(nivel in (1,2,3)),
    medioPagoPred   varChar(20)  references MedioDePago
);

-- Funcion para chequear tamaño de foto y banner
-- Funcion para chequear extension de foto y banner
-- Funcion para validar fecha de nacimiento (edad > 13)
-- Funcion para validar que unicamente uno de los metodos de recuperacion esta definido
-- NOTA: validar si es posible usar un autogenerated timestamp para el date 
-- Unir estas funciones en un create or update trigger

CREATE TABLE Donaciones(
	nombreDonante varChar(50) NOT null references Usuario,
	nombreDonador varChar(50) NOT null references Usuario,
	fechaDonacion date        NOT null,
	monto	      number(20)  NOT null
	primary key(nombreDonador, nombreDonante, fechaDonacion)
);

-- Funcion para checkear que el monto a transferir sea mayor al saldo del donador
-- Funcion para checkear que el monto sea positivo
-- NOTA: validar si es posible usar un autogenerated timestamp para el date

CREATE TABLE Logro( 
	id 		varchar(50)	NOT null primary key,
	descripcion 	varchar(100) 	NOT null
);

CREATE TABLE UsuarioLogro(
	nombreUsuario 	varchar(50) NOT null references Usuario,
	idLogro		varchar(50) NOT null references Logro,
	primary key(nombreUsuario, idLogro)
);

CREATE TABLE Subscripcion(
	nombreSubscritor varchar(50) NOT null references usuario,
	nombreSubscripto varchar(50) NOT null references usuario,
	fechaSuscripcion date 	     NOT null,
	fechaRenovacion  date 	     NOT null,
	medioPago	 varChar(20) NOT null references MedioDePago,
	primary key(nombreSubscritor, nombreSubscripto)
);

-- Funcion validar suscripto nivel >= 2
-- Trigger hacia ususario seteando el predeterminado.	
-- NOTA: validar si es posible usar un autogenerated timestamp para el date

CREATE TABLE MedioDePago (
	id 		    varchar(20) NOT null primary key,
	numero 		number(50),
	correo 		varchar(50),
	habilitado 	boolean 	NOT null
)

-- Validar que unicamente uno de ambos campos esta definido (numero, correo)