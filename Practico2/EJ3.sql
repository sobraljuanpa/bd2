DROP TABLE Pais;
DROP TABLE Tren;
DROP TABLE Terminal;
DROP TABLE Tramo;
DROP TABLE Registro;

CREATE TABLE Pais(
    idPais varchar(10) not null primary key,
    nombre varchar(50) not null
);

CREATE TABLE Tren(
    idTren               varchar(20) not null primary key,
    modelo               varchar(50) not null,
    año                  date        not null,
    kmRecorridos         number(10)  not null,
    velocidadCrucero_kph number(4)   not null check (velocidadCrucero_kph > 0),
    velocidadMaxima_kph  number(4)   not null check (velocidadMaxima_kph > 0)
);

CREATE TABLE Terminal(
    idTerminal        varchar(20) not null primary key,
    nombreCiudad      varchar(50) not null unique,
    idPais            varchar(10) not null references Pais,
    capacidadTerminal number(10)  not null check (capacidadTerminal > 500)
);

CREATE TABLE Tramo(
    idTerminalOrigen  varchar(20) not null references Terminal,
    idTerminalDestino varchar(20) not null references Terminal,
    distanciaKm       number(5)   not null check (distanciaKm > 10),
    primary key (idTerminalOrigen, idTerminalDestino)
);

CREATE TABLE Registro(
    fechaRegistro    date        not null,
    idOrigen         varchar(20) not null references Terminal,
    idDestino        varchar(20) not null references Terminal,
    idTren           varchar(20) not null references Tren,
    duracionViaje_hs number(5)   not null check (duracionViaje_hs > 0),
    primary key (fechaRegistro, idOrigen, idDestino, idTren)
);

-----------------------------
---------------------PARTE 2
-----------------------------

--  Dar el SQL necesario para implementar las siguientes restricciones:
-- 2.1. “El registro de la duración de un viaje no puede ser superior al tiempo que le llevaría al tren recorrer la
-- distancia del trayecto a velocidad crucero, ni inferior que viajando a velocidad máxima.”
-- 2.2. “La distancia total recorrida por cada tren, no puede ser inferior a la suma de las distancias de los
-- tramos recorridos por dicho tren.”
-- 2.3. “La velocidad crucero del tren no puede superar a su velocidad máxima.”
-- 2.4. “A partir del 01/Ene/2010, los trenes que realicen viajes entre ciudades de distintos países, no pueden
-- ser anteriores al año 2005 y no pueden tener más de 1.000.000 km recorridos.”

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