# 05_modelos_estadisticos.R
# Autor: Fernando S.
# Objetivo: Modelos estadísticos GEE (Generalized Estimating Equations)
# Replica: modelos.ipynb

library(tidyverse)
library(geepack)
library(broom)

# --- CONFIGURACIÓN DE RUTAS ---
path_processed <- "../../data/processed"
path_out_tables <- "../../outputs/R_FernandoS/tables"

# --- CARGAR DATOS ---
df_long <- read_csv(file.path(path_processed, "df_long.csv"), show_col_types = FALSE)

# Preparar factores
# Mapear Dilema a Tratamiento y establecer referencia
df_long <- df_long %>%
  mutate(Tratamiento = case_when(
    str_detect(Dilema, "CON") ~ "Bloque_CON",
    str_detect(Dilema, "SIN") ~ "Bloque_SIN",
    str_detect(Dilema, "Dist") ~ "Dist",
    TRUE ~ Dilema
  )) %>%
  mutate(Tratamiento = factor(Tratamiento, levels = c("Bloque_SIN", "Bloque_CON", "Dist")),
         Genero = factor(Genero))

# Función para guardar resumen del modelo
save_model_summary <- function(model, filename) {
  # Capturar el summary como texto
  sum_obj <- summary(model)

  # Guardar en archivo de texto
  sink(file.path(path_out_tables, filename))
  print(sum_obj)
  sink()

  # También guardar coeficientes limpios en CSV
  # Usar broom si es posible, o extraer coeficientes
  coefs <- tryCatch({
    tidy(model)
  }, error = function(e) {
    as.data.frame(coef(sum_obj))
  })
  write_csv(coefs, file.path(path_out_tables, paste0(str_replace(filename, ".txt", ".csv"))))
}

# ==============================================================================
# 1. MODELOS GEE (df_long - Todos los datos)
# ==============================================================================
message("Ejecutando Modelos GEE (Dataset Completo)...")

# Modelo 1: Efecto Directo (Tratamiento * Gap)
# Formula: Mantiene ~ Tratamiento * Gap_Size
m1 <- geeglm(Mantiene ~ Tratamiento * Gap_Size,
             id = ID_Sujeto,
             data = df_long,
             family = binomial,
             corstr = "independence")

save_model_summary(m1, "modelo_1_completo.txt")

# Modelo 2: Con Controles
# Formula: + Genero + NDC + SDO
m2 <- geeglm(Mantiene ~ Tratamiento * Gap_Size + Genero + NDC_Score + SDO_Score,
             id = ID_Sujeto,
             data = df_long,
             family = binomial,
             corstr = "independence")

save_model_summary(m2, "modelo_2_controles.txt")

# Modelo 3: Socio-Político
# Formula: + nivel_se + politica
m3 <- geeglm(Mantiene ~ Tratamiento * Gap_Size + Genero + NDC_Score + SDO_Score + nivel_se + politica,
             id = ID_Sujeto,
             data = df_long,
             family = binomial,
             corstr = "independence")

save_model_summary(m3, "modelo_3_sociopolitico.txt")


# ==============================================================================
# 2. MODELOS SOBRE EXPECTATIVAS FILTRADAS
# ==============================================================================
message("Ejecutando Modelos GEE (Expectativas Filtradas)...")

df_exp <- read_csv(file.path(path_processed, "df_expectativas_filtrada.csv"), show_col_types = FALSE)
df_exp <- df_exp %>%
  mutate(Tratamiento = case_when(
    str_detect(Dilema, "CON") ~ "Bloque_CON",
    str_detect(Dilema, "SIN") ~ "Bloque_SIN",
    str_detect(Dilema, "Dist") ~ "Dist",
    TRUE ~ Dilema
  )) %>%
  mutate(Tratamiento = factor(Tratamiento, levels = c("Bloque_SIN", "Bloque_CON", "Dist")),
         Genero = factor(Genero))

m1_exp <- geeglm(Mantiene ~ Tratamiento * Gap_Size,
                 id = ID_Sujeto,
                 data = df_exp,
                 family = binomial,
                 corstr = "independence")
save_model_summary(m1_exp, "modelo_1_expectativas.txt")

m2_exp <- geeglm(Mantiene ~ Tratamiento * Gap_Size + Genero + NDC_Score + SDO_Score,
                 id = ID_Sujeto,
                 data = df_exp,
                 family = binomial,
                 corstr = "independence")
save_model_summary(m2_exp, "modelo_2_expectativas.txt")


# ==============================================================================
# 3. ANOVA (Réplica aproximada de AnovaRM)
# ==============================================================================
# En R, para medidas repetidas binarias, GEE es preferible.
# Pero para replicar la lógica de "Promedios por sujeto" y ANOVA:

# Preparar datos agregados (promedio por sujeto y condición)
df_agg <- df_long %>%
  group_by(ID_Sujeto, Tratamiento) %>%
  summarise(Mantiene_Mean = mean(Mantiene, na.rm = TRUE), .groups = 'drop')

# ANOVA de medidas repetidas (usando aov o lme4)
# Mantiene ~ Tratamiento + Error(ID_Sujeto/Tratamiento)
anova_res <- aov(Mantiene_Mean ~ Tratamiento + Error(ID_Sujeto/Tratamiento), data = df_agg)

# Guardar resultados
sink(file.path(path_out_tables, "anova_tratamiento.txt"))
print(summary(anova_res))
sink()

message("Modelos estadísticos completados.")
