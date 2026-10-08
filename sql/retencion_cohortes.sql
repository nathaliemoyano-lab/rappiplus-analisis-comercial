WITH cohortes AS (
    SELECT
        id_usuario,
        TO_CHAR(
            DATE_TRUNC('month', CAST(fecha_registro AS DATE)),
            'YYYY-MM'
        ) AS cohort_mes
    FROM users
),

actividad AS (
    SELECT
        a.id_usuario,
        a.dias_despues_registro,
        a.activo,
        c.cohort_mes
    FROM user_activity a
    INNER JOIN cohortes c
        ON a.id_usuario = c.id_usuario
),

retencion AS (
    SELECT
        cohort_mes,

        COUNT(DISTINCT CASE
            WHEN dias_despues_registro >= 7
                 AND activo = 1
            THEN id_usuario
        END) AS retention_w1,

        COUNT(DISTINCT CASE
            WHEN dias_despues_registro >= 14
                 AND activo = 1
            THEN id_usuario
        END) AS retention_w2,

        COUNT(DISTINCT CASE
            WHEN dias_despues_registro >= 21
                 AND activo = 1
            THEN id_usuario
        END) AS retention_w3

    FROM actividad
    GROUP BY cohort_mes
),

tamano_cohorte AS (
    SELECT
        TO_CHAR(
            DATE_TRUNC('month', CAST(fecha_registro AS DATE)),
            'YYYY-MM'
        ) AS cohort_mes,
        COUNT(DISTINCT id_usuario) AS cohort_size
    FROM users
    GROUP BY cohort_mes
)

SELECT
    r.cohort_mes,
    t.cohort_size,

    r.retention_w1,
    r.retention_w2,
    r.retention_w3,

    ROUND(100.0 * r.retention_w1 / t.cohort_size, 2)
        AS retention_w1_pct,

    ROUND(100.0 * r.retention_w2 / t.cohort_size, 2)
        AS retention_w2_pct,

    ROUND(100.0 * r.retention_w3 / t.cohort_size, 2)
        AS retention_w3_pct

FROM retencion r
INNER JOIN tamano_cohorte t
    ON r.cohort_mes = t.cohort_mes

ORDER BY r.cohort_mes;
