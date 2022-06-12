PRUEBAS FECHAS

https://www.w3resource.com/oracle/datetime-functions/oracle-months_between-function.php

``` SQL

    CREATE TABLE PruebaFechas(fecha date not null);

    INSERT INTO PruebaFechas (fecha) VALUES ('10-JAN-00');

    SELECT * FROM PruebaFechas;

    MONTHS_BETWEEN('10-JAN-00', '10-JAN-22');

    SELECT MONTHS_BETWEEN('10-JAN-22', '10-JAN-00') FROM PruebaFechas; -- da 264

    SELECT MONTHS_BETWEEN(CURRENT_DATE, '10-JAN-00') FROM PruebaFechas; -- da 264

    SELECT * FROM PruebaFechas WHERE 200 < MONTHS_BETWEEN(CURRENT_DATE, fecha)

```

PRUEBAS USUARIOS

Esta comentada la referencia a mediodepago porque si no falla creacion de la tabla.

``` sql

DROP TABLE Usuario;

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
    nivel           number(1)    not null check(nivel in (1,2,3))--,
    --medioPagoPred   varChar(20)  references MedioDePago
);

CREATE OR REPLACE TRIGGER VALIDAR_METODO_RECUPERACION_UNICO
BEFORE INSERT OR UPDATE ON Usuario
FOR EACH ROW
DECLARE
	TEL_DEFINIDO  BOOLEAN;
	MAIL_DEFINIDO BOOLEAN;
BEGIN
	IF :NEW.numTelefono IS NULL THEN
		TEL_DEFINIDO := FALSE;
	ELSE
		TEL_DEFINIDO := TRUE;
	END IF;

	IF :NEW.email IS NULL THEN
		MAIL_DEFINIDO := FALSE;
	ELSE
		MAIL_DEFINIDO := TRUE;
	END IF;

	IF (MAIL_DEFINIDO AND TEL_DEFINIDO) OR (NOT (MAIL_DEFINIDO OR TEL_DEFINIDO)) THEN
		RAISE_APPLICATION_ERROR(-20001, 'No pueden estar definidos ambos metodos de recuperacion');
	END IF;
END;

CREATE OR REPLACE TRIGGER VALIDAR_EDAD_MIN_USUARIO BEFORE INSERT OR UPDATE ON Usuario
FOR EACH ROW
BEGIN
	-- se compara con la cantidad de meses (12x13=>156)
	IF 156 > MONTHS_BETWEEN(CURRENT_DATE, :NEW.fechaNacimiento) THEN
		RAISE_APPLICATION_ERROR(-20003, 'El usuario aun no tiene 13 años de edad');
	END IF;
END;

-- prueba datos validos
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, NUMTELEFONO, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba1', 'El prueba 1', 'notapassword', 'nada muy interesante', '10-JAN-00', 1234, 'asd', 'asd', CURRENT_DATE, 0, 1);

-- prueba ambos datos recuperacion definidos
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, NUMTELEFONO, EMAIL, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba2', 'El prueba 2', 'notapassword', 'nada muy interesante', '10-JAN-00', 1234, 'pruebaTrigger', 'asd', 'asd', CURRENT_DATE, 0, 1);

-- prueba menor 13 años
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, NUMTELEFONO, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba3', 'El prueba 3', 'notapassword', 'nada muy interesante', '10-JAN-20', 1234, 'asd', 'asd', CURRENT_DATE, 0, 1);
```



Clase cursores, requerimientos 1 y 3 al parecer https://vimeopro.com/universidadortfi/fi-3839-bases-de-datos-2-61531-n5a-id/video/703576796 a partir de 1:35

1:41 primer cursor, usa funcion tambien.

Funciones esta clase min 1:22 https://vimeopro.com/universidadortfi/fi-3839-bases-de-datos-2-61531-n5a-id/video/696393071

Procedimientos https://vimeopro.com/universidadortfi/fi-3839-bases-de-datos-2-61531-n5a-id/video/693838569 min 12

``` SQL

CREATE OR REPLACE PROCEDURE CHECK_ONLY_ONE_METHOD (num IN NUMBER, mail IN VARCHAR)
IS --es necesario el AS?
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
		RAISE_APPLICATION_ERROR(-20001, 'No pueden estar definidos ambos metodos de recuperacion, pero al menos uno es necesario.');
	END IF;
END;

-- esto compila, probar hacer funciones para todo y simplemente llamarlas desde los trigger

CREATE OR REPLACE PROCEDURE CHECK_AGE (fecha IN DATE) AS
BEGIN
	IF 156 > MONTHS_BETWEEN(CURRENT_DATE, fecha) THEN
		RAISE_APPLICATION_ERROR(-20002, 'El usuario aun no tiene 13 años de edad');
	END IF;
END;

CREATE OR REPLACE TRIGGER USER_CHECKS BEFORE INSERT OR UPDATE ON USUARIO
FOR EACH ROW
BEGIN
	CHECK_ONLY_ONE_METHOD(:NEW.numTelefono, :NEW.email);
	CHECK_AGE(:NEW.fechaNacimiento);
END;

-- anda perfecto, nos vamos a apoyar en esto para la creacion del trigger para mediodepago, capaz lo ideal es crear el proc y esa tabla primero
```

MEDIO DE PAGO

``` SQL
-- esta tabla la creamos para no tener tablas separadas y dos fk en usuario, es 
-- una manera de mantener la info centralizada mediante el uso del trigger
CREATE TABLE MedioDePago(
	id 		    NUMBER GENERATED AS IDENTITY,
	numero 		number(10),
	correo 		varchar(50),
	habilitado 	char(1) NOT null, -- Y O N
    PRIMARY KEY(id)
);

CREATE OR REPLACE TRIGGER VALIDAR_METODO_PAGO_UNICO BEFORE INSERT OR UPDATE ON MedioDePago
FOR EACH ROW
BEGIN
	CHECK_ONLY_ONE_METHOD(:NEW.numero, :NEW.correo);
END;

-- PARA LOS INSERT USAR SYS_GUID


INSERT INTO MEDIODEPAGO (NUMERO, HABILITADO) VALUES (12345, 'Y');
INSERT INTO MEDIODEPAGO (NUMERO, HABILITADO) VALUES (133345, 'Y');
INSERT INTO MEDIODEPAGO (NUMERO, HABILITADO) VALUES (1235645, 'Y');
INSERT INTO MEDIODEPAGO (NUMERO, HABILITADO) VALUES (123415, 'N');
INSERT INTO MEDIODEPAGO (CORREO, HABILITADO) VALUES ('PRUEBA@MAIL.COM', 'Y');
INSERT INTO MEDIODEPAGO (CORREO, HABILITADO) VALUES ('USUARIO@USUARIO.USUARIO', 'N');
```

Tema donaciones
``` SQL

CREATE TABLE Donaciones(
	nombreDonador varChar(50) NOT null references Usuario,
	nombreDonado varChar(50) NOT null references Usuario,
	fechaDonacion date        NOT null,
	monto	      number(20)  NOT null,
	primary key(nombreDonador, nombreDonado, fechaDonacion)
);

-- Funcion para checkear que el monto sea positivo
CREATE OR REPLACE PROCEDURE CHECK_POSITIVE_AMOUNT(monto IN NUMBER) AS
BEGIN
	IF 0 > monto THEN
		RAISE_APPLICATION_ERROR(-20003, 'El monto de una donacion debe ser mayor a cero');
	END IF;
END;

-- Funcion para checkear que el monto a transferir sea mayor al saldo del donador
CREATE OR REPLACE PROCEDURE CHECK_AMOUNT_AVAILABLE(monto IN NUMBER, nombre IN VARCHAR)
IS --es necesario el AS/IS claramente si?
    CANTIDAD_DISPONIBLE NUMBER;
BEGIN
   	SELECT bits INTO CANTIDAD_DISPONIBLE FROM USUARIO WHERE nombre = nombrePrivado;

	IF CANTIDAD_DISPONIBLE < monto THEN
		RAISE_APPLICATION_ERROR(-20004, 'El monto de una donacion debe ser menor o igual al saldo de bits del donante');
	END IF;
END;

-- Trigger que unifica

CREATE OR REPLACE TRIGGER VALIDATE_DONATION BEFORE INSERT OR UPDATE ON DONACIONES
FOR EACH ROW
BEGIN
	CHECK_POSITIVE_AMOUNT(:NEW.monto);
	CHECK_AMOUNT_AVAILABLE(:NEW.monto, :NEW.nombreDonador);
END;


-- prueba datos validos
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, NUMTELEFONO, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba1', 'El prueba 1', 'notapassword', 'nada muy interesante', '10-JAN-00', 1234, 'asd', 'asd', CURRENT_DATE, 0, 1);

-- prueba ambos datos recuperacion definidos
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba2', 'El prueba 2', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', 'asd', 'asd', CURRENT_DATE, 0, 1);

INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba3', 'El prueba 3', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', 'asd', 'asd', CURRENT_DATE, 1000, 1);

--DONACION VALIDA 
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba1', CURRENT_DATE, 100);

--DONACION MONTO NEGATIVO
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba2', 'prueba1', CURRENT_DATE, -100);

--DONACION MONTO MAYOR AL DISPONIBLE
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba2', 'prueba1', CURRENT_DATE, 100);



```


``` SQL

CREATE TABLE Suscripcion(
	nombreSuscriptor varchar(50) NOT null references usuario,
	nombreSuscripto varchar(50) NOT null references usuario,
	fechaSuscripcion date 	     NOT null,
	fechaRenovacion  date 	     NOT null,
	medioPago	 number NOT null references MedioDePago,
	primary key(nombreSuscriptor, nombreSuscripto)
);


-- USUARIOS AUXILIARES CON NIVEL PARA PROBAR SUSCRIPCIONES
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba4', 'El prueba 4', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', 'asd', 'asd', CURRENT_DATE, 10000, 2);

INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, URIFOTO, URIBANNER, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba5', 'El prueba 5', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', 'asd', 'asd', CURRENT_DATE, 10000, 3);

-- Funcion validar suscripto nivel >= 2
-- Chequear medio de pago esta habilidado
-- Chequear fechaRenovacion > fechaSuscripcion

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

-- pruebas valores invalidos
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, medioPago)
VALUES ('prueba1', 'prueba5', '10-JAN-40', '10-JAN-30', 2);

INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, medioPago)
VALUES ('prueba3', 'prueba5', CURRENT_DATE, '10-JAN-30', 4);

INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, medioPago)
VALUES ('prueba5', 'prueba1', CURRENT_DATE, '10-JAN-30', 3);
```