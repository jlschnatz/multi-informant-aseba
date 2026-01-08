# devtools::install_github("jvcasillas/contributoR")
library(contributoR)
library(ggplot2)

contr <- list(
  LS = c(1:3, 5:9, 11:14),
  MS = c(1, 6, 7, 9, 10, 14)
)

# Plot contributions
contributor(contributions = contr) +
  theme(text = element_text(family = "TeX Gyre Pagella"))

ggsave(
  filename = "preregistration/resources/contribution.svg",
  width = 6,
  height = 3.5,
  dpi = 500,
  bg = "white"
)
