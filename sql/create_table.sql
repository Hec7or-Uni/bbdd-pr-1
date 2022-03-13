CREATE TABLE estadios (
    nombre              VARCHAR2(100), 
    capacidad           NUMBER  	NOT NULL,
    fechaInauguracion   VARCHAR2(100)   NOT NULL,
    CONSTRAINT pk_Es_nombre         PRIMARY KEY (nombre),
    CONSTRAINT ck_capacidad         CHECK (capacidad >= 0)
);

CREATE TABLE equipos (
    nombreCorto     VARCHAR2(100),
    nombreOficial   VARCHAR2(100)   NOT NULL,
    nombreHistorico VARCHAR2(100),
    ciudad          VARCHAR2(100)   NOT NULL,
    fechaFundacion  NUMBER          NOT NULL,
    estadio         VARCHAR2(100), 
    CONSTRAINT pk_Eq_nombreCorto    PRIMARY KEY (nombreCorto),
    CONSTRAINT fk_estadio           FOREIGN KEY (estadio) REFERENCES estadios (nombre),
    CONSTRAINT ck_fechaFundacion CHECK (fechaFundacion >= 1582)
);

CREATE TABLE otrosNombres (
    nombre  VARCHAR2(100),
    equipo  VARCHAR2(100),
    CONSTRAINT pk_R_nombre  PRIMARY KEY (nombre),
    CONSTRAINT fk_equipo    FOREIGN KEY (equipo) REFERENCES equipos (nombreCorto)
);

CREATE TABLE jornadas (
    division    VARCHAR2(30),
    temporada   NUMBER,
    numJornada  NUMBER,
    CONSTRAINT pk_Eq_super      PRIMARY KEY (division, temporada, numJornada),
    CONSTRAINT ck_temporada     CHECK (temporada >= 1972),
    CONSTRAINT ck_numJornada    CHECK (numJornada >= 1)
);

CREATE TABLE partidos (
    golesLocal      NUMBER,
    golesVisitante  NUMBER,
    local           VARCHAR(100),
    visitante       VARCHAR(100),
    division        VARCHAR(30),
    temporada       NUMBER,
    numJornada      NUMBER,
    CONSTRAINT pk_P_super   PRIMARY KEY (local, division, temporada, numJornada),
    CONSTRAINT fk_local     FOREIGN KEY (local)     REFERENCES equipos (nombreCorto),
    CONSTRAINT fk_visitante FOREIGN KEY (visitante) REFERENCES equipos (nombreCorto),
    CONSTRAINT fk_jornada   FOREIGN KEY (division, temporada, numJornada) REFERENCES jornadas (division, temporada, numJornada),
    CONSTRAINT ck_golesLocal        CHECK (golesLocal >= 0),
    CONSTRAINT ck_golesVisitante    CHECK (golesVisitante >= 0)
);

CREATE TABLE resultados (
    puntos              NUMBER  NOT NULL,
    puesto              NUMBER  NOT NULL,
    golesAF             NUMBER  NOT NULL,
    golesEC             NUMBER  NOT NULL,
    partidosGanados     NUMBER  NOT NULL,
    partidosPerdidos    NUMBER  NOT NULL,
    asciende            NUMBER  NOT NULL,
    desciende           NUMBER  NOT NULL,
    europa              NUMBER  NOT NULL,
    equipo      VARCHAR(100),
    division    VARCHAR(30),
    temporada   NUMBER,
    numJornada  NUMBER,
    CONSTRAINT pk_R_super   PRIMARY KEY (equipo, division, temporada, numJornada),
    CONSTRAINT fk_R_equipo  FOREIGN KEY (equipo) REFERENCES equipos (nombreCorto),
    CONSTRAINT fk_R_jornada FOREIGN KEY (division, temporada, numJornada) REFERENCES jornadas (division, temporada, numJornada),
    CONSTRAINT ck_asciende  CHECK (asciende = 0 OR asciende = 1),
    CONSTRAINT ck_desciende CHECK (desciende = 0 OR desciende = 1),
    CONSTRAINT ck_europa    CHECK (europa = 0 OR europa = 1),
    CONSTRAINT ck_puntos    CHECK (puntos >= 0),
    CONSTRAINT ck_puesto    CHECK (puesto >= 0),
    CONSTRAINT ck_golesAF   CHECK (golesAF >= 0),
    CONSTRAINT ck_golesEC   CHECK (golesEC >= 0),
    CONSTRAINT ck_partidosGanados   CHECK (partidosGanados >= 0),
    CONSTRAINT ck_partidosPerdidos  CHECK (partidosPerdidos >= 0)
);