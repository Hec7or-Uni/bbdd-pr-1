CREATE OR REPLACE TRIGGER CHECK_INTEGRIDAD
BEFORE INSERT ON partidos
DECLARE 
    flag NUMBER;
BEGIN
    SELECT COUNT(*) INTO flag
    FROM partidos 
    WHERE temporada = :NEW.temporada AND division = :NEW.division AND numJornada = :NEW.numJornada AND 
        local = :NEW.visitante OR visitante = :NEW.visitante;
        
    IF flag > 0 THEN
        RAISE_APPLICATION_ERROR (-20000, 'Un equipo no puede jugar como local y visitante en la misma jornada.');
    END IF;
END; 
/