-- TRIGGER 1:
CREATE OR REPLACE TRIGGER CHECK_INTEGRIDAD
BEFORE INSERT ON partidos
FOR EACH ROW
DECLARE 
    flag NUMBER;
BEGIN
    SELECT COUNT(*) INTO flag
    FROM partidos 
    WHERE temporada = :NEW.temporada AND division = :NEW.division AND numJornada = :NEW.numJornada AND 
        (local = :NEW.visitante OR visitante = :NEW.visitante);
        
    IF flag >= 1 THEN
        RAISE_APPLICATION_ERROR (-20000, 'Un equipo no puede jugar como local y visitante en la misma jornada.');
    END IF;
END; 
/


-- -- TRIGGER 2:
-- CREATE OR REPLACE TRIGGER OK_DIV
-- BEFORE INSERT ON jornadas
-- FOR EACH ROW
-- BEGIN
--     IF NOT (:NEW.division = '1ª' OR :NEW.division = '2ª' OR :NEW.division = 'Promoción a 1ª' OR :NEW.division = 'Promoción 1ª/2ª' OR :NEW.division = 'Descenso a 2ª') THEN 
--         RAISE_APPLICATION_ERROR (-20001, 'No existe la división que se ha tratado de introducir');
--     END IF;
-- END;
-- /

-- -- TRIGGER 3:
-- CREATE OR REPLACE TRIGGER OK_ASC_DES_EU
-- BEFORE INSERT ON resultados
-- FOR EACH ROW
-- BEGIN
--     IF (:NEW.asciende = 1 AND :NEW.desciende = 1) THEN 
--         RAISE_APPLICATION_ERROR (-20002, 'Un equipo no puede ascender y descender simultáneamente.');
--     ELSIF (:NEW.asciende = 1 AND :NEW.europa = 1) THEN
--         RAISE_APPLICATION_ERROR (-20003, 'Un equipo no puede ascender e ir a europa simultáneamente.');
--     ELSIF (:NEW.division = '2ª' AND (:NEW.desciende = 1 OR :NEW.europa = 1)) THEN
--         RAISE_APPLICATION_ERROR (-20004, 'Un equipo de segunda división no puede ni descender, ni ir a europa.');
--     ELSIF (:NEW.division = '1ª' AND :NEW.asciende = 1) THEN
--         RAISE_APPLICATION_ERROR (-20005, 'Un equipo de primera división no puede ascender.');
--     END IF;
-- END;
-- /

-- Asegura que el número de partidos cuadre.
-- TRIGGER 2:
-- CREATE OR REPLACE TRIGGER SUM_PAR_OK
-- BEFORE INSERT ON resultados
-- FOR EACH ROW
-- DECLARE 
--     partidosRES NUMBER;
--     partidosPAR NUMBER;
-- BEGIN
--     partidosRES := :NEW.partidosGanados + :NEW.partidosEmpatados + :NEW.partidosPerdidos;
--     SELECT COUNT(*) INTO partidosPAR FROM partidos WHERE (:NEW.equipo = local OR :NEW.equipo = visitante) AND temporada = :NEW.temporada AND division = :NEW.division AND numJornada <= :NEW.numJornada;
    
--     IF NOT partidosRES = partidosPAR
--     THEN
--         RAISE_APPLICATION_ERROR (-20002, 'El número total de partidos jugados por el equipo, no cuadra con el número introducido en los resultados');
--     END IF;
-- END;
-- /

-- TRIGGER 2:
CREATE OR REPLACE TRIGGER DATES_OK
BEFORE INSERT ON resultados
FOR EACH ROW
DECLARE 
    fechaFUN NUMBER;
BEGIN
    SELECT fechaFundacion INTO fechaFUN FROM equipos WHERE :NEW.equipo = nombreCorto;
    
    IF :NEW.temporada < fechaFUN
    THEN
        RAISE_APPLICATION_ERROR (-20003, 'El equipo no existe aún en esta temporada');
    END IF;
END;
/

-- INSERT INTO EQUIPOS (NOMBRECORTO,NOMBREOFICIAL,NOMBREHISTORICO,CIUDAD,FECHAFUNDACION,ESTADIO) VALUES ('REALISIMOBetisBALOMPIEPA',' Real Betis Balompié','Sevilla Balompié','Sevilla','1996','Benito Villamarín');
-- INSERT INTO RESULTADOS (PUNTOS,PUESTO,GOLESAF,GOLESEC,PARTIDOSGANADOS,PARTIDOSEMPATADOS,PARTIDOSPERDIDOS,ASCIENDE,DESCIENDE,EUROPA,EQUIPO,DIVISION,TEMPORADA,NUMJORNADA) VALUES ('53','12','39','43','14','11','15',NULL,NULL,NULL,'REALISIMOBetisBALOMPIEPA','2ª','1976','38');
-- DELETE * FROM EQUIPOS WHERE NOMBRECORTO = 'REALISIMOBetisBALOMPIEPA';