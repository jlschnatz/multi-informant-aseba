pacman::p_load(dplyr, tidyr, ggplot2, systemfonts, ggdist)

logdata <- readRDS("data/processed/objective_criteria_log.rds")
colnames(logdata) <- c(
  "subscale_id",
  "run",
  "pheromone",
  "rmsea.robust",
  "srmr",
  "gamma",
  "phi",
  "omega_cic",
  "omega_cip",
  "omega_isc",
  "omega_isp"
)

criteria_level <- c(
  "&tau; \U2192",
  "\U2190 RMSEA",
  "\U2190 SRMR",
  "&gamma; \U2192",
  "\U2192 &phi; \U2190",
  "&omega;<sub>CIC</sub> \U2192",
  "&omega;<sub>CIP</sub> \U2192",
  "&omega;<sub>ISC</sub> \U2192",
  "&omega;<sub>ISP</sub> \U2192"
)

logdata$subscale_id <- as.factor(logdata$subscale_id)
mvc_data <- readRDS("data/processed/mvc_testing.rds") |>
  select(subscale_id, criterion, cutoff)


# Create data subset that meets the cutoffs for the RMSEA and SRMR for each subscale
data_goodfit <- logdata |>
  pivot_longer(
    -c(subscale_id, run, pheromone),
    names_to = "criterion",
    values_to = "value"
  ) |>
  full_join(mvc_data, by = join_by(subscale_id, criterion)) |>
  mutate(subscale_id = as.factor(subscale_id)) |>
  filter(criterion %in% c("rmsea.robust", "srmr")) |>
  mutate(below_cutoff = value < cutoff) |>
  group_by(subscale_id, run) |>
  filter(all(below_cutoff)) |>
  ungroup() |>
  select(subscale_id, run)


# long-format
data_goodfit_long <- data_goodfit |>
  left_join(logdata, by = join_by(subscale_id, run)) |>
  pivot_longer(
    -c(subscale_id, run),
    names_to = "criterion",
    values_to = "value"
  ) |>
  dplyr::mutate(
    criterion = factor(
      dplyr::case_match(
        criterion,
        "gamma" ~ "&gamma; \U2192",
        "phi" ~ "\U2192 &phi; \U2190",
        "omega_cic" ~ "&omega;<sub>CIC</sub> \U2192",
        "omega_cip" ~ "&omega;<sub>CIP</sub> \U2192",
        "omega_isc" ~ "&omega;<sub>ISC</sub> \U2192",
        "omega_isp" ~ "&omega;<sub>ISP</sub> \U2192",
        "rmsea.robust" ~ "\U2190 RMSEA",
        "srmr" ~ "\U2190 SRMR",
        "pheromone" ~ "&tau; \U2192"
      ),
      levels = criteria_level
    )
  )


# Given the sample of solutions with RMSEA and SRMR < Cutoff, find:
# 1. Solution which fullfills min(RMSEA + SRMR)
# 2. max(Pheromone)
# for each clinical subscale
data_search <- data_goodfit |>
  left_join(logdata, by = join_by(subscale_id, run)) |>
  rowwise() |>
  mutate(joint_fit = sum(rmsea.robust, srmr)) |>
  ungroup() |>
  mutate(
    fit_min = joint_fit == min(joint_fit),
    pheromone_max = pheromone == max(pheromone),
    .by = subscale_id
  ) |>
  filter(pheromone_max | fit_min) |>
  distinct() |>
  mutate(min_method = if_else(fit_min, "fit-min", "pheromone-max")) |>
  select(-c(fit_min, pheromone_max, joint_fit)) |>
  pivot_longer(
    -c(subscale_id, run, min_method),
    names_to = "criterion"
  ) |>
  dplyr::mutate(
    criterion = factor(
      dplyr::case_match(
        criterion,
        "gamma" ~ "&gamma; \U2192",
        "phi" ~ "\U2192 &phi; \U2190",
        "omega_cic" ~ "&omega;<sub>CIC</sub> \U2192",
        "omega_cip" ~ "&omega;<sub>CIP</sub> \U2192",
        "omega_isc" ~ "&omega;<sub>ISC</sub> \U2192",
        "omega_isp" ~ "&omega;<sub>ISP</sub> \U2192",
        "rmsea.robust" ~ "\U2190 RMSEA",
        "srmr" ~ "\U2190 SRMR",
        "pheromone" ~ "&tau; \U2192"
      ),
      levels = criteria_level
    )
  )

data_goodfit_long |>
  dplyr::mutate(
    q01 = quantile(value, 0.01),
    q99 = quantile(value, 0.99),
    .by = c(criterion, subscale_id)
  ) |>
  dplyr::filter(dplyr::between(value, q01, q99)) |>
  ggplot(aes(x = value, y = factor(subscale_id))) +
  facet_wrap(~criterion, scales = "free_x", drop = FALSE) +
  scale_y_discrete(drop = FALSE, limits = levels(data_goodfit$subscale_id)) +
  stat_slab(
    normalize = "xy",
    density = ggdist::density_unbounded(bandwidth = "nrd"),
    fill = "grey80"
  ) +
  stat_spike(
    data = data_search,
    aes(x = value, color = min_method),
    size = 0,
    linewidth = 1,
    density = ggdist::density_unbounded(bandwidth = "nrd")
  ) +
  ggh4x::facetted_pos_scales(
    x = list(
      criterion == "&tau; \U2192" ~ ggplot2::scale_x_continuous(
        limits = c(0, 1),
        expand = ggplot2::expansion(),
        breaks = seq(0, 1, 0.2)
      ),
      criterion == "&gamma; \U2192" ~ ggplot2::scale_x_continuous(
        limits = c(0, 10),
        expand = ggplot2::expansion(),
        breaks = seq(0, 10, 2)
      ),
      criterion == "&omega;<sub>CIC</sub> \U2192" ~ ggplot2::scale_x_continuous(
        limits = c(0, 1),
        expand = ggplot2::expansion(),
        breaks = seq(0, 1, 0.2)
      ),
      criterion == "&omega;<sub>CIP</sub> \U2192" ~ ggplot2::scale_x_continuous(
        limits = c(0, 1),
        expand = ggplot2::expansion(),
        breaks = seq(0, 1, 0.2)
      ),
      criterion == "&omega;<sub>ISC</sub> \U2192" ~ ggplot2::scale_x_continuous(
        limits = c(0, 1),
        expand = ggplot2::expansion(),
        breaks = seq(0, 1, 0.2)
      ),
      criterion == "&omega;<sub>ISP</sub> \U2192" ~ ggplot2::scale_x_continuous(
        limits = c(0, 1),
        expand = ggplot2::expansion(),
        breaks = seq(0, 1, 0.2)
      ),
      criterion == "\U2192 &phi; \U2190" ~ ggplot2::scale_x_continuous(
        limits = c(-1, 1),
        expand = ggplot2::expansion(),
        breaks = seq(-1, 1, 0.5),
        labels = scales::label_number()
      ),
      criterion == "\U2190 RMSEA" ~ ggplot2::scale_x_continuous(
        limits = c(0, 0.05),
        expand = expansion(),
        breaks = seq(0, 0.05, 0.01)
      ),
      criterion == "\U2190 SRMR" ~ ggplot2::scale_x_continuous(
        limits = c(0, 0.05),
        expand = ggplot2::expansion(),
        breaks = seq(0, 0.06, 0.01)
      )
    )
  ) +
  scale_color_manual(
    name = "Method",
    labels = c("min(RMSEA + SRMR)", "max(&tau;)"),
    values = c("#008080", "#B7410E")
  ) +
  coord_cartesian(clip = "off") +
  ggplot2::ylab("Clinical Subscale") +
  ggplot2::xlab("Criterion Value") +
  ggplot2::theme_minimal(base_family = "Libertinus Sans", base_size = 12) +
  ggplot2::theme(
    strip.text = ggtext::element_markdown(size = 13),
    panel.spacing.x = ggplot2::unit(0.75, "cm"),
    panel.background = element_rect(color = "lightgray"),
    plot.margin = ggplot2::margin(10, 10, 10, 10),
    axis.text.y.left = ggplot2::element_text(size = 12),
    axis.text.x.bottom = ggplot2::element_text(size = 12),
    axis.title.x.bottom = ggplot2::element_text(
      size = 14,
      margin = ggplot2::margin(t = 10)
    ),
    legend.text = ggtext::element_markdown(size = 13),
    legend.title = ggplot2::element_text(size = 14),
    axis.title.y.left = ggplot2::element_text(
      size = 14,
      margin = ggplot2::margin(r = 10)
    ),
    panel.grid.major.y = ggplot2::element_blank(),
    legend.position = "bottom"
  ) -> p

ggsave(
  "figures/conditional-criteria-distribution.svg",
  plot = p,
  width = 10,
  height = 10,
  dpi = 300
)


# How many solutions were found that met the cutoff criteria (per subscale):
count_solutions <- table(data_goodfit$subscale_id)
print(count_solutions)
