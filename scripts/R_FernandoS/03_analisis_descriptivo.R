# 03_analisis_descriptivo.R
# Autor: Fernando S.
# Objetivo: Análisis descriptivos y visualizaciones principales (Gap, Tratamiento, Demográficos)
# Replica: descriptiv4s.ipynb, Efecto Gap.ipynb, Efecto tratamiento.ipynb

library(tidyverse)
library(ggplot2)

# --- CONFIGURACIÓN DE RUTAS ---
path_processed <- "../../data/processed"
path_out_plots <- "../../outputs/R_FernandoS/plots"
path_out_tables <- "../../outputs/R_FernandoS/tables"

# Crear directorios si no existen
if (!dir.exists(path_out_plots)) dir.create(path_out_plots, recursive = TRUE)
if (!dir.exists(path_out_tables)) dir.create(path_out_tables, recursive = TRUE)

# --- CARGAR DATOS ---
df_long <- read_csv(file.path(path_processed, "df_long.csv"), show_col_types = FALSE)

# Sujetos únicos para demográficos y niveles agregado
df_unicos <- df_long %>%
  distinct(ID_Sujeto, .keep_all = TRUE)

# ==============================================================================
# 1. DEMOGRÁFICOS (descriptiv4s.ipynb)
# ==============================================================================
message("Generando análisis demográfico...")

# Distribución de Género
p_genero <- ggplot(df_unicos, aes(x = Genero)) +
  geom_bar(fill = "steelblue") +
  theme_minimal() +
  labs(title = "Distribución de Género", y = "Cantidad de Participantes")

ggsave(file.path(path_out_plots, "distribucion_genero.png"), p_genero, width = 6, height = 4)

# Histogramas SDO y NDC
p_sdo <- ggplot(df_unicos, aes(x = SDO_Score)) +
  geom_histogram(binwidth = 0.5, fill = "purple", alpha = 0.7, color = "black") +
  geom_density(aes(y = ..count.. * 0.5), color = "darkblue", size = 1) +
  theme_minimal() +
  labs(title = "Distribución SDO Score")

ggsave(file.path(path_out_plots, "hist_sdo.png"), p_sdo, width = 6, height = 4)

p_ndc <- ggplot(df_unicos, aes(x = NDC_Score)) +
  geom_histogram(binwidth = 0.5, fill = "orange", alpha = 0.7, color = "black") +
  geom_density(aes(y = ..count.. * 0.5), color = "red", size = 1) +
  theme_minimal() +
  labs(title = "Distribución NDC Score")

ggsave(file.path(path_out_plots, "hist_ndc.png"), p_ndc, width = 6, height = 4)


# ==============================================================================
# 2. EFECTO GAP (Efecto Gap.ipynb)
# ==============================================================================
message("Generando análisis de Efecto Gap...")

# A. Promedio Global por Gap
# Pivotar las columnas Promedio_Gap_X
cols_gap <- names(df_unicos)[grep("Promedio_Gap_", names(df_unicos))]
df_plot_gap <- df_unicos %>%
  select(ID_Sujeto, all_of(cols_gap)) %>%
  pivot_longer(cols = all_of(cols_gap), names_to = "Gap_Col", values_to = "Valor") %>%
  mutate(Gap = as.numeric(str_extract(Gap_Col, "\\d+")))

# Tabla resumen
tabla_gap_global <- df_plot_gap %>%
  group_by(Gap) %>%
  summarise(
    count = n(),
    mean = mean(Valor, na.rm = TRUE),
    std = sd(Valor, na.rm = TRUE)
  ) %>%
  mutate(Diff_vs_50 = round(mean - 0.5, 3))

write_csv(tabla_gap_global, file.path(path_out_tables, "tabla_gap_global.csv"))

# Gráfico Global Gap
p_gap_global <- ggplot(df_plot_gap, aes(x = factor(Gap), y = Valor)) +
  stat_summary(fun = mean, geom = "bar", fill = "skyblue", alpha = 0.7) +
  stat_summary(fun.data = mean_sdl, geom = "errorbar", width = 0.2) +
  geom_jitter(width = 0.2, alpha = 0.1) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "Análisis Global por Gap Size (Promedio Ensayos)",
       x = "Tamaño del Gap", y = "Proporción (Mantiene)")

ggsave(file.path(path_out_plots, "gap_global.png"), p_gap_global, width = 8, height = 6)


# B. Primera Aparición por Gap
# Tomar la primera fila para cada combinación de Sujeto y Gap_Size
df_primera_gap <- df_long %>%
  group_by(ID_Sujeto, Gap_Size) %>%
  slice(1) %>%
  ungroup()

tabla_gap_primera <- df_primera_gap %>%
  group_by(Gap_Size) %>%
  summarise(
    count = n(),
    mean = mean(Mantiene, na.rm = TRUE),
    std = sd(Mantiene, na.rm = TRUE)
  ) %>%
  mutate(Diff_vs_50 = round(mean - 0.5, 3))

write_csv(tabla_gap_primera, file.path(path_out_tables, "tabla_gap_primera.csv"))

p_gap_primera <- ggplot(df_primera_gap, aes(x = factor(Gap_Size), y = Mantiene)) +
  stat_summary(fun = mean, geom = "bar", fill = "lightgreen", alpha = 0.7) +
  stat_summary(fun.data = mean_sdl, geom = "errorbar", width = 0.2) +
  geom_jitter(width = 0.2, alpha = 0.1) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "Primera Aparición por Gap Size",
       x = "Tamaño del Gap", y = "Proporción (Mantiene)")

ggsave(file.path(path_out_plots, "gap_primera.png"), p_gap_primera, width = 8, height = 6)


# ==============================================================================
# 3. EFECTO TRATAMIENTO (Efecto tratamiento.ipynb)
# ==============================================================================
message("Generando análisis de Efecto Tratamiento...")

# A. Promedios Generales (CON, SIN, DIST)
df_proms_trat <- df_unicos %>%
  select(ID_Sujeto, Promedio_CON, Promedio_SIN, Promedio_DIST) %>%
  pivot_longer(cols = c(Promedio_CON, Promedio_SIN, Promedio_DIST),
               names_to = "Condicion_Raw", values_to = "Valor") %>%
  mutate(Condicion = str_replace(Condicion_Raw, "Promedio_", ""))

tabla_trat_global <- df_proms_trat %>%
  group_by(Condicion) %>%
  summarise(
    count = n(),
    mean = mean(Valor, na.rm = TRUE),
    std = sd(Valor, na.rm = TRUE)
  )
write_csv(tabla_trat_global, file.path(path_out_tables, "tabla_tratamiento_global.csv"))

# Gráfico Tratamiento
p_trat <- ggplot(df_proms_trat, aes(x = Condicion, y = Valor)) +
  stat_summary(fun = mean, geom = "bar", fill = "#66b3ff", alpha = 0.7) +
  stat_summary(fun.data = mean_sdl, geom = "errorbar", width = 0.2) +
  geom_jitter(width = 0.2, alpha = 0.2) +
  theme_minimal() +
  labs(title = "Promedios Generales por Tratamiento", x = "Condición", y = "Valor")

ggsave(file.path(path_out_plots, "tratamiento_global.png"), p_trat, width = 6, height = 6)

# B. Delta Intra-Sujeto (CON - SIN)
# df_unicos ya tiene Delta_Mantiene calculado en limpieza
p_delta <- ggplot(df_unicos, aes(y = Delta_Mantiene)) +
  geom_boxplot(fill = "#9b59b6", alpha = 0.6) +
  geom_jitter(aes(x=0), width = 0.1, alpha = 0.3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "Delta Intra-Sujeto (CON - SIN)", x = "", y = "Diferencia de Proporción") +
  theme(axis.text.x = element_blank())

ggsave(file.path(path_out_plots, "delta_boxplot.png"), p_delta, width = 4, height = 6)

message("Análisis descriptivos finalizados.")
