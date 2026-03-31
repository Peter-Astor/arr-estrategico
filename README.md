# Funcionalidad cooperativa de la Aversión a Revertir el Ranking (ARR)

Repositorio de datos y código de análisis del estudio experimental sobre la función de la ARR como mecanismo de estabilidad jerárquica y facilitación de la cooperación futura.

---

## Descripción del estudio

Este experimento económico examina si la Aversión a Revertir el Ranking (ARR) —la tendencia a evitar distribuciones que invierten el orden relativo de recursos entre personas— cumple una función cooperativa. Se emplearon tres condiciones experimentales que varían si la decisión distributiva tiene consecuencias estratégicas visibles para quienes luego deben cooperar entre sí.

*Pregunta central:* ¿La anticipación de una interacción cooperativa posterior modula la aparición de ARR en decisiones distributivas?

*Muestra analítica:* 133 participantes (de 166 totales), estudiantes universitarios de Bahía Blanca, Argentina. Diseño mixto con análisis entre-sujeto restringido al primer bloque recibido por cada participante.

---

## Estructura del repositorio


├── df_long0.csv                              # Base de datos cruda (formato largo, intrasujeto)

├── dataset_between.csv                       # Base de datos analítica (entre-sujeto, N=133)

├── DICT_tabla_long.csv                       # Diccionario de variables

├── 01_preprocesamiento.ipynb                 # Limpieza, filtros y construcción de variables

├── 02_analisis_SDO_GEE.ipynb                 # Modelos GEE principales (Tablas 3 y 4)

├── 04_validacion_expectativa.ipynb           # Validación del constructo Expectativa_Gap

├── 05_figuras.ipynb                          # Generación de figuras del manuscrito

└── README.md                                 # Este archivo


---

## Archivos de datos

### df_long0.csv — Base de datos cruda (N = 166 participantes, 3485 filas)

Contiene todos los ensayos de todos los participantes en formato largo, incluyendo los chequeos de atención. Es el punto de partida para toda la cadena de análisis.

| Variable | Tipo | Descripción |
|---|---|---|
| ID_Sujeto | String | Identificador único anonimizado del participante |
| Origen_Form | Categórica | Formulario de origen (para balanceo) |
| Identidad | String | Código interno del estímulo presentado |
| Bloque | Ordinal | Etiqueta de bloque con parámetros de monto inicial y montos finales |
| Orden_1 | Int | Posición en que se presentó el tratamiento (1, 2 o 3) |
| Dilema | Categórica | *Variable independiente.* Condición experimental: "Bloque_CON", "Bloque_SIN", "Dist", "Atencion" |
| Orden_2 | Int | Posición del bloque dentro del tratamiento (1–6) |
| Gap_Size | Int | Diferencia numérica entre las opciones finales en ARS (0, 1000, 1200, 2000, 2400) |
| Respuesta | String | Opción cruda seleccionada: "Opción 1", "Opción 2", "Opción 3" |
| Mantiene | Int (0/1) | *Variable dependiente.* 1 = preserva jerarquía (Status Quo), 0 = revierte |
| Expectativa_Activa | Int | Creencia del sujeto sobre el efecto de su decisión en la cooperación posterior, ajustada al nivel de Gap del ensayo (−1, 0, 1) |
| Genero | Categórica | Género autopercibido |
| politica | Ordinal | Autoposicionamiento político (1 = extrema izquierda, 7 = extrema derecha) |
| nivel_se | Ordinal | Nivel socioeconómico subjetivo (1–10) |
| SDO_Score | Float | Promedio en escala de Orientación a la Dominancia Social (1–5) |
| NDC_Score | Float | Promedio en escala de Necesidad de Cognición (1–5) |
| expectativa_sin_num | Int | Expectativa para ensayos con Gap = 0 (−1, 0, 1) |
| expectativa_pequeña_num | Int | Expectativa para ensayos con Gap 1000–1200 (−1, 0, 1) |
| expectativa_grande_num | Int | Expectativa para ensayos con Gap 2000–2400 (−1, 0, 1) |
| Promedio_Gap_0 … Promedio_Gap_2400 | Float | Tasa de "mantiene" del sujeto por nivel de Gap (variables auxiliares) |
| Promedio_CON, Promedio_SIN, Promedio_DIST | Float | Tasa de "mantiene" del sujeto por condición (variables auxiliares) |
| Delta_Mantiene | Float | Diferencia intra-sujeto: Promedio_CON − Promedio_SIN |
| Delta_base | Float | Diferencia intra-sujeto: Promedio_SIN − Promedio_DIST |

*Codificación de expectativas (valores −1, 0, 1):*
- 1 (MIC) = el sujeto cree que mantener el ranking incrementa la cooperación posterior
- 0 = el sujeto cree que la decisión es indiferente para la cooperación
- −1 (RIC) = el sujeto cree que revertir el ranking incrementa la cooperación posterior

---

### dataset_between.csv — Base de datos analítica entre-sujeto (N = 133, 798 filas)

Dataset preprocesado que contiene únicamente las observaciones del primer bloque recibido por cada participante (diseño entre-sujeto). Es el input directo de los notebooks de análisis 02_ y 05_. Incluye todas las columnas de df_long0.csv más las variables centradas para los modelos:

| Variable adicional | Descripción |
|---|---|
| Mantiene_bin | Equivalente a Mantiene, tipado como entero binario |
| SDO_c | SDO_Score centrado en la media muestral (M = 2.12) |
| NDC_c | NDC_Score centrado en la media muestral (M = 3.88) |
| pol_c | politica centrada en la media muestral |
| nse_c | nivel_se centrado en la media muestral |
| Gen_mujer | Dummy: 1 = Mujer, 0 = otro |
| Gap | Equivalente a Gap_Size (renombrado para compatibilidad con fórmulas GEE) |
| Gap0 | Dummy: 1 si Gap = 0 |
| Gap_pos | Gap en ARS cuando Gap > 0, 0 en caso contrario |
| Tratamiento | Versión string de la condición: "CON", "SIN", "DIST" |

*Criterio de exclusión:* se excluyeron 33 participantes que fallaron el chequeo de atención en su primer bloque (de 166 a 133). La tasa de exclusión no difirió significativamente entre condiciones (χ²(2) = 1.95, p = .378).

---

### DICT_tabla_long.csv — Diccionario de variables

Archivo tabular con la descripción completa de cada variable de df_long0.csv, incluyendo categoría (identificación, experimental, del sujeto, auxiliar), tipo de dato y ejemplos de valores.

---

## Notebooks — Orden de ejecución

Los notebooks deben ejecutarse en el siguiente orden. Cada uno indica su input y output:

### 01_preprocesamiento.ipynb
*Input:* df_long0.csv
*Output:* dataset_between.csv

Realiza la cadena completa de limpieza y preparación de datos:
1. Identifica los chequeos de atención (Dilema == "Atencion") y genera la lista de bloques a excluir por participante
2. Construye el dataset entre-sujeto restringiendo a Orden_1 == 1
3. Centra las variables continuas (SDO_c, NDC_c, pol_c, nse_c) en la media muestral de la muestra analítica
4. Verifica el balance entre condiciones (tablas S1–S3 del material suplementario)
5. Exporta dataset_between.csv

---

### 02_analisis_SDO_GEE.ipynb
*Input:* dataset_between.csv
*Output:* tablas CSV con resultados de modelos GEE

Estima los modelos GEE reportados en las Tablas 3 y 4 del paper:
- Modelo completo: interacción triple Tratamiento × SDO × Gap (N = 133 sujetos, 798 obs), con SIN como condición de referencia
- Subgrupo NDC alta: mismo modelo restringido a participantes con NDC_Score ≥ P75 = 4.33 (N = 43, 258 obs)
- Genera estadística de Wilcoxon de tasa Mantiene vs. azar (0.50) por condición y por nivel de Gap

*Especificación de los modelos GEE:*
- Familia: Binomial con función de enlace logit
- Estructura de correlación: Exchangeable
- Estimador de varianza: sandwich de Huber-White (robusto)
- Agrupamiento: por ID_Sujeto

> *Nota:* El notebook usa DIST como categoría de referencia (dummies T_CON y T_SIN). Las Tablas 3 y 4 del paper usan SIN como referencia (dummies T_CON y T_DIST). Los coeficientes son algebraicamente equivalentes pero numéricamente distintos. Para reproducir directamente las tablas del paper, reemplazar T_SIN por T_DIST en las dummies de tratamiento.

---

### 03_validacion_expectativa.ipynb
*Input:* df_long0.csv
*Output:* estadísticos descriptivos y tests de racionalización (Tablas 5, S7, S8, S9)

Valida el constructo Expectativa_Gap (creencia sobre qué opción distributiva favorece más la cooperación posterior):
1. Construye Exp_Gap a partir del mapeo Gap_Size → expectativa correspondiente
2. Verifica que el mapeo sea correcto mediante la Tabla S7
3. Calcula descriptivos de expectativas por nivel de Gap (Tabla 5)
4. Analiza la alineación entre expectativa y conducta (Tablas S8)
5. Test de racionalización post-hoc: compara alineación entre sujetos para quienes el bloque CON fue el último vs. los que lo recibieron antes (p = .596, sin evidencia de racionalización)
6. Calcula correlaciones Spearman entre expectativas y variables ideológicas (SDO, política, NDC)

Este notebook también estima los modelos GEE de la Tabla 7 (Tratamiento × Expectativa × NDC, ref = SIN):
- Modelo 1: interacción doble Tratamiento × Expectativa
- Modelo 2: interacción triple Tratamiento × Expectativa × NDC

> *Nota:* Los modelos GEE de este notebook usan una implementación personalizada del estimador sandwich que puede producir resultados ligeramente distintos a los de statsmodels. Ver REPLICATION_REPORT.md para detalles.

---

### 04_figuras.ipynb
*Input:* df_long0.csv
*Output:* archivos PNG de figuras del manuscrito

Genera las figuras del paper reconstruyendo el dataset between-subject desde df_long0.csv:
- *fig_mantiene_por_gap.png* — Figura 2 del paper: tasa de "Mantiene" por nivel de Gap, agrupado por condición (DIST, SIN, CON). Barras con IC 95% (±1.96 SE). Línea punteada de azar en 0.50.
- *fig_mantiene_por_tratamiento.png* — Tasa de "Mantiene" por condición, agrupado por nivel de Gap.
- *fig_A_marginal_exp_cond.png* — Efectos marginales predichos P(Mantiene) en función de Expectativa × Condición (Modelo 1 de Tabla 7).
- *fig_B_marginal_exp_ndc.png* — Efectos marginales en dos paneles NDC bajo / NDC alto (Modelo 2 de Tabla 7).
- *fig_C_barras_exp_cond.png* — Barras descriptivas de tasa de "Mantiene" por Expectativa × Condición.

*Paleta de colores usada:*
- DIST: #185FA5 (azul)
- SIN: #1D9E75 (verde)
- CON: #D85A30 (naranja)

---

## Diseño experimental resumido

*Tres condiciones (entre-sujeto, primer bloque):*
- *DIST* — Solo dilema distributivo; sin dilema de cooperación posterior. Línea de base para la ARR.
- *SIN* — Dilema distributivo seguido de dilema de cooperación, pero la decisión distributiva NO es conocida por los cooperadores. Controla la carga cognitiva sin habilitar señalización estratégica.
- *CON* — Dilema distributivo seguido de dilema de cooperación, y la decisión distributiva SÍ es conocida por los cooperadores antes de decidir. Condición de señalización estratégica.

*Seis escenarios por bloque* (con distintos niveles de Gap: 0, 0, 1000, 1200, 2000, 2400 ARS) + 1 chequeo de atención.

*Variables dependientes principales:*
- Mantiene (0/1): si el participante elige la opción que preserva la jerarquía inicial de dotaciones
- Expectativa_Activa (−1, 0, 1): creencia sobre qué opción distributiva favorece más la cooperación posterior

---

## Requerimientos de software


Python      3.8.16
pandas      1.2.4
numpy       1.19.2
scipy       1.6.3
statsmodels 0.12.2
jupyter     1.0.0


> ⚠️ *Importante para replicabilidad:* Los modelos GEE son sensibles a la versión de statsmodels. Diferencias en el cómputo del estimador sandwich de Huber-White entre versiones pueden producir variaciones en el segundo decimal de los SE y valores de p cercanos al umbral de significancia

---

## Referencia al paper

> [La función social de la jerarquía: evidencia experimental sobre la aversión a revertir rankings y la cooperación], [Pedro García Vassallo], [2026]. DOI: [pendiente].

---

## Contacto

Para preguntas sobre los datos o el código, contactar a Pedro García Vassallo en epdrogarciavassallo@gmail.com.
