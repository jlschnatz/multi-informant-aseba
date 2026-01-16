# set.seed(42)
# library(lavaan)
# library(stuart)
# library(glue)
#
# data(fairplayer, package = "stuart")
#
# dat1 <- fairplayer[, grep(
#   "(s|t)EM\\d{2}t1$",
#   colnames(fairplayer),
#   value = TRUE
# )]
# dat2 <- fairplayer[, grep(
#   "(s|t)SI\\d{2}t1$",
#   colnames(fairplayer),
#   value = TRUE
# )]
#
# fs1 <- list(
#   CIC = grep("^s", colnames(dat1), value = TRUE),
#   CIP = grep("^t", colnames(dat1), value = TRUE),
#   ISC = grep("^s", colnames(dat1), value = TRUE),
#   ISP = grep("^t", colnames(dat1), value = TRUE)
# )
#
# fs2 <- list(
#   CIC = grep("^s", colnames(dat2), value = TRUE),
#   CIP = grep("^t", colnames(dat2), value = TRUE),
#   ISC = grep("^s", colnames(dat2), value = TRUE),
#   ISP = grep("^t", colnames(dat2), value = TRUE)
# )
#
# mtmm <- list(
#   CI = c("CIC", "CIP"),
#   ISP = "ISP",
#   ISC = "ISC"
# )
#
# capacity <- 2
#
# stuart:::data.prep(dat1, fs1, capacity = 2, mtmm = # mtmm)
#
# rs1 <- randomsamples(
#   data = dat1,
#   factor.structure = fs1,
#   capacity = capacity,
#   mtmm = mtmm,
#   cores = 1,
#   n = 1000
# )
#
# rs2 <- randomsamples(
#   data = dat2,
#   factor.structure = fs2,
#   capacity = capacity,
#   mtmm = mtmm,
#   cores = 1,
#   n = 1000
# )
#
# fit1 <- rs1$final
# fit2 <- rs2$final
#
# fscores1 <- lavPredict(fit1, method = "Bartlett", se = # "standard")
# colnames(fscores1) <- paste0(colnames(fscores1), "_1")
# se1 <- attr(fscores1, "se")[[1]][1, ]
# names(se1) <- colnames(fscores1)
#
# fscores2 <- lavPredict(fit2, method = "Bartlett", se = # "standard")
# colnames(fscores2) <- paste0(colnames(fscores2), "_2")
# se2 <- attr(fscores2, "se")[[1]][1, ]
# names(se2) <- colnames(fscores2)
#
# mod1 <- paste(
#   glue(
#     "{names(se1)}_adj =~ 1 * {names(se1)}\n{names# (se1)} ~~ {se1^2} * {names(se1)}"
#   ),
#   collapse = "\n"
# )
# cat(mod1)
#
# mod2 <- paste(
#   glue(
#     "{names(se2)}_adj =~ 1 * {names(se2)}\n{names# (se2)} ~~ {se2^2} * {names(se2)}"
#   ),
#   collapse = "\n"
# )
# cat(mod2)
#
# fit1 <- cfa(mod1, fscores1)
# fit2 <- cfa(mod2, fscores2)
#
# fit <- sem(paste(mod1, mod2, sep = "\n"), cbind# (fscores1, fscores2), std.lv = TRUE)
# summary(fit, fit.measures = TRUE, standardized = TRUE)
#
# inspect(fit, "est")$psi
# round(cov(cbind(fscores1, fscores2), use = "pairwise.# complete.obs"), 3)
#
#
# estimate_fscores <- function(x) {
#   stopifnot(inherits(x, "stuartOutput"))
#   fit <- x$final
#   fscores <- lavaan::lavPredict(fit, method = # "Bartlett", se = "standard")
#   se <- attr(fscores, "se")[[1]][1, ]
#   model <- paste(
#     sprintf(
#       "%s_adj =~ 1*%s\n%s ~~ %g*%s",
#       names(se),
#       names(se),
#       names(se),
#       se^2,
#       names(se)
#     ),
#     collapse = "\n"
#   )
#   out <- list(fscores = as.data.frame(fscores), se = # se, model = model)
#   return(out)
# }
