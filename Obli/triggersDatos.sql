CREATE OR REPLACE PROCEDURE VALIDAR_SOLO_UNO_DEFINIDO (num IN NUMBER, mail IN VARCHAR)
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
	VALIDAR_SOLO_UNO_DEFINIDO(:NEW.numero, :NEW.correo);
END;

CREATE OR REPLACE PROCEDURE VALIDAR_EDAD (fecha IN DATE) AS
BEGIN
	IF 156 > MONTHS_BETWEEN(CURRENT_DATE, fecha) THEN
		RAISE_APPLICATION_ERROR(-20002, 'El usuario aun no tiene 13 años de edad');
	END IF;
END;

-- Reciclamos procedure para chequeo metodo de pago
CREATE OR REPLACE TRIGGER USER_CHECKS BEFORE INSERT OR UPDATE ON USUARIO
FOR EACH ROW
BEGIN
	VALIDAR_SOLO_UNO_DEFINIDO(:NEW.numTelefono, :NEW.email);
	VALIDAR_EDAD(:NEW.fechaNacimiento);
END;

CREATE OR REPLACE PROCEDURE VALIDAR_EXTENSION (fotoname IN VARCHAR) AS
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

CREATE OR REPLACE TRIGGER VALIDAR_IMAGEN BEFORE INSERT OR UPDATE ON Fotos
FOR EACH ROW
BEGIN
	VALIDAR_EXTENSION(:NEW.name);
END;

CREATE OR REPLACE PROCEDURE AUMENTAR_CANTIDAD_BITS(nombre IN VARCHAR, cantidad IN NUMBER) AS
	CANTIDAD_PREVIA NUMBER;
BEGIN
	SELECT bits INTO CANTIDAD_PREVIA FROM Usuario WHERE nombrePrivado = nombre;
	UPDATE Usuario SET bits = (CANTIDAD_PREVIA + cantidad) WHERE nombrePrivado = nombre;
END;

CREATE OR REPLACE PROCEDURE VALIDAR_METODOPAGO_HABILITADO(idMetodo IN NUMBER)
IS
    estaHabilitado CHARACTER;
BEGIN
   	SELECT HABILITADO INTO estaHabilitado FROM MEDIODEPAGO WHERE id = idMetodo;

	IF estaHabilitado = 'N' THEN
		RAISE_APPLICATION_ERROR(-20005, 'El metodo de pago seleccionado no esta habilitado');
	END IF;
END;

CREATE OR REPLACE TRIGGER VALIDAR_COMPRA_BITS BEFORE INSERT OR UPDATE ON COMPRA
FOR EACH ROW
BEGIN
	VALIDAR_METODOPAGO_HABILITADO(:NEW.medioDePago);
	AUMENTAR_CANTIDAD_BITS(:NEW.nombreComprador, :NEW.cantidad);
END;

CREATE OR REPLACE PROCEDURE REDUCIR_CANTIDAD_BITS(nombre IN VARCHAR, cantidad IN NUMBER) AS
	CANTIDAD_PREVIA NUMBER;
BEGIN
	SELECT bits INTO CANTIDAD_PREVIA FROM Usuario WHERE nombrePrivado = nombre;
	UPDATE Usuario SET bits = (CANTIDAD_PREVIA - cantidad) WHERE nombrePrivado = nombre;
END;

CREATE OR REPLACE PROCEDURE VALIDAR_CANTIDAD_POSITIVA(monto IN NUMBER) AS
BEGIN
	IF 0 > monto THEN
		RAISE_APPLICATION_ERROR(-20003, 'El monto de una donacion debe ser mayor a cero');
	END IF;
END;

CREATE OR REPLACE PROCEDURE VALIDAR_CANTIDAD_DISPONIBLE(monto IN NUMBER, nombre IN VARCHAR)
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
	VALIDAR_CANTIDAD_POSITIVA(:NEW.monto);
	VALIDAR_CANTIDAD_DISPONIBLE(:NEW.monto, :NEW.nombreDonador);
	AUMENTAR_CANTIDAD_BITS(:NEW.nombreDonado, :NEW.monto);
	REDUCIR_CANTIDAD_BITS(:NEW.nombreDonador, :NEW.monto);
END;

CREATE OR REPLACE PROCEDURE VALIDAR_NIVEL(nombre IN VARCHAR)
IS
    NIVELAUX NUMBER;
BEGIN
   	SELECT NIVEL INTO NIVELAUX FROM USUARIO WHERE nombrePrivado = nombre;

	IF NIVELAUX < 2 THEN
		RAISE_APPLICATION_ERROR(-20006, 'No se puede suscribir a un usuario con nivel menor a 2');
	END IF;
END;

CREATE OR REPLACE PROCEDURE VALIDAR_FECHAS(fechaSuscripcion IN DATE, fechaRenovacion IN DATE) IS
BEGIN
	IF fechaSuscripcion > fechaRenovacion THEN
		RAISE_APPLICATION_ERROR(-20007, 'La fecha de renovacion no puede ser previa a la de suscripcion');
	END IF;
END;

CREATE OR REPLACE TRIGGER VALIDAR_SUSCRIPCION BEFORE INSERT OR UPDATE ON SUSCRIPCION
FOR EACH ROW
BEGIN
	VALIDAR_METODOPAGO_HABILITADO(:NEW.medioPago);
	VALIDAR_NIVEL(:NEW.nombreSuscripto);
	VALIDAR_FECHAS(:NEW.fechaSuscripcion, :NEW.fechaRenovacion);
END;