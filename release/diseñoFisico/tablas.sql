CREATE TABLE resultados_all (
    puesto              NUMBER,
    partidosGanados     NUMBER,
    equipo      VARCHAR2(100),
    division    VARCHAR2(30),
    temporada   NUMBER,
    CONSTRAINT fis_pf_R_super   PRIMARY KEY (equipo, division, temporada),
    CONSTRAINT fis_ck_puesto            CHECK (puesto >= 0),
    CONSTRAINT fis_ck_partidosGanados   CHECK (partidosGanados >= 0),
    CONSTRAINT fis_ck_temporada         CHECK (temporada >= 1972)
);

CREATE TABLE resultados_primera (
    puesto              NUMBER,
    partidosGanados     NUMBER,
    equipo      VARCHAR2(100),
    temporada   NUMBER,
    CONSTRAINT fis1_pf_R_super   PRIMARY KEY (equipo, temporada),
    CONSTRAINT fis1_ck_puesto            CHECK (puesto >= 0),
    CONSTRAINT fis1_ck_partidosGanados   CHECK (partidosGanados >= 0),
    CONSTRAINT fis1_ck_temporada         CHECK (temporada >= 1972)
);

CREATE TABLE resultados_segunda (
    puesto              NUMBER,
    partidosGanados     NUMBER,
    equipo      VARCHAR2(100),
    temporada   NUMBER,
    CONSTRAINT fis2_pf_R_super   PRIMARY KEY (equipo, temporada),
    CONSTRAINT fis2_ck_puesto            CHECK (puesto >= 0),
    CONSTRAINT fis2_ck_partidosGanados   CHECK (partidosGanados >= 0),
    CONSTRAINT fis2_ck_temporada         CHECK (temporada >= 1972)
);