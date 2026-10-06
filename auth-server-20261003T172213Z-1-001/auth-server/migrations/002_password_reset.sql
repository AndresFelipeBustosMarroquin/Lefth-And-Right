CREATE TABLE IF NOT EXISTS codigo_recuperacion_contrasena (
    correo TEXT PRIMARY KEY,
    codigo_hash CHAR(64) NOT NULL,
    vence_en TIMESTAMPTZ NOT NULL,
    intentos SMALLINT NOT NULL DEFAULT 0 CHECK (intentos >= 0),
    enviado_en TIMESTAMPTZ NOT NULL
);
