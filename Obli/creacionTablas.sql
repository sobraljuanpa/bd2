DROP TABLE Compra;
DROP TABLE Suscripcion;
DROP TABLE Donaciones;
DROP TABLE UsuarioLogro;
DROP TABLE Logro;
DROP TABLE Fotos;
DROP TABLE MedioDePago;
DROP TABLE Usuario;

CREATE TABLE Logro( 
	id 		    NUMBER GENERATED AS IDENTITY,
	descripcion 	varchar(100) 	NOT null,
	PRIMARY KEY(id)
);

CREATE TABLE Usuario(
    nombrePrivado   varchar(50)  not null primary key,
    nombrePublico   varchar(50)  not null unique,
    contraseña      varchar(50)  not null,
    biografia       varchar(500) not null,
    fechaNacimiento date         not null,
    numTelefono     number(20),
    email           varchar(50),
    fechaCreacion   date         not null,
    bits            number(20)   not null,
    nivel           number(1)    not null check(nivel in (1,2,3))
);

CREATE TABLE Fotos(
	nombreUsuario varchar(50) references Usuario,
	name varchar(50) not null,
	foto blob,
	PRIMARY KEY(nombreUsuario, name)
);

CREATE TABLE UsuarioLogro(
	nombreUsuario 	varchar(50) NOT null references Usuario,
	idLogro		number NOT null references Logro,
	primary key(nombreUsuario, idLogro)
);

CREATE TABLE MedioDePago(
	id 		    NUMBER GENERATED AS IDENTITY,
	nombreUsuario varchar(50) not null references Usuario,
	numero 		number(10),
	correo 		varchar(50),
	habilitado 	char(1) NOT null check(habilitado in ('Y','N')),
    PRIMARY KEY(id)
);

CREATE TABLE Compra(
	id NUMBER GENERATED AS IDENTITY,
	nombreComprador varchar(50) not null references Usuario,
	medioDePago number not null references MedioDePago,
	cantidad number(10) not null check(cantidad in (300,5000,25000)),
	PRIMARY KEY(id)
);

CREATE TABLE Donaciones(
	nombreDonador varChar(50) NOT null references Usuario,
	nombreDonado varChar(50) NOT null references Usuario,
	fechaDonacion date        NOT null,
	monto	      number(20)  NOT null,
	primary key(nombreDonador, nombreDonado, fechaDonacion)
);

CREATE TABLE Suscripcion(
	nombreSuscriptor varchar(50) NOT null references usuario,
	nombreSuscripto varchar(50) NOT null references usuario,
	fechaSuscripcion date 	     NOT null,
	fechaRenovacion  date 	     NOT null,
	pais varchar(50) not null,
	medioPago	 number NOT null references MedioDePago,
	primary key(nombreSuscriptor, nombreSuscripto)
);