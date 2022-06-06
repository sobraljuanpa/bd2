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

```