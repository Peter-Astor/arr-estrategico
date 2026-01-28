# 04_analisis_ndc_expectativas.R
# Autor: Fernando S.
# Objetivo: Análisis del efecto de Need for Cognition (NDC) y Expectativas
# Replica: efecto del NDC.ipynb, Efecto expectativas.ipynb

library(tidyverse)
library(ggplot2)

# --- CONFIGURACIÓN DE RUTAS ---
path_processed <- "../../data/processed"
path_out_plots <- "../../outputs/R_FernandoS/plots"
path_out_tables <- "../../outputs/R_FernandoS/tables"

# --- CARGAR DATOS ---
df_long <- read_csv(file.path(path_processed, "df_long.csv"), show_col_types = FALSE)

# Sujetos únicos para cálculos de mediana
sujetos_unicos <- df_long %>%
  distinct(ID_Sujeto, .keep_all = TRUE)

median_ndc <- median(sujetos_unicos$NDC_Score, na.rm = TRUE)

# ==============================================================================
# 1. EFECTO DEL NDC (efecto del NDC.ipynb)
# ==============================================================================
message("Generando análisis de NDC...")

# Crear grupos NDC en el dataframe largo
df_ndc <- df_long %>%
  mutate(NDC_Group = if_else(NDC_Score > median_ndc, "High NDC", "Low NDC"))

# Estandarizar nombres de Dilema si es necesario (asumiendo que ya están limpios, pero por seguridad)
# En limpieza.R ya están como Bloque_CON, Bloque_SIN, Dist.
# Mapear a CON, SIN, DIST para graficar
df_ndc <- df_ndc %>%
  mutate(Tratamiento = case_when(
    str_detect(Dilema, "CON") ~ "CON",
    str_detect(Dilema, "SIN") ~ "SIN",
    str_detect(Dilema, "Dist") ~ "DIST",
    TRUE ~ Dilema
  ))

# Tabla Resumen
resumen_ndc <- df_ndc %>%
  group_by(NDC_Group, Tratamiento) %>%
  summarise(
    N = n_distinct(ID_Sujeto),
    Mean_Mantiene = mean(Mantiene, na.rm = TRUE),
    SD_Mantiene = sd(Mantiene, na.rm = TRUE),
    .groups = 'drop'
  )

write_csv(resumen_ndc, file.path(path_out_tables, "tabla_ndc_tratamiento.csv"))

# Gráfico
p_ndc <- ggplot(df_ndc, aes(x = Tratamiento, y = Mantiene, fill = NDC_Group)) +
  stat_summary(fun = mean, geom = "bar", position = position_dodge(0.9), alpha = 0.8) +
  stat_summary(fun.data = mean_se, geom = "errorbar", position = position_dodge(0.9), width = 0.2) +
  labs(title = paste0("Efecto del NDC (Mediana = ", round(median_ndc, 2), ")"),
       y = "Tasa Media de 'Mantiene'", x = "Tratamiento") +
  theme_minimal() +
  scale_fill_manual(values = c("High NDC" = "#55a868", "Low NDC" = "#4c72b0"))

ggsave(file.path(path_out_plots, "efecto_ndc_tratamiento.png"), p_ndc, width = 8, height = 6)


# ==============================================================================
# 2. EFECTO EXPECTATIVAS (General)
# ==============================================================================
message("Generando análisis descriptivo de Expectativas...")

# Ver cómo influye la expectativa activa (-1, 0, 1) en la decisión
# -1: Espera que Opc2 aumente coop (Revierte)
# 0: No espera efecto
# 1: Espera que Opc1 aumente coop (Mantiene)

resumen_exp <- df_long %>%
  group_by(Expectativa_Activa) %>%
  summarise(
    Mean_Mantiene = mean(Mantiene, na.rm = TRUE),
    N = n(),
    .groups = 'drop'
  )

write_csv(resumen_exp, file.path(path_out_tables, "tabla_expectativas_mantiene.csv"))

p_exp <- ggplot(df_long, aes(x = factor(Expectativa_Activa), y = Mantiene)) +
  stat_summary(fun = mean, geom = "bar", fill = "coral", alpha = 0.7) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2) +
  labs(title = "Tasa de 'Mantiene' según Expectativa Activa",
       x = "Expectativa (-1: Revierte, 0: Neutro, 1: Mantiene)",
       y = "Proporción Mantiene") +
  theme_minimal()

ggsave(file.path(path_out_plots, "efecto_expectativas.png"), p_exp, width = 6, height = 5)

message("Análisis NDC y Expectativas finalizado.")
