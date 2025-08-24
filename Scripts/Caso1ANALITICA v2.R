# install.packages("readxl")
# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("scales")

setwd("C:/Users/Lenovo/Documents/Proyecto")

library(readxl)
library(dplyr)
library(ggplot2)
library(scales)

# --- PASO 1: LECTURA Y PREPARACIÓN INICIAL DE DATOS ---

# 1.1. Leer financials.xls y establecer nombres de columna
financials_df <- read_excel("financials.xls")
names(financials_df)[1:2] <- c("Week (2008)", "Week (2009)")

# 1.2. Leer y procesar dinámicamente Weekly Visits.xls
visits_raw_df <- read_excel("Weekly Visits.xls", col_names = FALSE)
visits_raw_df <- as.data.frame(visits_raw_df)

separator_indices <- which(grepl("#####", visits_raw_df[, 1]))
start_rows <- c(1, separator_indices + 1)
end_rows <- c(separator_indices - 1, nrow(visits_raw_df))
channel_names <- c("Direct", "Referral", "Organic", "Unknown") 
df_list <- list()

for (i in 1:length(start_rows)) {
  current_block <- visits_raw_df[start_rows[i]:end_rows[i], ]
  block_headers <- as.character(current_block[1, ])
  current_data <- current_block[-1, ]
  names(current_data) <- block_headers[1:ncol(current_data)]
  current_data$channel <- channel_names[i]
  df_list[[i]] <- current_data
}
visits_df <- do.call(rbind, df_list)

# Forzar la conversión a numérico en ambas tablas
visits_df <- visits_df %>% mutate(across(-channel, as.numeric))
financials_df <- financials_df %>% mutate(across(everything(), as.numeric))


# --- PASO 2: CREACIÓN DE UNA CLAVE DE UNIÓN FIABLE Y UNIÓN FINAL ---

# 1. Creamos una tabla con las semanas únicas de visits_df y le añadimos un índice.
unique_weeks_with_index <- visits_df %>%
  select(`Week (2008)`, `Week (2009)`) %>%
  distinct() %>%
  arrange(`Week (2008)`) %>%
  mutate(week_index = row_number())

# 2. Añadimos este índice a nuestra tabla principal de visitas.
visits_with_index_df <- left_join(visits_df, unique_weeks_with_index, by = c("Week (2008)", "Week (2009)"))

# 3. Añadimos un índice a la tabla de financials (simplemente el número de fila).
financials_with_index_df <- financials_df %>%
  mutate(week_index = row_number())

# 4. Unimos las tablas usando el "week_index".
df_final <- left_join(visits_with_index_df, financials_with_index_df, by = "week_index")


# --- PASO 3: LIMPIEZA FINAL Y ANÁLISIS ---

# 3.1. Crear la columna de fecha y limpiar las columnas sobrantes
df_final$Date <- as.Date(df_final$`Week (2009).x`, origin = "1899-12-30")

df_final <- df_final %>%
  select(Date, Revenue, Profit, `Lbs. Sold`, Inquiries, Visits, `Unique Visits`, Pageviews, `Pages/Visit`, `Avg. Time on Site (secs.)`, `Bounce Rate`, `% New Visits`, channel)

# 3.2. Calcular la correlación
correlation_matrix <- cor(df_final[, c("Revenue", "Visits", "Unique Visits", "Pageviews")])
cat("\n--- Matriz de Correlación ---\n")
print(correlation_matrix)

# 3.3. Gráfico de series de tiempo para 'Profit'
profit_timeseries_plot <- ggplot(df_final, aes(x = Date, y = Profit)) +
  geom_line(color = "#0072B2", size = 1) +
  labs(title = "Evolución del Beneficio (Profit) a lo Largo del Tiempo", x = "Fecha", y = "Beneficio ($)") +
  scale_y_continuous(labels = scales::dollar) + theme_minimal()
ggsave("profit_evolution.png", plot = profit_timeseries_plot, width = 10, height = 6)
cat("\nGráfico 'profit_evolution.png' guardado.\n")

# 3.4. Gráfico de barras de visitas totales por canal
visits_by_channel <- df_final %>%
  group_by(channel) %>%
  summarise(Total_Visits = sum(Visits, na.rm = TRUE)) %>%
  arrange(desc(Total_Visits))
visits_barchart <- ggplot(visits_by_channel, aes(x = reorder(channel, -Total_Visits), y = Total_Visits, fill = channel)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::comma(Total_Visits)), vjust = -0.3, size = 4) +
  labs(title = "Comparación de Visitas Totales por Canal", x = "Canal de Tráfico", y = "Número Total de Visitas") +
  scale_y_continuous(labels = scales::comma) + theme_minimal() + theme(legend.position = "none")
ggsave("visits_by_channel.png", plot = visits_barchart, width = 10, height = 6)
cat("Gráfico 'visits_by_channel.png' guardado.\n\n")

# Mostrar un resumen del dataframe final para verificar que ahora tiene datos
cat("--- Vista previa del DataFrame final ---\n")
print(head(df_final))


# Grafico de dispersion libras vs ingresos
print(
  ggplot(plot_data, aes(x = Lbs..Sold, y = Revenue)) +
    geom_point(color = "blue", size = 3, alpha = 0.7) +
    geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
    labs(
      title = "Relación entre Ingresos y Libras Vendidas",
      x = "Libras Vendidas",
      y = "Ingresos ($)"
    ) +
    theme_minimal(base_size = 15) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
)
#coeficiente de correlacion libras e ingresos 
correlacion_Libras <- cor(plot_data$Revenue, plot_data$Lbs..Sold, use = "complete.obs")
print(paste("Coeficiente de correlación entre Ingresos y Libras Vendidas:", round(correlacion, 4)))


# diagrama de dispersion visitas vs ingresos
ggplot(plot_data, aes(x = Unique.Visits, y = Revenue)) +
  geom_point(color = "darkgreen", size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(
    title = "Relación entre Ingresos y Visitas Únicas",
    x = "Visitas Únicas",
    y = "Ingresos ($)"
  ) +
  theme_minimal(base_size = 15) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
#coeficiente de correlcion visitas e ingresos 
correlacion_visitas <- cor(plot_data$Revenue, plot_data$Unique.Visits, use = "complete.obs")
print(paste("Coeficiente de correlación entre Ingresos y Visitas Únicas:", round(correlacion_visitas, 4)))

# --- PUNTO 8: ANÁLISIS DE LIBRAS VENDIDAS ---

lbs_sold_df <- read_excel("Lbs. Sold.xls")

lbs_sold_df <- lbs_sold_df %>%
  mutate(`Lbs. Sold` = as.numeric(`Lbs. Sold`))

# Calcular las estadísticas
media_lbs <- mean(lbs_sold_df$`Lbs. Sold`, na.rm = TRUE)
mediana_lbs <- median(lbs_sold_df$`Lbs. Sold`, na.rm = TRUE)
desviacion_lbs <- sd(lbs_sold_df$`Lbs. Sold`, na.rm = TRUE)

# 5. Imprimir los resultados
cat("--- Punto 8: Análisis de Libras Vendidas ---\n")
cat("Media (Promedio):", format(round(media_lbs, 1), nsmall = 1, big.mark = ","), "libras\n")
cat("Mediana (Valor central):", format(round(mediana_lbs, 1), nsmall = 1, big.mark = ","), "libras\n")
cat("Desviación Estándar:", format(round(desviacion_lbs, 1), nsmall = 1, big.mark = ","), "libras\n")


# --- PUNTO 9: GRÁFICO DE VISITAS DIARIAS ---

# Leer el archivo y convertir la columna de día a fecha
daily_visits_df <- read_excel("Daily Visits.xls") %>%
  mutate(Date = as.Date(Day, origin = "1899-12-30"))

# Crear el gráfico de series de tiempo
daily_visits_plot <- ggplot(daily_visits_df, aes(x = Date, y = Visits)) +
  geom_line(color = "#0072B2", size = 0.8) +
  labs(
    title = "Evolución de las Visitas Diarias",
    x = "Fecha",
    y = "Número de Visitas"
  ) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
  scale_y_continuous(labels = comma) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Guardar el gráfico
ggsave("daily_visits_timeseries.png", plot = daily_visits_plot, width = 10, height = 6)

cat("--- Punto 9: Gráfico de Visitas Diarias ---\n")
cat("El gráfico 'daily_visits_timeseries.png' ha sido guardado.\n")
