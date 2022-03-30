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
        local = :NEW.visitante OR visitante = :NEW.visitante;
        
    IF flag >= 1 THEN
        RAISE_APPLICATION_ERROR (-20000, 'Un equipo no puede jugar como local y visitante en la misma jornada.');
    END IF;
END; 
/


-- TRIGGER 2:
CREATE OR REPLACE TRIGGER OK_DIV
BEFORE INSERT ON jornadas
FOR EACH ROW
BEGIN
    IF NOT (:NEW.division = '1ª' OR :NEW.division = '2ª' OR :NEW.division = 'Promoción a 1ª' OR :NEW.division = 'Promoción 1ª/2ª' OR :NEW.division = 'Descenso a 2ª') THEN 
        RAISE_APPLICATION_ERROR (-20001, 'No existe la división que se ha tratado de introducir');
    END IF;
END;
/
