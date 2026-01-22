#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#set page(width: 5.75in, height: 5.25in)
#set align(center + horizon)
#set text(font: "TeX Gyre Pagella")


#set align(center)
#let width_latent = 4em
#let height_latent = 3em
#let radius_error = 1.4em
#let spacing = (3.5em, 3.5em)
#let var_bend = 109deg
#let var_loop = 222deg

#diagram(
  node-stroke: .04em,
  node-fill: gradient.radial(silver.lighten(95%), silver, center: (30%, 20%), radius: 80%),
  spacing: spacing,
  let (ISC, CIC, ISP, CIP) = ((-.75, 0), (0, -.75), (0.75, 0), (0, .75)),
  let (x1, x2) = ((-0.25, -1.75), (0.25, -1.75)),
  let (e1, e2) = ((-0.25, -2.5), (0.25, -2.5)),
  // CIC
  node(CIC, [CI-C], shape: fletcher.shapes.ellipse, width: width_latent, height: height_latent),
  node(x1, align(center + horizon)[$X_(111)$], shape: rect),
  node(x2, align(center + horizon)[$X_(211)$], shape: rect),
  edge(CIC, x1, "--|>", label: "1", label-side: center),
  edge(CIC, x2, "-|>"),
  node(e1, [$delta_(111)$], shape: circle, radius: radius_error),
  node(e2, [$delta_(211)$], shape: circle, radius: radius_error),
  edge(e1, x1, "-|>"),
  edge(e2, x2, "-|>"),
  edge(CIC, CIC, "<|-|>", bend: -var_bend, loop-angle: var_loop),

  // ISC
  let (x3, x4) = ((-1.75, 0.25), (-1.75, -0.25)),
  let (e3, e4) = ((-2.5, 0.25), (-2.5, -0.25)),
  node(ISC, "IS-C", shape: fletcher.shapes.ellipse, width: width_latent, height: height_latent),
  node(x3, [$X_(311)$], shape: rect),
  node(x4, [$X_(411)$], shape: rect),
  edge(ISC, x3, "--|>", label: "1", label-side: center),
  edge(ISC, x4, "-|>"),
  node(e3, [$delta_(311)$], shape: circle, radius: radius_error),
  node(e4, [$delta_(411)$], shape: circle, radius: radius_error),
  edge(e3, x3, "-|>"),
  edge(e4, x4, "-|>"),
  edge(ISC, ISC, "<|-|>", bend: -var_bend, loop-angle: var_loop),


  // ISP (right side)
  let (x5, x6) = ((1.75, 0.25), (1.75, -0.25)),
  let (e5, e6) = ((2.5, 0.25), (2.5, -0.25)),
  node(ISP, "IS-P", shape: fletcher.shapes.ellipse, width: width_latent, height: height_latent),
  node(x5, [$X_(512)$], shape: rect),
  node(x6, [$X_(612)$], shape: rect),
  edge(ISP, x5, "--|>", label: "1", label-side: center),
  edge(ISP, x6, "-|>"),
  node(e5, [$delta_(512)$], shape: circle, radius: radius_error),
  node(e6, [$delta_(612)$], shape: circle, radius: radius_error),
  edge(e5, x5, "-|>"),
  edge(e5, e5, "<|-|>", bend: -var_bend, loop-angle: 180deg),
  edge(e6, e6, "<|-|>", bend: -var_bend, loop-angle: 180deg),
  edge(e4, e4, "<|-|>", bend: -var_bend, loop-angle: 0deg),
  edge(e3, e3, "<|-|>", bend: -var_bend, loop-angle: 0deg),
  edge(e2, e2, "<|-|>", bend: -var_bend, loop-angle: 270deg),
  edge(e1, e1, "<|-|>", bend: -var_bend, loop-angle: 270deg),
  edge(e6, x6, "-|>"),
  edge(ISP, ISP, "<|-|>", bend: -var_bend, loop-angle: var_loop),


  // CIP (CIP is directly below CIC)
  let (x7, x8) = ((-0.25, 1.75), (0.25, 1.75)),
  let (e7, e8) = ((-0.25, 2.5), (0.25, 2.5)),
  node(CIP, "CI-P", shape: fletcher.shapes.ellipse, width: width_latent, height: height_latent),
  node(x7, [$X_(112)$], shape: rect),
  node(x8, [$X_(212)$], shape: rect),
  edge(CIP, x7, "--|>", label: "1", label-side: center),
  edge(CIP, x8, "-|>"),
  node(e7, [$delta_(112)$], shape: circle, radius: radius_error),
  node(e8, [$delta_(212)$], shape: circle, radius: radius_error),
  edge(e7, x7, "-|>"),
  edge(e8, x8, "-|>"),
  edge(e7, e7, "<|-|>", bend: -var_bend, loop-angle: 90deg),
  edge(e8, e8, "<|-|>", bend: -var_bend, loop-angle: 90deg),

  let (CIPRES) = (0.75, 0.75),
  node(CIPRES, [$zeta_(script("CI-P"))$], shape: circle),
  edge(CIPRES, CIPRES, "<|-|>", bend: -var_bend, loop-angle: 180deg),
  edge(CIPRES, CIP, "-|>", label-side: center),
  edge(CIPRES, ISP, "<|-|>", bend: -40deg),
  edge(CIPRES, ISC, "<|-|>", bend: -30deg),
  edge(CIPRES, CIC, "<|-|>", bend: 30deg),

  // Covariance
  edge(CIC, CIP, label: text(rgb("#B80043"))[$gamma arrow.t$], label-side: center, marks: "-|>", stroke: rgb("#B80043")),
  edge(
    ISC,
    ISP,
    label: text(rgb("#2B518D"))[$phi arrow.b$],
    label-side: center,
    marks: "<|-|>",
    stroke: rgb("#2B518D"),
    bend: -30deg,
    label-fill: white,
  ),
  edge(ISC, CIC, "<|-|>", bend: 30deg),
  edge(ISP, CIC, "<|-|>", bend: -30deg),
)

