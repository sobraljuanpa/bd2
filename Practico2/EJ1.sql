-- 2.1. “Verificar que la fecha de las postulaciones sea mayor que la fecha desde la que está disponible la
-- oferta.”
CREATE OR REPLACE TRIGGER VALIDAR_FECHA_POSTULACION
BEFORE INSERT OR UPDATE ON POSTULACION
FOR EACH ROW
DECLARE
    V_FECHA DATE;
BEGIN
    --SE OBTIENE FECHA DESDE LA CUAL ESTA DISPONIBLE LA OFERTA
    SELECT disponibleDesde INTO V_FECHA FROM OFERTATRABAJO WHERE nroreferencia = :NEW.nroreferencia;
    
    IF :NEW.fechapostulacion < V_FECHA THEN
        RAISE_APPLICATION_ERROR(-20001, 'La fecha de postulacion debe ser mayor o igual a la fecha de la oferta');
    END IF;
END;

-- para probarlo
SELECT DISPONIBLEDESDE FROM OFERTATRABAJO WHERE NROREFERENCIA = 2;
SELECT * FROM POSTULACION WHERE NROREFERENCIA = 2;

UPDATE POSTULACION SET FECHAPOSTULACION = '03-SEP-08' WHERE NROREFERENCIA = 2; --Preguntar aca si hay que suar algun formato de fecha especifico


-- 2.2. “Para todo interesado debe haber siempre por lo menos una postulación a algún trabajo.”

CREATE OR REPLACE TRIGGER VALIDAR_POSTULACIONMIN_INTERESADO BEFORE INSERT OR UPDATE ON INTERESADO
FOR EACH ROW -- QUE HACE ESTO?
DECLARE CANTPOSTULACIONES NUMERIC;
BEGIN
    SELECT COUNT(*) INTO CANTPOSTULACIONES FROM POSTULACION WHERE ci = :NEW.ci;

    IF CANTPOSTULACIONES < 1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El interesado debe haber postulado al menos a una oferta');
    END IF;
END;

-- para probarlo
SELECT * FROM INTERESADO;
insert into Interesado ( ci, nombre, fNac, sexo, domicilio, cvPath) values (11,'Interesado 11',to_date('23/10/1982','dd/mm/yyyy'),'M','Domicilio 11','c:\CV11');  
update interesado set nombre = 'interesado 1 uno' where ci = 1;
-- 2.3. “Verificar que para toda postulación, la edad del postulante siempre sea mayor o igual a la edad
-- mínima requerida para el cargo.”
CREATE OR REPLACE TRIGGER VALIDAR_EDAD_MIN_POSTULANTE BEFORE INSERT OR UPDATE ON POSTULACION
FOR EACH ROW
DECLARE CUMPLE_REQ CHAR;
BEGIN
    SELECT CUMPLE INTO CUMPLE_REQ FROM POST_CUMPLE_REQ WHERE ci = :NEW.ci AND nroReferencia = :NEW.nroReferencia;
-- 2.4. “Un mismo interesado no debe postularse más de una vez a la misma oferta.”
CREATE OR REPLACE TRIGGER VALIDAR_POSTULACION_UNICA BEFORE INSERT OR UPDATE ON POSTULACION
FOR EACH ROW
DECLARE CANTPOSTULACIONES NUMERIC;
BEGIN
    SELECT COUNT(*) INTO CANTPOSTULACIONES FROM POSTULACION WHERE ci = :NEW.ci AND nroReferencia = :NEW.nroReferencia;

    IF CANTPOSTULACIONES > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'El interesado ya postulo a la oferta indicada');
    END IF;
END;

-- aca preguntar si tendria uqe hacer otra regla para el udpate o si hay alguna forma de cambiar el chequeo segun si es un insert o un update
SELECT * FROM POSTULACION;
insert into Postulacion ( ci, nroReferencia, fechaPostulacion, aspiraciones) values (1,1,to_date('02/09/2009','dd/mm/yyyy'),12000);
-- 2.5. “Verificar que un interesado no se postule a todas las ofertas en un período menor a 2 horas.”

-- 2.6. “No se deben aceptar postulaciones a las cuales el postulante no cumpla con todos los requisitos
-- excluyentes”
CREATE OR REPLACE TRIGGER VALIDAR_REQS_POSTULACION BEFORE INSERT OR UPDATE ON POSTULACION
FOR EACH ROW
DECLARE REQS_NO_CUMPLIDOS NUMERIC;
BEGIN
    SELECT COUNT(*) INTO REQS_NO_CUMPLIDOS FROM POST_CUMPLE_REQ WHERE
        ci = :NEW.ci AND nroReferencia = :NEW.nroReferencia AND cumple = 'N';
    
    IF REQS_NO_CUMPLIDOS > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'El interesado no cumple con los requisitos de la postulacion');
    END IF;
END;

--- para preguntar ----

--manejo de listas, onda cargar una lista a una variable y recorrerla desp
--si se puede modificar un chequeo para que funcione de una forma con update y otra con insert o tengo que crear dos
--como resolver el 2.5
