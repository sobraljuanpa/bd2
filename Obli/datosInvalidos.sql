-- =========================================================================================================
-- Importante, es necesario tener los datos validos insertados previamente para probar estos datos invalidos
-- =========================================================================================================

-- Prueba usuario con nivel invalido (rango 1 a 3 por letra)
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba6', 'El prueba 6', 'notapassword', 'nada muy interesante', '10-JAN-00', 'pruebaTrigger', CURRENT_DATE, 10000, 5);

-- Prueba usuario con edad menor a 13
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, NUMTELEFONO, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba6', 'El prueba 6', 'notapassword', 'nada muy interesante', '10-JAN-10', 1234, CURRENT_DATE, 0, 1);

-- Prueba usuario con ambos datos de recuperacion definidos
INSERT INTO USUARIO (NOMBREPRIVADO, NOMBREPUBLICO, CONTRASEÑA, BIOGRAFIA, FECHANACIMIENTO, EMAIL, NUMTELEFONO, FECHACREACION, BITS, NIVEL) 
VALUES ('prueba6', 'El prueba 6', 'notapassword', 'nada muy interesante', '10-JAN-00', 'TRIGGERFAIL', 1234, CURRENT_DATE, 0, 1);

-- Prueba compra de bits cantidad invalida ({300,5000,25000} cantidades validas por letra)
INSERT INTO COMPRA (nombreComprador, medioDePago, cantidad) VALUES ('prueba1', 1, 35000);

-- Prueba formato de imagen invalido
INSERT INTO FOTOS (nombreUsuario, name) VALUES ('prueba4','banner.jpg');

-- Prueba nivel usuario al que se suscriben < 2
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, pais, medioPago)
VALUES ('prueba5', 'prueba1', CURRENT_DATE, '10-JAN-30', 'Uruguay', 3);

-- =========================================================================================================
-- Chequeos mas alla de los planteados en la letra
-- =========================================================================================================

-- Prueba medio pago no habilitado en suscripcion
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, pais, medioPago)
VALUES ('prueba3', 'prueba5', CURRENT_DATE, '10-JAN-30', 'Uruguay', 4);

-- Prueba fecha renovacion previa a suscripcion
INSERT INTO SUSCRIPCION (nombreSuscriptor, nombreSuscripto, fechaSuscripcion, fechaRenovacion, pais, medioPago)
VALUES ('prueba3', 'prueba5', CURRENT_DATE, '10-JAN-15', 'Uruguay', 1);

-- Prueba cantidad de donacion mayor al saldo disponible
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba1', CURRENT_DATE, 9011100);

-- Prueba trigger cantidad de donacion menor a cero
INSERT INTO DONACIONES (NOMBREDONADOR, NOMBREDONADO, FECHADONACION, MONTO) 
VALUES ('prueba3', 'prueba1', CURRENT_DATE, -100);