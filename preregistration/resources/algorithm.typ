#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: pill, diamond

#let decision(pos, label, ..args) = node(
  pos, align(center, label), 
  fill:  gradient.radial(silver.lighten(95%), silver.darken(10%), center: (30%, 20%), radius: 80%), 
  shape: diamond,
  width: 4em,
  height: 4em,
  ..args
  )

#let state(pos, label, ..args) = node(
  pos, align(center, label), 
  shape: rect, 
  fill: gradient.radial(navy.lighten(85%), navy.lighten(30%), center: (30%, 20%), radius: 80%),
  width: 7.5em,
  height: 4em,
  ..args
  )

#let stopper(pos, label, ..args) = node(
  pos, align(center, label), 
  shape: pill, 
  fill: gradient.radial(orange.lighten(85%), orange.lighten(10%), center: (30%, 20%), radius: 80%),
  width: 6em,
  height: 4em,
  ..args
  )

#set par(justify: false)

#align(center, [
    #text(size: 9.5pt, [
      #diagram(
      let(srmr_met, rmsea_met, phi_met, gamma_met, omega_met) = ((-2, 0), (-1, 0), (0, 0), (1, 0), (2, 0)),
      let(rmsea_met2, fct_threshold) = ((-2, -1), (2, -1)),
      let(overparam, drop_is, drop_ci) = ((-1, -1), (0, -1), (1, -1)),
      let(drop_compl, refit) = ((-1, -2), (0.5, -2)),
      let(begin, end) = ((-2, 1), (2, 1)),
      decision(srmr_met, [Is SRMR met?]),
      decision(rmsea_met, [Is RMSEA met?]),
      decision(phi_met, [Is $phi$ met?]),
      decision(gamma_met, [Is $gamma$ met?]),
      decision(omega_met, [Is $omega$ met?]),
      decision(rmsea_met2, [Is RMSEA met?]),
      decision(fct_threshold, [Which factor(s) < $omega$?]),
      state(overparam, [Model over- \ parameterized]),
      state(drop_is, [Drop IS component]),
      state(drop_ci, [Drop CI component]),
      state(drop_compl, [Drop subscale]),
      stopper(refit, [Refit model]),
      stopper(begin, [Start]),
      stopper(end, [Criteria met]),
      edge(begin, srmr_met, "-|>"),
      edge(srmr_met, rmsea_met, "-|>", label: "Yes", label-side: center),
      edge(srmr_met, rmsea_met2, "-|>", label: "No", label-pos: 40%),
      edge(rmsea_met2, (-2, -2), drop_compl, "-|>", label: "No", label-pos: 40%, label-side: center),
      edge(rmsea_met, phi_met, "-|>", label: "Yes", label-side: center),
      edge(phi_met, gamma_met, "-|>", label: "Yes", label-side: center),
      edge(gamma_met, omega_met, "-|>", label: "Yes", label-side: center),
      edge(omega_met, end, "-|>", label: "Yes", label-side: center, label-pos: 30%),
      edge(omega_met, fct_threshold, "-|>", label: "No", label-pos: 40%),
      edge(fct_threshold, (2, -3), (-1, -3), drop_compl, "-|>", label: "Both", label-side: center),
      edge(fct_threshold, (2, -2.5), (0, -2.5), drop_is, "-|>", label: [IS\*], label-side: center),
      edge(fct_threshold, drop_ci, "-|>", label: [CI], label-side: center),
      edge(rmsea_met, overparam, "-|>", label: "No", label-side: center, label-pos: 40%),
      edge(phi_met, drop_is, "-|>", label: "No", label-side: center, label-pos: 30%),
      edge(gamma_met, drop_ci, "-|>", label: "No", label-side: center, label-pos: 40%),
      edge(drop_is, refit, "-|>"),
      edge(drop_ci, refit, "-|>"),
    )
  ])
])

#set par(justify: true)