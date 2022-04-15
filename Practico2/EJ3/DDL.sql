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