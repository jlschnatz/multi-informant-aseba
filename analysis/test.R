library(lavaan)
library(ShortForm)
 
 # --- Example CFA model ---
 model <- 'f1 =~ x1 + x2 + x3; f2 =~ x4 + x5 + x6'

 fit <- cfa(model, data = HolzingerSwineford1939)
 
 # --- Extract and modify parameter table ---
 pt <- parameterTable(fit)


 
 # Fix all loadings at their estimated values
 is_loading <- pt$op == "=~"
 pt$free[is_loading]   <- 0
 pt$ustart[is_loading] <- pt$est[is_loading]


 refit.model(fit, parTable(fit))
 
 # --- Refit model from parameter table ---
 fit_fixed <- lavaan(model = pt, data = HolzingerSwineford1939, fixed.x = FALSE)
 
 # --- Inspect results ---
 summary(fit_fixed, standardized = TRUE)

 ?parameterTable
