-- INSERCION USUARIOS VALIDOS
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, NUMTELEFONO, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba1', 'El prueba 1', 'notapassword', 'nada muy interesante', '10-JAN-00', 1234, CURRENT_DATE, 0, 1);
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba2', 'El prueba 2', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', CURRENT_DATE, 0, 1);
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba3', 'El prueba 3', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', CURRENT_DATE, 1000, 1);
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba4', 'El prueba 4', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', CURRENT_DATE, 10000, 2);
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba5', 'El prueba 5', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', CURRENT_DATE, 10000, 3);
COMMIT;
--SELECT * FROM USUARIO;

-- INSERCION FOTOS VALIDAS
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba1','perfil.jpeg');
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba1','banner.png');
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba2','algo.gif');
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba3','otracosa.gif');
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba4','banner.jpeg');
COMMIT;
--SELECT * FROM FOTOS;

-- INSERCION LOGROS VALIDOS
INSERT INTO LOGRO (descripcion) VALUES ('Streamear por una hora');
INSERT INTO LOGRO (descripcion) VALUES ('Streamear por diez horas');
INSERT INTO LOGRO (descripcion) VALUES ('Obtener tu primer suscriptor');
INSERT INTO LOGRO (descripcion) VALUES ('Streamear cinco dias consecutivos');
COMMIT;
--SELECT * FROM LOGRO;

-- INSERCION USUARIOLOGROS VALIDOS
INSERT INTO USUARIOLOGRO (nombreUsuario, idLogro) VALUES ('prueba1', 1);
INSERT INTO USUARIOLOGRO (nombreUsuario, idLogro) VALUES ('prueba2', 1);
INSERT INTO USUARIOLOGRO (nombreUsuario, idLogro) VALUES ('prueba3', 1);
INSERT INTO USUARIOLOGRO (nombreUsuario, idLogro) VALUES ('prueba1', 2);
INSERT INTO USUARIOLOGRO (nombreUsuario, idLogro) VALUES ('prueba3', 3);
COMMIT;
--SELECT * FROM USUARIOLOGRO;

-- Insercion datos validos
INSERT INTO MEDIODEPAGO (nombreUsuario, numero, habilitado) VALUES ('prueba1', 12345, 'Y');
INSERT INTO MEDIODEPAGO (nombreUsuario, numero, habilitado) VALUES ('prueba2', 133345, 'Y');
INSERT INTO MEDIODEPAGO (nombreUsuario, numero, habilitado) VALUES ('prueba3', 1235645, 'Y');
INSERT INTO MEDIODEPAGO (nombreUsuario, numero, habilitado) VALUES ('prueba3', 123415, 'N');
INSERT INTO MEDIODEPAGO (nombreUsuario, correo, habilitado) VALUES ('prueba2', 'PRUEBA@MAIL.COM', 'Y');
INSERT INTO MEDIODEPAGO (nombreUsuario, correo, habilitado) VALUES ('prueba1', 'USUARIO@USUARIO.USUARIO', 'N');
COMMIT;
--SELECT * FROM MEDIODEPAGO;

-- Insercion compras validas, interesante ver como el trigger dispara cambios en los saldos de bits de los usuarios
--SELECT nombrePrivado, bits FROM USUARIO;
INSERT INTO COMPRA (nombreComprador, medioDePago, cantidad) VALUES ('prueba1', 1, 5000);
INSERT INTO COMPRA (nombreComprador, medioDePago, cantidad) VALUES ('prueba2', 2, 300);
INSERT INTO COMPRA (nombreComprador, medioDePago, cantidad) VALUES ('prueba2', 2, 25000);
COMMIT;
--SELECT nombrePrivado, bits FROM USUARIO;
--SELECT * FROM COMPRA;

-- Insercion donaciones validas, interesante ver como el trigger dispara cambios en los saldos de bits de los usuarios
--SELECT nombrePrivado, bits FROM USUARIO;
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba1', CURRENT_DATE, 100);
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba2', CURRENT_DATE, 100);
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba4', CURRENT_DATE, 100);
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba4', 'prueba1', CURRENT_DATE, 100);
COMMIT;
--SELECT nombrePrivado, bits FROM USUARIO;
--SELECT * FROM DONACIONES;

-- Insercion suscripciones validas
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, pais, medioPago)
VALUES ('prueba1', 'prueba4', CURRENT_DATE, '10-JAN-30', 'Uruguay', 5);
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, pais, medioPago)
VALUES ('prueba2', 'prueba5', CURRENT_DATE, '10-JAN-30', 'Argentina', 2);
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, pais, medioPago)
VALUES ('prueba1', 'prueba5', CURRENT_DATE, '10-JAN-30', 'Brasil', 3);
COMMIT;
--SELECT * FROM SUSCRIPCION;