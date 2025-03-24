# ui/utils_theme.R

# Function to define custom UI theme for the app
get_gltx_theme <- function() {
  bs_theme(
  bootswatch = "flatly",
  primary = "#1D1D1F",
  secondary = "#2C2C2E",
  success = "#6E6E73",
  info = "#A3A3A3",
  warning = "#D1D1D6",
  danger = "#E5E5EA"
  )
}
