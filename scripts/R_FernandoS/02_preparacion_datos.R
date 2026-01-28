# 02_preparacion_datos.R
# Autor: Fernando S.
# Objetivo: Generar datasets derivados para análisis específicos (Expectativas, NDC)
# Replica la lógica de preparación de 'Efecto expectativas.ipynb' y 'efecto del NDC.ipynb'

library(tidyverse)

# --- CONFIGURACIÓN DE RUTAS ---
path_processed <- "../../data/processed"

# --- 1. CARGAR DATOS ---
message("Cargando df_long.csv...")
df_long <- read_csv(file.path(path_processed, "df_long.csv"), show_col_types = FALSE)

# --- 2. DATASET EXPECTATIVAS FILTRADA ---
# Filtrar filas donde Expectativa_Activa != 0
message("Generando df_expectativas_filtrada...")
df_expectativas_filtrada <- df_long %>%
  filter(Expectativa_Activa != 0)

write_csv(df_expectativas_filtrada, file.path(path_processed, "df_expectativas_filtrada.csv"))
message("Guardado: df_expectativas_filtrada.csv")

# --- 3. DATASET HIGH NDC ---
# Calcular la mediana del NDC Score (basado en sujetos únicos)
sujetos_unicos <- df_long %>%
  distinct(ID_Sujeto, .keep_all = TRUE)

median_ndc <- median(sujetos_unicos$NDC_Score, na.rm = TRUE)
message(paste("Mediana NDC (Sujetos únicos):", round(median_ndc, 2)))

# Identificar sujetos High NDC (> mediana)
sujetos_high_ndc <- sujetos_unicos %>%
  filter(NDC_Score > median_ndc) %>%
  pull(ID_Sujeto)

# Filtrar el dataframe completo para esos sujetos
message("Generando df_high_ndc...")
df_high_ndc <- df_long %>%
  filter(ID_Sujeto %in% sujetos_high_ndc)

write_csv(df_high_ndc, file.path(path_processed, "df_high_ndc.csv"))
message("Guardado: df_high_ndc.csv")

# --- 4. DATASET EXPECTATIVAS NDC (High NDC + Expectativa Activa) ---
# Intersección de los dos filtros anteriores
message("Generando df_expectativas_ndc...")
df_expectativas_ndc <- df_high_ndc %>%
  filter(Expectativa_Activa != 0)

write_csv(df_expectativas_ndc, file.path(path_processed, "df_expectativas_ndc.csv"))
message("Guardado: df_expectativas_ndc.csv")

message("Preparación de datos derivada completada.")
