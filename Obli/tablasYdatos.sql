DROP TABLE SUSCRIPCION;
DROP TABLE MEDIODEPAGO;
DROP TABLE DONACIONES;
DROP TABLE COMPRAS;
DROP TABLE LOGRO;
DROP TABLE USUARIOLOGRO;
DROP TABLE IMAGENES;
DROP TABLE USUARIO;

CREATE TABLE MedioDePago(
	id 		    NUMBER GENERATED AS IDENTITY,
	nombreUsuario varchar(50) not null references Usuario,
	numero 		number(10),
	correo 		varchar(50),
	habilitado 	char(1) NOT null, -- Y O N
    PRIMARY KEY(id)
);

-- Este proc se usa en el trigger de mediodepago y en el de usuario
CREATE OR REPLACE PROCEDURE CHECK_ONLY_ONE_METHOD (num IN NUMBER, mail IN VARCHAR)
IS
    TEL_DEFINIDO  BOOLEAN;
	MAIL_DEFINIDO BOOLEAN;
BEGIN
    IF num IS NULL THEN
		TEL_DEFINIDO := FALSE;
	ELSE
		TEL_DEFINIDO := TRUE;
	END IF;

	IF mail IS NULL THEN
		MAIL_DEFINIDO := FALSE;
	ELSE
		MAIL_DEFINIDO := TRUE;
	END IF;

	IF (MAIL_DEFINIDO AND TEL_DEFINIDO) OR (NOT (MAIL_DEFINIDO OR TEL_DEFINIDO)) THEN
		RAISE_APPLICATION_ERROR(-20001, 'No pueden estar definidos ambos valores, pero uno es necesario.');
	END IF;
END;

CREATE OR REPLACE TRIGGER VALIDAR_METODO_PAGO_UNICO BEFORE INSERT OR UPDATE ON MedioDePago
FOR EACH ROW
BEGIN
	CHECK_ONLY_ONE_METHOD(:NEW.numero, :NEW.correo);
END;

-- Insercion datos validos
INSERT INTO MEDIODEPAGO (NUMERO, HABILITADO) VALUES (12345, 'Y');
INSERT INTO MEDIODEPAGO (NUMERO, HABILITADO) VALUES (133345, 'Y');
INSERT INTO MEDIODEPAGO (NUMERO, HABILITADO) VALUES (1235645, 'Y');
INSERT INTO MEDIODEPAGO (NUMERO, HABILITADO) VALUES (123415, 'N');
INSERT INTO MEDIODEPAGO (CORREO, HABILITADO) VALUES ('PRUEBA@MAIL.COM', 'Y');
INSERT INTO MEDIODEPAGO (CORREO, HABILITADO) VALUES ('USUARIO@USUARIO.USUARIO', 'N');

COMMIT;

-- Probando trigger
INSERT INTO MEDIODEPAGO (NUMERO, CORREO, HABILITADO) VALUES (123456, 'PRUEBA', 'Y');

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

CREATE OR REPLACE PROCEDURE CHECK_AGE (fecha IN DATE) AS
BEGIN
	IF 156 > MONTHS_BETWEEN(CURRENT_DATE, fecha) THEN
		RAISE_APPLICATION_ERROR(-20002, 'El usuario aun no tiene 13 años de edad');
	END IF;
END;

-- Reciclamos procedure para chequeo metodo de pago
CREATE OR REPLACE TRIGGER USER_CHECKS BEFORE INSERT OR UPDATE ON USUARIO
FOR EACH ROW
BEGIN
	CHECK_ONLY_ONE_METHOD(:NEW.numTelefono, :NEW.email);
	CHECK_AGE(:NEW.fechaNacimiento);
END;

INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, NUMTELEFONO, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba1', 'El prueba 1', 'notapassword', 'nada muy interesante', '10-JAN-00', 1234, 'asd', 'asd', CURRENT_DATE, 0, 1);
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba2', 'El prueba 2', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', 'asd', 'asd', CURRENT_DATE, 0, 1);
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba3', 'El prueba 3', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', 'asd', 'asd', CURRENT_DATE, 1000, 1);
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba4', 'El prueba 4', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', 'asd', 'asd', CURRENT_DATE, 10000, 2);
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba5', 'El prueba 5', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', 'asd', 'asd', CURRENT_DATE, 10000, 3);

COMMIT;

-- Prueba trigger ambos datos recuperacion definidos
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, NUMTELEFONO, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba6', 'El prueba 6', 'notapassword', 'nada muy interesante', '10-JAN-00', 'TRIGGERFAIL', 1234, 'asd', 'asd', CURRENT_DATE, 0, 1);

-- Prueba trigger edad
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, NUMTELEFONO, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba6', 'El prueba 6', 'notapassword', 'nada muy interesante', '10-JAN-10', 1234, 'asd', 'asd', CURRENT_DATE, 0, 1);

CREATE TABLE Fotos(
	nombreUsuario varchar(50) references Usuario,
	name varchar(50) not null,
	foto blob, --seria una RNE a nivel aplicacion
	PRIMARY KEY(nombreUsuario, name)
);

CREATE OR REPLACE PROCEDURE CHECK_EXTENSION (fotoname IN VARCHAR) AS
	IS_VALID BOOLEAN;
BEGIN
	IF (fotoname Like '%.jpeg' OR fotoname Like '%.png') OR fotoname Like '%.gif' THEN
		IS_VALID := TRUE;
	ELSE
		IS_VALID := FALSE;
	END IF;

	IF NOT IS_VALID THEN
		RAISE_APPLICATION_ERROR(-20008, 'La imagen provista no esta en uno de los formatos aceptados');
	END IF;
END;
--Trigger para validar nombre termina con alguna de las extensiones
--Probar trigger y validar pruebas

CREATE OR REPLACE TRIGGER VALIDATE_IMAGE BEFORE INSERT OR UPDATE ON Fotos
FOR EACH ROW
BEGIN
	CHECK_EXTENSION(:NEW.name);
END;

INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba1','perfil.jpeg');
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba1','banner.png');
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba2','algo.gif');
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba3','otracosa.gif');
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba4','banner.jpeg');
COMMIT;
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba4','banner.jpg');

CREATE TABLE Compra(
	id NUMBER GENERATED AS IDENTITY,
	nombreComprador varchar(50) not null references Usuario,
	medioDePago number not null references MedioDePago,
	cantidad number(10) not null check(cantidad in (300,5000,25000)),
	PRIMARY KEY(id)
)

--Trigger validar medio de pago habilitado
--Trigger aumentar cantidad de bits de usuario

CREATE TABLE Donaciones(
	nombreDonador varChar(50) NOT null references Usuario,
	nombreDonado varChar(50) NOT null references Usuario,
	fechaDonacion date        NOT null,
	monto	      number(20)  NOT null,
	primary key(nombreDonador, nombreDonado, fechaDonacion)
);

--Trigger aumentar cantidad de bits de usuario

CREATE OR REPLACE PROCEDURE CHECK_POSITIVE_AMOUNT(monto IN NUMBER) AS
BEGIN
	IF 0 > monto THEN
		RAISE_APPLICATION_ERROR(-20003, 'El monto de una donacion debe ser mayor a cero');
	END IF;
END;

CREATE OR REPLACE PROCEDURE CHECK_AMOUNT_AVAILABLE(monto IN NUMBER, nombre IN VARCHAR)
IS
    CANTIDAD_DISPONIBLE NUMBER;
BEGIN
   	SELECT bits INTO CANTIDAD_DISPONIBLE FROM USUARIO WHERE nombre = nombrePrivado;

	IF CANTIDAD_DISPONIBLE < monto THEN
		RAISE_APPLICATION_ERROR(-20004, 'El monto de una donacion debe ser menor o igual al saldo de bits del donante');
	END IF;
END;

CREATE OR REPLACE TRIGGER VALIDATE_DONATION BEFORE INSERT OR UPDATE ON DONACIONES
FOR EACH ROW
BEGIN
	CHECK_POSITIVE_AMOUNT(:NEW.monto);
	CHECK_AMOUNT_AVAILABLE(:NEW.monto, :NEW.nombreDonador);
END;

INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba1', CURRENT_DATE, 100);
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba2', CURRENT_DATE, 100);
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba4', CURRENT_DATE, 100);
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba4', 'prueba1', CURRENT_DATE, 100);

-- Prueba trigger cantidad mayor a cero
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba1', CURRENT_DATE, -100);
-- Prueba trigger cantidad menor a la disponible
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba1', CURRENT_DATE, 1011100);

COMMIT;

CREATE TABLE Suscripcion(
	nombreSuscriptor varchar(50) NOT null references usuario,
	nombreSuscripto varchar(50) NOT null references usuario,
	fechaSuscripcion date 	     NOT null,
	fechaRenovacion  date 	     NOT null,
	pais varchar(50) not null,
	medioPago	 number NOT null references MedioDePago,
	primary key(nombreSuscriptor, nombreSuscripto)
);

CREATE OR REPLACE PROCEDURE CHECK_PAYMENTMETHOD_ENABLED(idMetodo IN NUMBER)
IS
    estaHabilitado CHARACTER;
BEGIN
   	SELECT HABILITADO INTO estaHabilitado FROM MEDIODEPAGO WHERE id = idMetodo;

	IF estaHabilitado = 'N' THEN
		RAISE_APPLICATION_ERROR(-20005, 'El metodo de pago seleccionado no esta habilitado');
	END IF;
END;

CREATE OR REPLACE PROCEDURE CHECK_LEVEL(nombre IN VARCHAR)
IS
    NIVELAUX NUMBER;
BEGIN
   	SELECT NIVEL INTO NIVELAUX FROM USUARIO WHERE nombrePrivado = nombre;

	IF NIVELAUX < 2 THEN
		RAISE_APPLICATION_ERROR(-20006, 'No se puede suscribir a un usuario con nivel menor a 2');
	END IF;
END;

CREATE OR REPLACE PROCEDURE CHECK_VALID_DATES(fechaSuscripcion IN DATE, fechaRenovacion IN DATE) IS
BEGIN
	IF fechaSuscripcion > fechaRenovacion THEN
		RAISE_APPLICATION_ERROR(-20007, 'La fecha de renovacion no puede ser previa a la de suscripcion');
	END IF;
END;

CREATE OR REPLACE TRIGGER VALIDAR_SUSCRIPCION BEFORE INSERT OR UPDATE ON SUSCRIPCION
FOR EACH ROW
BEGIN
	CHECK_PAYMENTMETHOD_ENABLED(:NEW.medioPago);
	CHECK_LEVEL(:NEW.nombreSuscripto);
	CHECK_VALID_DATES(:NEW.fechaSuscripcion, :NEW.fechaRenovacion);
END;

INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, medioPago)
VALUES ('prueba1', 'prueba4', CURRENT_DATE, '10-JAN-30', 5);
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, medioPago)
VALUES ('prueba2', 'prueba5', CURRENT_DATE, '10-JAN-30', 2);
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, medioPago)
VALUES ('prueba1', 'prueba5', CURRENT_DATE, '10-JAN-30', 3);

COMMIT;

-- Prueba nivel suscripto
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, medioPago)
VALUES ('prueba5', 'prueba1', CURRENT_DATE, '10-JAN-30', 3);

-- Prueba medio pago no habilitado
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, medioPago)
VALUES ('prueba3', 'prueba5', CURRENT_DATE, '10-JAN-30', 4);

CREATE TABLE Logro( 
	id 		    NUMBER GENERATED AS IDENTITY,
	descripcion 	varchar(100) 	NOT null,
	PRIMARY KEY(id)
);

CREATE TABLE UsuarioLogro(
	nombreUsuario 	varchar(50) NOT null references Usuario,
	idLogro		number NOT null references Logro,
	primary key(nombreUsuario, idLogro)
);

-- No se crean datos falsos en estas tablas por no ser necesarios para probar nada