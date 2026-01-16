pacman::p_load(dplyr, tidyr, ggplot2, ggdist, ggh4x, systemfonts, ggtext)
comb_best <- readRDS("data/processed/objective_criteria_best.rds")
comb_log <- readRDS("data/processed/objective_criteria_log.rds")

comb_best_pdata <- comb_best |>
  tidyr::pivot_longer(
    -c(subscale_id, run, pheromone),
    names_to = "criterion",
    values_to = "best_value"
  ) |>
  dplyr::mutate(
    criterion = factor(
      dplyr::case_match(
        criterion,
        "beta" ~ "&beta;",
        "lvcor" ~ "&phi;",
        "omega_cic" ~ "&omega;<sub>CIC<sub>",
        "omega_cip" ~ "&omega;<sub>CIP<sub>",
        "omega_isc" ~ "&omega;<sub>ISC<sub>",
        "omega_isp" ~ "&omega;<sub>ISP<sub>",
        "rmsea.robust" ~ "RMSEA",
        "srmr" ~ "SRMR"
      ),
      levels = c(
        "RMSEA",
        "SRMR",
        "&beta;",
        "&phi;",
        "&omega;<sub>CIC<sub>",
        "&omega;<sub>CIP<sub>",
        "&omega;<sub>ISC<sub>",
        "&omega;<sub>ISP<sub>"
      )
    )
  ) |>
  dplyr::select(subscale_id, criterion, best_value)


comb_log |>
  tidyr::pivot_longer(
    -c(subscale_id, run, pheromone),
    names_to = "criterion",
    values_to = "value"
  ) |>
  dplyr::mutate(
    criterion = factor(
      dplyr::case_match(
        criterion,
        "beta" ~ "&beta;",
        "lvcor" ~ "&phi;",
        "omega_cic" ~ "&omega;<sub>CIC<sub>",
        "omega_cip" ~ "&omega;<sub>CIP<sub>",
        "omega_isc" ~ "&omega;<sub>ISC<sub>",
        "omega_isp" ~ "&omega;<sub>ISP<sub>",
        "rmsea.robust" ~ "RMSEA",
        "srmr" ~ "SRMR"
      ),
      levels = c(
        "RMSEA",
        "SRMR",
        "&beta;",
        "&phi;",
        "&omega;<sub>CIC<sub>",
        "&omega;<sub>CIP<sub>",
        "&omega;<sub>ISC<sub>",
        "&omega;<sub>ISP<sub>"
      )
    )
  ) |>
  dplyr::mutate(
    q01 = quantile(value, 0.01),
    q99 = quantile(value, 0.99),
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
      criterion == "&beta;" ~ ggplot2::scale_x_continuous(
        limits = c(0, 5),
        expand = ggplot2::expansion(),
        breaks = seq(0, 5)
      ),
      criterion == "&omega;<sub>CIC<sub>" ~ ggplot2::scale_x_continuous(
        limits = c(0, 1),
        expand = ggplot2::expansion(),
        breaks = seq(0, 1, 0.2)
      ),
      criterion == "&omega;<sub>CIP<sub>" ~ ggplot2::scale_x_continuous(
        limits = c(0, 1),
        expand = ggplot2::expansion(),
        breaks = seq(0, 1, 0.2)
      ),
      criterion == "&omega;<sub>ISC<sub>" ~ ggplot2::scale_x_continuous(
        limits = c(0, 1),
        expand = ggplot2::expansion(),
        breaks = seq(0, 1, 0.2)
      ),
      criterion == "&omega;<sub>ISP<sub>" ~ ggplot2::scale_x_continuous(
        limits = c(0, 1),
        expand = ggplot2::expansion(),
        breaks = seq(0, 1, 0.2)
      ),
      criterion == "&phi;" ~ ggplot2::scale_x_continuous(
        limits = c(-.6, 1),
        expand = ggplot2::expansion(),
        breaks = seq(-0.6, 1, 0.4),
        labels = scales::label_number()
      ),
      criterion == "RMSEA" ~ ggplot2::scale_x_continuous(
        limits = c(0, 0.2),
        expand = expansion(),
        breaks = seq(0, 0.2, 0.05)
      ),
      criterion == "SRMR" ~ ggplot2::scale_x_continuous(
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
