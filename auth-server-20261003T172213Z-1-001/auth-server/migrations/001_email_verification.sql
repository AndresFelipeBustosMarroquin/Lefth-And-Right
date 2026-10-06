ALTER TABLE usuario
    ADD COLUMN IF NOT EXISTS correo_verificado BOOLEAN NOT NULL DEFAULT TRUE;

CREATE TABLE IF NOT EXISTS codigo_verificacion_correo (
    correo TEXT PRIMARY KEY,
    codigo_hash CHAR(64) NOT NULL,
    vence_en TIMESTAMPTZ NOT NULL,
    intentos SMALLINT NOT NULL DEFAULT 0 CHECK (intentos >= 0),
    enviado_en TIMESTAMPTZ NOT NULL
);
