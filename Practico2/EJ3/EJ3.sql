--  Dar el SQL necesario para implementar las siguientes restricciones:
-- 2.1. “El registro de la duración de un viaje no puede ser superior al tiempo que le llevaría al tren recorrer la
-- distancia del trayecto a velocidad crucero, ni inferior que viajando a velocidad máxima.”

CREATE OR REPLACE TRIGGER VALIDAR_DURACION_VIAJE
BEFORE INSERT OR UPDATE ON Registro
FOR EACH ROW
DECLARE
    VCRUCERO NUMERIC;
    VMAXIMA NUMERIC;
    DISTANCIA NUMERIC;
BEGIN
    SELECT velocidadCrucero_kph INTO VCRUCERO FROM Tren WHERE idTren = :NEW.idTren;
    SELECT velocidadMaxima_kph INTO VMAXIMA FROM Tren WHERE idTren = :NEW.idTren;
    SELECT distanciaKm INTO DISTANCIA FROM Tramo WHERE idTerminalOrigen = :NEW.idOrigen AND idTerminalDestino = :NEW.idDestino;

    IF :NEW.duracionViaje_hs > DISTANCIA / VCRUCERO THEN
        RAISE_APPLICATION_ERROR(-20041, 'La duracion del viaje es mayor al tiempo que llevaria recorrer la distancia a velocidad crucero');
    END IF;
    IF :NEW.duracionViaje_hs < DISTANCIA / VMAXIMA THEN
        RAISE_APPLICATION_ERROR(-20042, 'La duracion del viaje es menor al tiempo que llevaria recorrer la distancia a velocidad maxima');
    END IF;
END;

insert into Tren (idTren, modelo, año, kmRecorridos, velocidadCrucero_kph, velocidadMaxima_kph) values ('Tren balin','Balin 500',to_date('31/08/2009','dd/mm/yyyy'),0,100,150);
commit;
select * from Tren;

insert into Pais (idPais, nombre) values ('URY','Uruguay');
insert into Terminal (idTerminal, nombreCiudad, idPais, capacidadTerminal) values ('MVD', 'Montevideo', 'URY', 501);
insert into Terminal (idTerminal, nombreCiudad, idPais, capacidadTerminal) values ('SJS', 'San Jose', 'URY', 502);
commit;
select * from Pais;
select * from Terminal;

insert into Tramo (idTerminalOrigen, idTerminalDestino, distanciaKm) values ('MVD', 'SJS', 60);
commit;
select * from Tramo;

insert into Registro (fechaRegistro, idOrigen, idDestino, idTren, duracionViaje_hs) values (to_date('31/08/2009','dd/mm/yyyy'),'MVD','SJS','Tren balin', 5);
insert into Registro (fechaRegistro, idOrigen, idDestino, idTren, duracionViaje_hs) values (to_date('31/08/2009','dd/mm/yyyy'),'MVD','SJS','Tren balin', 0.1);
--averiguar por que no me esta andando con velocidad crucero 0.5
-- es un tema de casteos

-- 2.2. “La distancia total recorrida por cada tren, no puede ser inferior a la suma de las distancias de los
-- tramos recorridos por dicho tren.”

CREATE OR REPLACE TRIGGER VALIDAR_DISTANCIA_TOTAL
BEFORE INSERT OR UPDATE ON Tren
FOR EACH ROW
DECLARE
    DISTANCIARECORRIDA NUMERIC;
BEGIN
    SELECT SUM(Tramo.distanciaKM) INTO DISTANCIARECORRIDA
    FROM Registro INNER JOIN Tramo
        ON Registro.idOrigen = tramo.idterminalorigen
        AND Registro.idDestino = tramo.idterminaldestino
    WHERE Registro.idTren = :NEW.idTren;

    IF :NEW.kmRecorridos < DISTANCIARECORRIDA THEN
        RAISE_APPLICATION_ERROR(-20043, 'La distancia recorrida es inferior a la suma de los tramos realizados');
    END IF;
END;


-- 2.3. “La velocidad crucero del tren no puede superar a su velocidad máxima.”

CREATE OR REPLACE TRIGGER VALIDAR_VELOCIDADES
BEFORE INSERT OR UPDATE ON Tren
FOR EACH ROW
BEGIN
    IF :NEW.velocidadMaxima_kph < :NEW.velocidadCrucero_kph THEN
        RAISE_APPLICATION_ERROR(-20044, 'La velocidad maxima es menor que la velocidad crucero');
    END IF;
END;

-- 2.4. “A partir del 01/Ene/2010, los trenes que realicen viajes entre ciudades de distintos países, no pueden
-- ser anteriores al año 2005 y no pueden tener más de 1.000.000 km recorridos.”
CREATE OR REPLACE TRIGGER VALIDAR_DATOS_VIAJES_INTERNACIONALES
BEFORE INSERT OR UPDATE ON Registro
FOR EACH ROW
DECLARE
    DISTANCIARECORRIDA NUMERIC;
    IDPAIS1 VARCHAR;
    IDPAIS2 VARCHAR;
BEGIN
    IF :NEW.fechaRegistro > (to_date('1/1/2010','dd/mm/yyyy')) THEN
        SELECT idPais INTO IDPAIS1 FROM Terminal WHERE Terminal.idTerminal = :NEW.idOrigen;
        SELECT idPais INTO IDPAIS2 FROM Terminal WHERE Terminal.idTerminal = :NEW.idDestino;
        IF IDPAIS1 != IDPAIS2 THEN
            SELECT SUM(Tramo.distanciaKM) INTO DISTANCIARECORRIDA
            FROM Registro INNER JOIN Tramo
                ON Registro.idOrigen = tramo.idterminalorigen
                AND Registro.idDestino = tramo.idterminaldestino
            WHERE Registro.idTren = :NEW.idTren;

            IF DISTANCIARECORRIDA > 1000000 THEN
                RAISE_APPLICATION_ERROR(-20045, 'El tren dado ha recorrido mas de 1 millon de kms y no puede ser usado para viajes internacionales');
            END IF;
        END IF;
    END IF;
END;