pacman::p_load(dplyr, tidyr, ggplot2, ggdist, ggh4x, systemfonts, ggtext)
comb_best <- readRDS("data/processed/objective_criteria_best.rds")
comb_log <- readRDS("data/processed/objective_criteria_log.rds")


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

comb_best_pdata <- comb_best |>
  tidyr::pivot_longer(
    -c(subscale_id, run),
    names_to = "criterion",
    values_to = "best_value"
  ) |>
  dplyr::mutate(
    criterion = factor(
      dplyr::case_match(
        criterion,
        "beta" ~ "&gamma; \U2192",
        "lvcor" ~ "\U2192 &phi; \U2190",
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
  ) |>
  dplyr::select(subscale_id, criterion, best_value)


comb_log |>
  tidyr::pivot_longer(
    -c(subscale_id, run),
    names_to = "criterion",
    values_to = "value"
  ) |>
  dplyr::mutate(
    criterion = factor(
      dplyr::case_match(
        criterion,
        "beta" ~ "&gamma; \U2192",
        "lvcor" ~ "\U2192 &phi; \U2190",
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
  ) |>
  dplyr::mutate(
    q01 = quantile(value, 0.005),
    q99 = quantile(value, 0.995),
    .by = c(criterion, subscale_id)
  ) |>
  dplyr::filter(dplyr::between(value, q01, q99)) |>
  dplyr::left_join(
    comb_best_pdata,
    by = dplyr::join_by(subscale_id, criterion)
  ) |>
  ggplot2::ggplot(ggplot2::aes(x = value, y = subscale_id)) +
  ggplot2::facet_wrap(~criterion, scales = "free_x") +
  ggdist::stat_slab(
    normalize = "groups",
    density = ggdist::density_unbounded(bandwidth = "nrd"),
    fill = "grey80"
  ) +
  ggdist::stat_spike(
    aes(x = best_value),
    normalize = "groups",
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
        breaks = seq(-1, 1, .5),
        labels = scales::label_number()
      ),
      criterion == "\U2190 RMSEA" ~ ggplot2::scale_x_continuous(
        limits = c(0, 0.2),
        expand = expansion(),
        breaks = seq(0, 0.2, 0.05)
      ),
      criterion == "\U2190 SRMR" ~ ggplot2::scale_x_continuous(
        limits = c(0, 0.2),
        expand = ggplot2::expansion(),
        breaks = seq(0, 0.2, 0.05)
      )
    )
  ) +
  ggplot2::ylab("Clinical Subscale") +
  ggplot2::xlab("Criterion Value") +
  ggplot2::theme_minimal(base_family = "Libertinus Sans", base_size = 12) +
  ggplot2::theme(
    strip.text = ggtext::element_markdown(size = 13),
    panel.spacing.x = ggplot2::unit(0.75, "cm"),
    panel.border = ggplot2::element_rect(color = "grey"),
    plot.margin = ggplot2::margin(10, 10, 10, 10),
    axis.text.y.left = ggplot2::element_text(size = 12),
    axis.text.x.bottom = ggplot2::element_text(size = 12),
    axis.title.x.bottom = ggplot2::element_text(
      size = 14,
      margin = ggplot2::margin(t = 10)
    ),
    axis.title.y.left = ggplot2::element_text(
      size = 14,
      margin = ggplot2::margin(r = 10)
    ),
    panel.grid.major.y = ggplot2::element_blank()
  ) -> p


ggplot2::ggsave(
  "figures/obj_criteria_dist.svg",
  plot = p,
  dpi = 300,
  width = 10,
  height = 10
)
