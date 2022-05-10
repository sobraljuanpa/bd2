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
CREATE OR REPLACE TRIGGER VALIDAR_METODO_RECUPERACION_UNICO
BEFORE INSERT OR UPDATE ON Usuario
FOR EACH ROW
DECLARE
	TEL_DEFINIDO  BOOLEAN;
	MAIL_DEFINIDO BOOLEAN;
BEGIN
	IF :NEW.numTelefono IS NULL THEN
		TEL_DEFINIDO = FALSE;
	ELSE
		TEL_DEFINIDO = TRUE;
	END IF;

	IF :NEW.email IS NULL THEN
		MAIL_DEFINIDO = FALSE;
	ELSE
		MAIL_DEFINIDO = TRUE;
	END IF;

	IF (MAIL_DEFINIDO AND TEL_DEFINIDO) OR (NOT (MAIL_DEFINIDO OR TEL_DEFINIDO)) THEN
		RAISE_APPLICATION_ERROR(-20001, 'No pueden estar definidos ambos metodos de recuperacion');
	END IF;
END;
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
CREATE OR REPLACE TRIGGER VALIDAR_METODO_PAGO_UNICO
BEFORE INSERT OR UPDATE ON MedioDePago
FOR EACH ROW
DECLARE
	NUMTARJ_DEFINIDO  BOOLEAN;
	MAIL_DEFINIDO BOOLEAN;
BEGIN
	IF :NEW.numero IS NULL THEN
		NUMTARJ_DEFINIDO = FALSE;
	ELSE
		NUMTARJ_DEFINIDO = TRUE;
	END IF;

	IF :NEW.email IS NULL THEN
		MAIL_DEFINIDO = FALSE;
	ELSE
		MAIL_DEFINIDO = TRUE;
	END IF;

	IF (MAIL_DEFINIDO AND NUMTARJ_DEFINIDO) OR (NOT (MAIL_DEFINIDO OR NUMTARJ_DEFINIDO)) THEN
		RAISE_APPLICATION_ERROR(-20002, 'No pueden estar definidos los datos de dos medios de pago en una entrada');
	END IF;
END;