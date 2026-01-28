# Análisis de Arreglos Estratégicos (arr-estrategico)

Repositorio para el análisis de datos experimentales del proyecto de investigación. Este repositorio contiene el flujo completo desde la limpieza de datos crudos hasta el análisis de efectos específicos (Tratamiento, Gap y Expectativas).

## 📂 Estructura del Proyecto

### 1. Estructura de Directorios

El proyecto se ha modularizado en las siguientes carpetas:

*   **`data/`**: Contiene los datos del proyecto.
    *   **`raw/`**: Datos crudos originales (`Base_Dem_dict.csv`, `Base_res_dict.csv`, etc.).
    *   **`processed/`**: Dataframes procesados y limpios listos para análisis (`df_long.csv`, `df_expectativas_filtrada.csv`, etc.).
*   **`scripts/`**: Notebooks de Jupyter para limpieza y análisis estadístico.
*   **`outputs/`**: Resultados generados por el código.
    *   **`plots/`**: Gráficos y visualizaciones (`panel_completo_resultados.png`, etc.).
    *   **`tables/`**: Tablas de resultados (si aplica).
*   **`docs/`**: Documentación adicional, diccionarios de datos y reportes de auditoría.

### 2. Flujo de Trabajo (Scripts)

Los notebooks se encuentran en la carpeta `scripts/`. El orden sugerido de ejecución es:

1.  **`Limpieza.ipynb`**: Preprocesamiento. Toma los datos de `data/raw/`, anonimiza y genera los archivos en `data/processed/`.
2.  **Análisis Estadísticos**:
    *   **`modelos.ipynb`**: Modelos de regresión (GEE) y análisis principales.
    *   **`Efecto tratamiento.ipynb`**: Impacto de los bloques experimentales.
    *   **`Efecto Gap.ipynb`**: Evaluación del Gap Size.
    *   **`Efecto expectativas.ipynb`**: Análisis de expectativas.
    *   **`efecto del NDC.ipynb`**: Análisis de Need for Cognition.
    *   **`descriptiv4s.ipynb`**: Análisis descriptivos básicos.

### 3. Documentación

En la carpeta `docs/` encontrará:
*   **`Diccionario de Datos`**: Definiciones de variables.
*   **`AUDITORIA.md`**: Reporte de auditoría técnica y metodológica.

---
**Nota:** El archivo `scripts/borr4dor.ipynb` es un espacio de trabajo temporal para pruebas de código.
