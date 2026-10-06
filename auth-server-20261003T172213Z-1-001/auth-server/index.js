require('dotenv').config();

const crypto = require('node:crypto');
const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');

const app = express();
const configuredOrigins = new Set(
    (process.env.CORS_ORIGINS || '')
        .split(',')
        .map((origin) => origin.trim())
        .filter(Boolean)
);

app.use((req, res, next) => {
    const origin = req.get('Origin');
    const isLocalDevelopmentOrigin =
        origin && /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);

    if (!origin) {
        return next();
    }

    if (!isLocalDevelopmentOrigin && !configuredOrigins.has(origin)) {
        return res.status(403).json({
            code: 'ORIGIN_NOT_ALLOWED',
            error: 'El origen de esta aplicación no está autorizado.'
        });
    }

    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        return res.sendStatus(204);
    }

    return next();
});
app.use(express.json({ limit: '16kb' }));

const pool = new Pool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 5432),
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD
});

const CODE_TTL_MINUTES = 10;
const CODE_RESEND_SECONDS = 60;
const MAX_CODE_ATTEMPTS = 5;

class ApiError extends Error {
    constructor(status, code, message) {
        super(message);
        this.status = status;
        this.code = code;
    }
}

function normalizeEmail(value) {
    return typeof value === 'string' ? value.trim().toLowerCase() : '';
}

function validEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validPassword(password) {
    return typeof password === 'string' &&
        password.length >= 6 &&
        /[A-Z]/.test(password) &&
        /[a-z]/.test(password) &&
        /[0-9]/.test(password) &&
        /[^A-Za-z0-9]/.test(password);
}

function verificationCodeHash(email, code) {
    return crypto
        .createHmac('sha256', process.env.JWT_SECRET)
        .update(`${email}:${code}`)
        .digest('hex');
}

function secureHashEquals(expectedHex, actualHex) {
    if (!/^[a-f0-9]{64}$/i.test(expectedHex) ||
        !/^[a-f0-9]{64}$/i.test(actualHex)) {
        return false;
    }

    return crypto.timingSafeEqual(
        Buffer.from(expectedHex, 'hex'),
        Buffer.from(actualHex, 'hex')
    );
}

function createMailTransport() {
    const user = process.env.GMAIL_USER;
    const password = process.env.GMAIL_APP_PASSWORD;
    if (!user || !password) {
        throw new ApiError(
            503,
            'EMAIL_NOT_CONFIGURED',
            'El envío de correo no está configurado en el servidor.'
        );
    }

    return nodemailer.createTransport({
        service: 'gmail',
        auth: { user, pass: password },
        connectionTimeout: 15_000,
        greetingTimeout: 10_000,
        socketTimeout: 30_000
    });
}

async function sendVerificationEmail(email, code) {
    const transport = createMailTransport();
    await transport.sendMail({
        from: {
            name: 'LEFT AND RIGHT',
            address: process.env.GMAIL_USER
        },
        to: email,
        subject: 'Confirma tu correo - LEFT AND RIGHT',
        text: `Tu código de verificación es ${code}. ` +
            `Vence en ${CODE_TTL_MINUTES} minutos. Si no solicitaste esta cuenta, ignora este mensaje.`,
        html: `<p>Tu código de verificación es:</p>` +
            `<p style="font-size:24px;font-weight:bold;letter-spacing:6px">${code}</p>` +
            `<p>Vence en ${CODE_TTL_MINUTES} minutos. Si no solicitaste esta cuenta, ignora este mensaje.</p>`
    });
}

async function sendPasswordResetEmail(email, code) {
    const transport = createMailTransport();
    await transport.sendMail({
        from: {
            name: 'LEFT AND RIGHT',
            address: process.env.GMAIL_USER
        },
        to: email,
        subject: 'Recupera tu contraseña - LEFT AND RIGHT',
        text: `Tu código para recuperar la contraseña es ${code}. ` +
            `Vence en ${CODE_TTL_MINUTES} minutos. Si no solicitaste este cambio, ignora este mensaje.`,
        html: `<p>Usa este código para recuperar tu contraseña:</p>` +
            `<p style="font-size:24px;font-weight:bold;letter-spacing:6px">${code}</p>` +
            `<p>Vence en ${CODE_TTL_MINUTES} minutos. Si no solicitaste este cambio, ignora este mensaje.</p>`
    });
}

async function issueVerificationCode(email) {
    const code = String(crypto.randomInt(100000, 1000000));
    const codeHash = verificationCodeHash(email, code);
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        await client.query(
            'SELECT pg_advisory_xact_lock(hashtext($1))',
            [email]
        );
        const existing = await client.query(
            'SELECT enviado_en FROM codigo_verificacion_correo WHERE correo = $1 FOR UPDATE',
            [email]
        );

        if (existing.rows.length > 0) {
            const lastSentAt = new Date(existing.rows[0].enviado_en).getTime();
            const secondsSinceLastSend = Math.floor((Date.now() - lastSentAt) / 1000);
            if (secondsSinceLastSend < CODE_RESEND_SECONDS) {
                throw new ApiError(
                    429,
                    'RESEND_TOO_SOON',
                    `Espera ${CODE_RESEND_SECONDS - secondsSinceLastSend} segundos antes de solicitar otro código.`
                );
            }
        }

        await client.query(
            `INSERT INTO codigo_verificacion_correo
                (correo, codigo_hash, vence_en, intentos, enviado_en)
             VALUES ($1, $2, NOW() + ($3 * INTERVAL '1 minute'), 0, NOW())
             ON CONFLICT (correo) DO UPDATE
             SET codigo_hash = EXCLUDED.codigo_hash,
                 vence_en = EXCLUDED.vence_en,
                 intentos = 0,
                 enviado_en = EXCLUDED.enviado_en`,
            [email, codeHash, CODE_TTL_MINUTES]
        );
        await client.query('COMMIT');
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }

    try {
        await sendVerificationEmail(email, code);
    } catch (error) {
        await pool.query(
            `UPDATE codigo_verificacion_correo
             SET enviado_en = NOW() - ($3 * INTERVAL '1 second')
             WHERE correo = $1 AND codigo_hash = $2`,
            [email, codeHash, CODE_RESEND_SECONDS]
        );
        if (error instanceof ApiError) {
            throw error;
        }
        console.error('Error enviando código de verificación:', error);
        throw new ApiError(
            503,
            'EMAIL_SEND_FAILED',
            'No se pudo enviar el correo. Revisa la configuración del servidor e intenta reenviar el código.'
        );
    }
}

async function issuePasswordResetCode(email) {
    const code = String(crypto.randomInt(100000, 1000000));
    const codeHash = verificationCodeHash(email, code);
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        await client.query(
            'SELECT pg_advisory_xact_lock(hashtext($1))',
            [`password-reset:${email}`]
        );
        const existing = await client.query(
            'SELECT enviado_en FROM codigo_recuperacion_contrasena WHERE correo = $1 FOR UPDATE',
            [email]
        );

        if (existing.rows.length > 0) {
            const lastSentAt = new Date(existing.rows[0].enviado_en).getTime();
            const secondsSinceLastSend = Math.floor((Date.now() - lastSentAt) / 1000);
            if (secondsSinceLastSend < CODE_RESEND_SECONDS) {
                throw new ApiError(
                    429,
                    'RESEND_TOO_SOON',
                    `Espera ${CODE_RESEND_SECONDS - secondsSinceLastSend} segundos antes de solicitar otro código.`
                );
            }
        }

        await client.query(
            `INSERT INTO codigo_recuperacion_contrasena
                (correo, codigo_hash, vence_en, intentos, enviado_en)
             VALUES ($1, $2, NOW() + ($3 * INTERVAL '1 minute'), 0, NOW())
             ON CONFLICT (correo) DO UPDATE
             SET codigo_hash = EXCLUDED.codigo_hash,
                 vence_en = EXCLUDED.vence_en,
                 intentos = 0,
                 enviado_en = EXCLUDED.enviado_en`,
            [email, codeHash, CODE_TTL_MINUTES]
        );
        await client.query('COMMIT');
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }

    try {
        await sendPasswordResetEmail(email, code);
    } catch (error) {
        await pool.query(
            `UPDATE codigo_recuperacion_contrasena
             SET enviado_en = NOW() - ($3 * INTERVAL '1 second')
             WHERE correo = $1 AND codigo_hash = $2`,
            [email, codeHash, CODE_RESEND_SECONDS]
        );
        if (error instanceof ApiError) {
            throw error;
        }
        console.error('Error enviando código de recuperación:', error);
        throw new ApiError(
            503,
            'EMAIL_SEND_FAILED',
            'No se pudo enviar el correo. Revisa la configuración del servidor e intenta de nuevo.'
        );
    }
}

function createSessionToken(user) {
    if (!process.env.JWT_SECRET) {
        throw new ApiError(
            503,
            'AUTH_NOT_CONFIGURED',
            'La autenticación no está configurada en el servidor.'
        );
    }

    return jwt.sign(
        { role: 'authenticated', user_id: user.id_usuario },
        process.env.JWT_SECRET,
        { expiresIn: '2h' }
    );
}

function sendApiError(res, error) {
    if (error instanceof ApiError) {
        return res.status(error.status).json({
            code: error.code,
            error: error.message
        });
    }

    console.error('Error procesando solicitud de autenticación:', error);
    return res.status(500).json({
        code: 'INTERNAL_ERROR',
        error: 'Error interno del servidor.'
    });
}

app.get('/', (req, res) => {
    res.json({ mensaje: 'Servidor de autenticación Left And Right funcionando' });
});

app.post('/register', async (req, res) => {
    const nombre = typeof req.body?.nombre === 'string' ? req.body.nombre.trim() : '';
    const correo = normalizeEmail(req.body?.correo);
    const contrasena = req.body?.contrasena;

    if (!nombre || nombre.length > 120 || !validEmail(correo) || !validPassword(contrasena)) {
        return res.status(400).json({
            code: 'INVALID_INPUT',
            error: 'Revisa el nombre, el correo y los requisitos de la contraseña.'
        });
    }

    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        await client.query('SELECT pg_advisory_xact_lock(hashtext($1))', [correo]);
        const existing = await client.query(
            `SELECT id_usuario, correo_verificado
             FROM usuario
             WHERE LOWER(correo) = $1
             LIMIT 1`,
            [correo]
        );

        if (existing.rows.length > 0) {
            await client.query('ROLLBACK');
            const verified = existing.rows[0].correo_verificado;
            return res.status(409).json({
                code: verified ? 'EMAIL_ALREADY_REGISTERED' : 'EMAIL_PENDING',
                error: verified
                    ? 'Ya existe una cuenta con este correo.'
                    : 'Esta cuenta aún no está verificada. Ingresa el código o solicita uno nuevo.'
            });
        }

        const passwordHash = await bcrypt.hash(contrasena, 12);
        await client.query(
            `INSERT INTO usuario (nombre, correo, contrasena, correo_verificado)
             VALUES ($1, $2, $3, FALSE)`,
            [nombre, correo, passwordHash]
        );
        await client.query('COMMIT');
    } catch (error) {
        await client.query('ROLLBACK');
        return sendApiError(res, error);
    } finally {
        client.release();
    }

    try {
        await issueVerificationCode(correo);
        return res.status(201).json({
            mensaje: 'Cuenta creada. Revisa tu correo e ingresa el código de verificación.'
        });
    } catch (error) {
        if (error instanceof ApiError) {
            return res.status(error.status).json({
                code: error.code,
                error: error.message
            });
        }
        return sendApiError(res, error);
    }
});

app.post('/verify-email', async (req, res) => {
    const correo = normalizeEmail(req.body?.correo);
    const code = typeof req.body?.codigo === 'string' ? req.body.codigo.trim() : '';

    if (!validEmail(correo) || !/^\d{6}$/.test(code)) {
        return res.status(400).json({
            code: 'INVALID_INPUT',
            error: 'Ingresa un correo válido y el código de 6 dígitos.'
        });
    }

    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        await client.query('SELECT pg_advisory_xact_lock(hashtext($1))', [correo]);
        const result = await client.query(
            `SELECT codigo_hash, vence_en, intentos
             FROM codigo_verificacion_correo
             WHERE correo = $1
             FOR UPDATE`,
            [correo]
        );

        if (result.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(400).json({
                code: 'CODE_NOT_FOUND',
                error: 'No hay un código vigente. Solicita uno nuevo.'
            });
        }

        const verification = result.rows[0];
        if (new Date(verification.vence_en).getTime() <= Date.now()) {
            await client.query(
                'DELETE FROM codigo_verificacion_correo WHERE correo = $1',
                [correo]
            );
            await client.query('COMMIT');
            return res.status(400).json({
                code: 'CODE_EXPIRED',
                error: 'El código venció. Solicita uno nuevo.'
            });
        }

        if (verification.intentos >= MAX_CODE_ATTEMPTS) {
            await client.query('ROLLBACK');
            return res.status(429).json({
                code: 'TOO_MANY_ATTEMPTS',
                error: 'Se alcanzó el límite de intentos. Solicita un código nuevo.'
            });
        }

        const suppliedHash = verificationCodeHash(correo, code);
        if (!secureHashEquals(verification.codigo_hash, suppliedHash)) {
            await client.query(
                `UPDATE codigo_verificacion_correo
                 SET intentos = intentos + 1
                 WHERE correo = $1`,
                [correo]
            );
            await client.query('COMMIT');
            return res.status(400).json({
                code: 'INVALID_CODE',
                error: 'El código ingresado no es correcto.'
            });
        }

        const user = await client.query(
            `UPDATE usuario
             SET correo_verificado = TRUE
             WHERE LOWER(correo) = $1
             RETURNING id_usuario`,
            [correo]
        );
        await client.query(
            'DELETE FROM codigo_verificacion_correo WHERE correo = $1',
            [correo]
        );
        await client.query('COMMIT');

        if (user.rows.length === 0) {
            return res.status(404).json({
                code: 'ACCOUNT_NOT_FOUND',
                error: 'No existe una cuenta pendiente para este correo.'
            });
        }

        return res.json({ mensaje: 'Correo verificado correctamente.' });
    } catch (error) {
        await client.query('ROLLBACK');
        return sendApiError(res, error);
    } finally {
        client.release();
    }
});

app.post('/resend-verification', async (req, res) => {
    const correo = normalizeEmail(req.body?.correo);
    if (!validEmail(correo)) {
        return res.status(400).json({
            code: 'INVALID_INPUT',
            error: 'Ingresa un correo válido.'
        });
    }

    try {
        const account = await pool.query(
            `SELECT correo_verificado
             FROM usuario
             WHERE LOWER(correo) = $1
             LIMIT 1`,
            [correo]
        );

        if (account.rows.length === 0) {
            return res.status(404).json({
                code: 'ACCOUNT_NOT_FOUND',
                error: 'No existe una cuenta con este correo.'
            });
        }
        if (account.rows[0].correo_verificado) {
            return res.status(409).json({
                code: 'EMAIL_ALREADY_VERIFIED',
                error: 'Este correo ya está verificado. Inicia sesión.'
            });
        }

        await issueVerificationCode(correo);
        return res.json({ mensaje: 'Enviamos un nuevo código de verificación.' });
    } catch (error) {
        return sendApiError(res, error);
    }
});

app.post('/forgot-password', async (req, res) => {
    const correo = normalizeEmail(req.body?.correo);
    if (!validEmail(correo)) {
        return res.status(400).json({
            code: 'INVALID_INPUT',
            error: 'Ingresa un correo electrónico válido.'
        });
    }

    try {
        const account = await pool.query(
            `SELECT 1
             FROM usuario
             WHERE LOWER(correo) = $1 AND correo_verificado = TRUE
             LIMIT 1`,
            [correo]
        );

        if (account.rows.length > 0) {
            await issuePasswordResetCode(correo);
        }

        return res.json({
            mensaje: 'Si existe una cuenta verificada con ese correo, enviaremos un código de recuperación.'
        });
    } catch (error) {
        return sendApiError(res, error);
    }
});

app.post('/verify-reset-code', async (req, res) => {
    const correo = normalizeEmail(req.body?.correo);
    const code = typeof req.body?.codigo === 'string' ? req.body.codigo.trim() : '';

    if (!validEmail(correo) || !/^\d{6}$/.test(code)) {
        return res.status(400).json({
            code: 'INVALID_INPUT',
            error: 'Ingresa un correo válido y el código de 6 dígitos.'
        });
    }

    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        await client.query(
            'SELECT pg_advisory_xact_lock(hashtext($1))',
            [`password-reset:${correo}`]
        );
        const result = await client.query(
            `SELECT codigo_hash, vence_en, intentos
             FROM codigo_recuperacion_contrasena
             WHERE correo = $1
             FOR UPDATE`,
            [correo]
        );

        if (result.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(400).json({
                code: 'CODE_NOT_FOUND',
                error: 'No hay un código de recuperación vigente. Solicita uno nuevo.'
            });
        }

        const recovery = result.rows[0];
        if (new Date(recovery.vence_en).getTime() <= Date.now()) {
            await client.query(
                'DELETE FROM codigo_recuperacion_contrasena WHERE correo = $1',
                [correo]
            );
            await client.query('COMMIT');
            return res.status(400).json({
                code: 'CODE_EXPIRED',
                error: 'El código venció. Solicita uno nuevo.'
            });
        }

        if (recovery.intentos >= MAX_CODE_ATTEMPTS) {
            await client.query('ROLLBACK');
            return res.status(429).json({
                code: 'TOO_MANY_ATTEMPTS',
                error: 'Se alcanzó el límite de intentos. Solicita un código nuevo.'
            });
        }

        const suppliedHash = verificationCodeHash(correo, code);
        if (!secureHashEquals(recovery.codigo_hash, suppliedHash)) {
            await client.query(
                `UPDATE codigo_recuperacion_contrasena
                 SET intentos = intentos + 1
                 WHERE correo = $1`,
                [correo]
            );
            await client.query('COMMIT');
            return res.status(400).json({
                code: 'INVALID_CODE',
                error: 'El código ingresado no es correcto.'
            });
        }

        const account = await client.query(
            `SELECT 1
             FROM usuario
             WHERE LOWER(correo) = $1 AND correo_verificado = TRUE
             LIMIT 1`,
            [correo]
        );
        await client.query('COMMIT');

        if (account.rows.length === 0) {
            return res.status(400).json({
                code: 'ACCOUNT_NOT_FOUND',
                error: 'No se pudo validar la solicitud de recuperación.'
            });
        }

        return res.json({ mensaje: 'Código de recuperación válido.' });
    } catch (error) {
        await client.query('ROLLBACK');
        return sendApiError(res, error);
    } finally {
        client.release();
    }
});

app.post('/reset-password', async (req, res) => {
    const correo = normalizeEmail(req.body?.correo);
    const code = typeof req.body?.codigo === 'string' ? req.body.codigo.trim() : '';
    const contrasena = req.body?.nueva_contrasena ??
        req.body?.nuevaContrasena ??
        req.body?.contrasena;

    if (!validEmail(correo) || !/^\d{6}$/.test(code) || !validPassword(contrasena)) {
        return res.status(400).json({
            code: 'INVALID_INPUT',
            error: 'Ingresa un código válido y una contraseña que cumpla los requisitos.'
        });
    }

    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        await client.query(
            'SELECT pg_advisory_xact_lock(hashtext($1))',
            [`password-reset:${correo}`]
        );
        const result = await client.query(
            `SELECT codigo_hash, vence_en, intentos
             FROM codigo_recuperacion_contrasena
             WHERE correo = $1
             FOR UPDATE`,
            [correo]
        );

        if (result.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(400).json({
                code: 'CODE_NOT_FOUND',
                error: 'No hay un código de recuperación vigente. Solicita uno nuevo.'
            });
        }

        const recovery = result.rows[0];
        if (new Date(recovery.vence_en).getTime() <= Date.now()) {
            await client.query(
                'DELETE FROM codigo_recuperacion_contrasena WHERE correo = $1',
                [correo]
            );
            await client.query('COMMIT');
            return res.status(400).json({
                code: 'CODE_EXPIRED',
                error: 'El código venció. Solicita uno nuevo.'
            });
        }

        if (recovery.intentos >= MAX_CODE_ATTEMPTS) {
            await client.query('ROLLBACK');
            return res.status(429).json({
                code: 'TOO_MANY_ATTEMPTS',
                error: 'Se alcanzó el límite de intentos. Solicita un código nuevo.'
            });
        }

        const suppliedHash = verificationCodeHash(correo, code);
        if (!secureHashEquals(recovery.codigo_hash, suppliedHash)) {
            await client.query(
                `UPDATE codigo_recuperacion_contrasena
                 SET intentos = intentos + 1
                 WHERE correo = $1`,
                [correo]
            );
            await client.query('COMMIT');
            return res.status(400).json({
                code: 'INVALID_CODE',
                error: 'El código ingresado no es correcto.'
            });
        }

        const passwordHash = await bcrypt.hash(contrasena, 12);
        const account = await client.query(
            `UPDATE usuario
             SET contrasena = $1
             WHERE LOWER(correo) = $2 AND correo_verificado = TRUE
             RETURNING id_usuario`,
            [passwordHash, correo]
        );
        await client.query(
            'DELETE FROM codigo_recuperacion_contrasena WHERE correo = $1',
            [correo]
        );
        await client.query('COMMIT');

        if (account.rows.length === 0) {
            return res.status(400).json({
                code: 'ACCOUNT_NOT_FOUND',
                error: 'No se pudo validar la solicitud de recuperación.'
            });
        }

        return res.json({ mensaje: 'Contraseña actualizada correctamente.' });
    } catch (error) {
        await client.query('ROLLBACK');
        return sendApiError(res, error);
    } finally {
        client.release();
    }
});

app.post('/login', async (req, res) => {
    const correo = normalizeEmail(req.body?.correo);
    const contrasena = req.body?.contrasena;

    if (!validEmail(correo) || typeof contrasena !== 'string' || !contrasena) {
        return res.status(400).json({
            code: 'INVALID_INPUT',
            error: 'Ingresa un correo y una contraseña válidos.'
        });
    }

    try {
        const result = await pool.query(
            `SELECT id_usuario, nombre, correo, contrasena, correo_verificado
             FROM usuario
             WHERE LOWER(correo) = $1
             LIMIT 1`,
            [correo]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                code: 'ACCOUNT_NOT_FOUND',
                error: 'No existe una cuenta registrada con este correo.'
            });
        }

        const user = result.rows[0];
        const passwordCorrect = await bcrypt.compare(contrasena, user.contrasena);
        if (!passwordCorrect) {
            return res.status(401).json({
                code: 'INVALID_CREDENTIALS',
                error: 'El correo o la contraseña son incorrectos.'
            });
        }
        if (!user.correo_verificado) {
            return res.status(403).json({
                code: 'EMAIL_NOT_VERIFIED',
                error: 'Confirma tu correo antes de iniciar sesión.'
            });
        }

        const token = createSessionToken(user);
        return res.json({
            mensaje: 'Inicio de sesión correcto.',
            usuario: {
                id_usuario: user.id_usuario,
                nombre: user.nombre,
                correo: user.correo
            },
            token
        });
    } catch (error) {
        return sendApiError(res, error);
    }
});

const PORT = Number(process.env.PORT || 4000);
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Auth Server escuchando en 0.0.0.0:${PORT}`);
});
