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

-- TRIGGER 3:
CREATE OR REPLACE TRIGGER OK_ASC_DES_EU
BEFORE INSERT ON resultados
FOR EACH ROW
BEGIN
    IF (:NEW.asciende = 1 AND :NEW.desciende = 1) THEN 
        RAISE_APPLICATION_ERROR (-20002, 'Un equipo no puede ascender y descender simultáneamente.');
    ELSIF (:NEW.asciende = 1 AND :NEW.europa = 1) THEN
        RAISE_APPLICATION_ERROR (-20003, 'Un equipo no puede ascender e ir a europa simultáneamente.');
    ELSIF (:NEW.division = '2ª' AND (:NEW.desciende = 1 OR :NEW.europa = 1)) THEN
        RAISE_APPLICATION_ERROR (-20004, 'Un equipo de segunda división no puede ni descender, ni ir a europa.');
    ELSIF (:NEW.division = '1ª' AND :NEW.asciende = 1) THEN
        RAISE_APPLICATION_ERROR (-20005, 'Un equipo de primera división no puede ascender.');
    END IF;
END;
/