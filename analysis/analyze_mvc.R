pacman::p_load(targets, dplyr, ggplot2, systemfonts, ggtext, patchwork, ungeviz)
tar_load(starts_with("mvc_training"))
tar_load(starts_with("mvc_testing"))
subscale_ids <- c("AB", "AD", "AP", "RB", "SC", "SP", "TP", "WD")

mvc_training <- do.call(
  rbind,
  mapply(
    FUN = function(x, y) {
      criterion_table <- x$criterion_table
      criterion_table$subscale_id <- y
      criterion_table[, c(
        "subscale_id",
        "criterion",
        "direction",
        "actual",
        "cutoff",
        "meets"
      )]
    },
    x = mget(ls(pattern = "mvc_training_..")),
    y = subscale_ids,
    SIMPLIFY = FALSE
  )
)


mvc_testing <- do.call(
  rbind,
  mapply(
    FUN = function(x, y) {
      if (is.null(x)) {
        return(NULL)
      }
      criterion_table <- x$criterion_table
      criterion_table$subscale_id <- y
      criterion_table[, c(
        "subscale_id",
        "criterion",
        "direction",
        "actual",
        "cutoff",
        "meets"
      )]
    },
    x = mget(ls(pattern = "mvc_testing_..")),
    y = subscale_ids,
    SIMPLIFY = FALSE
  )
)

plot_mvc <- function(x) {
  x |>
    dplyr::mutate(subscale_id = factor(subscale_id, levels = subscale_ids)) |>
    dplyr::mutate(
      meets = factor(
        ifelse(meets, "yes", "no"),
        levels = c("yes", "no", "test")
      )
    ) |>
    dplyr::mutate(
      criterion = factor(
        dplyr::case_match(
          criterion,
          "gamma" ~ "&beta;",
          "phi" ~ "&phi;",
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
    dplyr::filter(!is.na(meets)) |>
    ggplot2::ggplot(ggplot2::aes(x = criterion)) +
    ggplot2::geom_point(
      ggplot2::aes(y = actual, color = meets),
      show.legend = TRUE,
      size = 2
    ) +
    ggplot2::geom_segment(
      ggplot2::aes(y = actual, yend = cutoff, color = meets),
      show.legend = FALSE
    ) +
    ungeviz::geom_hpline(ggplot2::aes(y = cutoff), width = 0.5, size = 0.5) +
    ggplot2::facet_wrap(~subscale_id, drop = FALSE, scales = "free_x") +
    ggplot2::scale_y_continuous(
      limits = c(0, 1),
      breaks = seq(0, 1, 0.2),
      expand = ggplot2::expansion()
    ) +
    ggplot2::scale_color_manual(
      name = "Status",
      values = c("no" = "darkorange", "yes" = "dodgerblue3", "test" = "black"),
      labels = c("no" = "Rejected", "yes" = "Accepted", "test" = "Cutoff"),
      drop = FALSE
    ) +
    ggplot2::labs(x = "Criterion", y = "Value") +
    ggplot2::guides(
      color = ggplot2::guide_legend(
        override.aes = list(size = c(2, 2, 4), shape = c(16, 16, 124))
      )
    ) +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal(base_family = "Libertinus Sans", base_size = 12) +
    ggplot2::theme(
      axis.text.y.left = ggtext::element_markdown(),
      legend.position = c(0.825, 0.125),
      panel.grid.major.y = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(color = "grey"),
      strip.text = ggplot2::element_text(face = "bold", size = 11),
      panel.spacing = ggplot2::unit(0.5, "cm"),
      plot.margin = ggplot2::margin(r = 0.3, b = 0.3, l = 0.3, unit = "cm"),
      axis.title.y.left = ggplot2::element_text(
        margin = ggplot2::margin(l = 0, r = 5)
      ),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 10))
    )
}

p1 <- plot_mvc(mvc_testing)
p2 <- plot_mvc(mvc_training)

ggplot2::ggsave(
  "figures/mvc_testing.svg",
  plot = p1,
  dpi = 300,
  width = 9,
  height = 6
)
ggplot2::ggsave(
  "figures/mvc_training.svg",
  plot = p2,
  dpi = 300,
  width = 9,
  height = 6
)

pcomb <- (p2 | p1) +
  patchwork::plot_layout(nrow = 2) +
  patchwork::plot_annotation(tag_levels = "A") &
  ggplot2::theme(plot.tag = element_text(face = "bold"))

ggplot2::ggsave(
  "figures/mvc_combined.svg",
  plot = pcomb,
  dpi = 300,
  width = 9,
  height = 12
)
