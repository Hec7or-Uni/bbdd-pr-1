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
        RAISE_APPLICATION_ERROR (-20001, 'El equipo no existe aún en esta temporada');
    END IF;
END;
/