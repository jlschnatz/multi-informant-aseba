// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}

//#assert(sys.version.at(1) >= 11 or sys.version.at(0) > 0, message: "This template requires Typst Version 0.11.0 or higher. The version of Quarto you are using uses Typst version is " + str(sys.version.at(0)) + "." + str(sys.version.at(1)) + "." + str(sys.version.at(2)) + ". You will need to upgrade to Quarto 1.5 or higher to use apaquarto-typst.")

// counts how many appendixes there are
#let appendixcounter = counter("appendix")
// make latex logo
// https://github.com/typst/typst/discussions/1732#discussioncomment-11286036
#let TeX = {
  set text(font: "New Computer Modern")
  let t = "T"
  let e = text(baseline: 0.22em, "E")
  let x = "X"
  box(t + h(-0.14em) + e + h(-0.14em) + x)
}

#let LaTeX = {
  set text(font: "New Computer Modern")
  let l = "L"
  let a = text(baseline: -0.35em, size: 0.66em, "A")
  box(l + h(-0.32em) + a + h(-0.13em) + TeX)
}

#let firstlineindent = 0.5in

// documentmode: man
#let man(
  title: none,
  runninghead: none,
  margin: (x: 1in, y: 1in),
  paper: "us-letter",
  font: ("Times", "Times New Roman"),
  fontsize: 12pt,
  leading: 18pt,
  spacing: 18pt,
  firstlineindent: 0.5in,
  toc: false,
  lang: "en",
  cols: 1,
  numbersections: false,
  numberdepth: 3,
  first-page: 1,
  suppresstitlepage: false,
  doc,
) = {
  if suppresstitlepage { counter(page).update(first-page) }

  set page(
    margin: margin,
    paper: paper,
    header-ascent: 50%,
    numbering: none, // new
    header: grid(
      columns: (9fr, 1fr),
      align(left)[#upper[#runninghead]], align(right)[#context counter(page).display()],
    ),
  )


  set table(
    stroke: (x, y) => (
      top: if y <= 1 { 0.5pt } else { 0pt },
      bottom: .5pt,
    )
  )

  set par(
    justify: false,
    leading: leading,
    first-line-indent: firstlineindent,
  )

  // Also "leading" space between paragraphs
  set block(spacing: spacing, above: spacing, below: spacing)

  set text(
    font: font,
    size: fontsize,
    lang: lang,
  )

  show link: set text(black)
  show "al.'s": "al.\u{2019}s"

  show quote: set pad(x: 0.5in)
  show quote: set par(leading: leading)
  show quote: set block(spacing: spacing, above: spacing, below: spacing)
  // show LaTeX
  show "TeX": TeX
  show "LaTeX": LaTeX

  // format figure captions
  show figure.where(kind: "quarto-float-fig"): it => block(width: 100%, breakable: false)[
    #if int(appendixcounter.display().at(0)) > 0 [
      #heading(level: 2, outlined: false)[#it.supplement #appendixcounter.display("A")#it.counter.display()]
    ] else [
      #heading(level: 2, outlined: false)[#it.supplement #it.counter.display()]
    ]
    #align(left)[#par[#emph[#it.caption.body]]]
    #align(center)[#it.body]
  ]

  // format table captions
  show figure.where(kind: "quarto-float-tbl"): it => block(width: 100%, breakable: false)[#align(left)[

    #if int(appendixcounter.display().at(0)) > 0 [
      #heading(level: 2, outlined: false, numbering: none)[#it.supplement #appendixcounter.display(
          "A",
        )#it.counter.display()]
    ] else [
      #heading(level: 2, outlined: false, numbering: none)[#it.supplement #it.counter.display()]
    ]
    #par[#emph[#it.caption.body]]
    #block[#it.body]
  ]]

  set heading(numbering: "1.1")

  show heading: set text(size: fontsize)


  // Redefine headings up to level 5
  show heading.where(
    level: 1,
  ): it => block(width: 100%, below: leading, above: leading)[
    #set align(center)
    #if (numbersections and it.outlined and numberdepth > 0 and counter(heading).get().at(0) > 0) [#counter(
      heading,
    ).display()] #it.body
  ]

  show heading.where(
    level: 2,
  ): it => block(width: 100%, below: leading, above: leading)[
    #set align(left)
    #if (numbersections and it.outlined and numberdepth > 1 and counter(heading).get().at(0) > 0) [#counter(
      heading,
    ).display()] #it.body
  ]

  show heading.where(
    level: 3,
  ): it => block(width: 100%, below: leading, above: leading)[
    #set align(left)
    #set text(style: "italic")
    #if (numbersections and it.outlined and numberdepth > 2 and counter(heading).get().at(0) > 0) [#counter(
      heading,
    ).display()] #it.body
  ]

  show heading.where(
    level: 4,
  ): it => text(
    weight: "bold",
    it.body,
  )

  show heading.where(
    level: 5,
  ): it => text(
    weight: "bold",
    style: "italic",
    it.body,
  )


  if cols == 1 {
    doc
  } else {
    columns(cols, gutter: 4%, doc)
  }

}


#set page(
  paper: "a4",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)

#show: document => man(
  paper: "a4",
  font: ("TeX Gyre Pagella",),
  fontsize: 11pt,
  lang: "en",
  first-page: 1,
  numberdepth: 3,
  document,
)

\
\
#block[
#heading(
level: 
1
, 
numbering: 
none
, 
outlined: 
false
, 
[
Using Automatic Item Selection in Multi-Informant Assessment of Child Mental Health
]
)
]
#set align(center)
#block[
\
Jan Luca Schnatz

Department of Psychological Methods with Interdisciplinary Focus, Institute of Psychology, Goethe University

]
#set align(left)
#set align(center)
#block[
March 13, 2026

]
#set align(left)
\
\
\
\
\
\
\
\
\
\
#block[
#heading(
level: 
1
, 
numbering: 
none
, 
outlined: 
false
, 
[
Author Note
]
)
]
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Jan Luca Schnatz #box(image("_extensions/apaquarto/ORCID-iD_icon-vector.svg", width: 4.23mm)) #link("https://orcid.org/0009-0004-3079-2317")

This work was preregistered on October 1st, 2025 on OSF (osf.io/hzus8). The codebase for this study is publicly available on GitHub (https:\/\/github.com/jlschnatz/multi-informant-aseba). The authors have no conflicts of interest to disclose.

#pagebreak()

#block[
#heading(
level: 
1
, 
numbering: 
none
, 
outlined: 
false
, 
[
Abstract
]
)
]
#block[
]
#block[
"Comprehensive clinical assessment of mental health in children and adolescents often relies on multiple informants, such as parents, teachers and children themselves. However, discrepancies in reports from different raters are common, leading to challenges in interpreting the results of assessment procedures. These discrepancies may arise because some items capture behaviors that are commonly observed across informants, while others reflect informant-specific perspectives unique to each rater. At the same time, there is a need for economic instruments that reduce burden for respondents and clinicians while maintaining reliability and validity. To address these challenges the present study aims to develop a subtest containing 32 items of the commonly employed multi-informant assessment instrument Achenbach System of Empirically Based Assessment (ASEBA) that balances shared and informant-specific perspectives while retaining a manageable number of items for economic admin- istration in clinical settings. This will be achieved within a structural equation modeling framework leveraging an automatic item selection approach to identify an item set that optimally satisfies a predefined set of construction criteria. The present study will use two waves of data of parent and child ratings on the ASEBA Child Behavior Checklist (CBCL/6-18) and Youth Self Report (YSR/11-18) from the SAFE children study (Tolan et al., 2016), a longitudinal randomized controlled trial with #emph[N] = 424 children and their primary caregivers that participated in a family-centered preventive intervention program"

]
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
#emph[Keywords];: Multi-Informant Assessment, Automatic Item Selection, Scale Construction, Achenbach System of Empirically Based Assessment

#counter(page).update(1 - 1)
 #pagebreak()

#block[
#heading(
level: 
1
, 
numbering: 
none
, 
outlined: 
false
, 
[
Using Automatic Item Selection in Multi-Informant Assessment of Child Mental Health
]
)
]

#set par(justify: true)
#show link: it => text(fill: black)[#it]
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Evidence-based clinical assessment in children and adolescents often relies on multiple informants, such as parents, teachers, and children themselves, to obtain a comprehensive understanding of child's mental health (#link(<ref-hunsley2007>)[Hunsley & Mash, 2007];; #link(<ref-mash2005>)[Mash & Hunsley, 2005];). This typically involves using parallel standardized questionnaires such as the widely used Achenbach System of Empirically Based Assessment (ASEBA) that includes self-report, parent-report, and teacher-report forms (#link(<ref-achenbach2001a>)[T. M. Achenbach & Rescorla, 2001];).

However, extensive meta-analytical empirical evidence has shown that discrepancies in reports from different informants (#emph[informant discrepancies];) are common in these instruments (#link(<ref-achenbach1987>)[T. M. Achenbach et al., 1987];; #link(<ref-delosreyes2015>)[De Los Reyes et al., 2015];; #link(<ref-jungersen2023>)[Jungersen, 2023];), leading to challenges in understanding and interpreting the results of the assessment procedures.

Historically, informant discrepancies have been conceived as measurement error, treating them as interchangeable and informant-specific variance as nuisance (#link(<ref-delosreyes2023a>)[De Los Reyes et al., 2023];). This line of interpretation stems from the seminal work of Campbell and Fiske (#link(<ref-campbell1959a>)[1959];) on multi-trait multi-method analysis, which has shaped both theoretical and empirical efforts to emphasize common variance across informants (#link(<ref-delosreyes2023>)[De Los Reyes & and Epkins, 2023];).

More recent theoretical advances concerning the #emph[Operations Triad Model] (#link(<ref-delosreyes2013>)[De Los Reyes et al., 2013];) have shifted the focus towards a more nuanced understanding of multi-informant assessment. Specifically, #emph[converging operations] in this model refer to measurement conditions in which informants' reports align, leading to similar conclusions. The Operations Triad Model distinguishes among informant discrepancies based on their underlying sources. #emph[Diverging] operations capture instances where informants offer distinct yet domain-relevant perspectives, whereas #emph[compensating] operations reflect discrepancies that stem from measurement-related confounds, such as random error or rater biases (#link(<ref-delosreyes2023>)[De Los Reyes & and Epkins, 2023];). This shift in perspective has led to a growing body of literature that emphasizes the importance of informant-specific perspectives in multi-informant assessment(#link(<ref-delosreyes2011>)[De Los Reyes, 2011];; #link(<ref-delosreyes2023a>)[De Los Reyes et al., 2023];).

This reconceptualization has contributed to a paradigm shift in measurement, highlighting the need to account for both common variance and meaningful informant-specific variance (#link(<ref-delosreyes2023>)[De Los Reyes & and Epkins, 2023];). However, because most existing instruments were developed with an emphasis on common variance, they may lack sensitivity to detect domain-relevant informant discrepancies, highlighting the need to refine current measures or develop new tools that explicitly integrate both shared and informant-specific item content (#link(<ref-delosreyes2023>)[De Los Reyes & and Epkins, 2023];).

In addition to the need for instruments that capture both shared and informant-specific perspectives, there is also a growing demand for shortened tests that are feasible to implement in time-limited clinical settings (#link(<ref-goetz2013>)[Goetz et al., 2013];). For example, within the widely used ASEBA system introduced above, the Brief Problem Monitor (BPM) has been developed as a shortened test for the economical assessment of emotional and behavioral problems (#link(<ref-achenbach2011>)[T. Achenbach et al., 2011];). However, the BPM uses the same items across all informants, which may not be optimal for capturing meaningful informant-specific perspectives. This highlights the need for instruments that can effectively balance shared and informant-specific perspectives while also being economical for use in clinical settings.

== Objectives and Research Questions
<objectives-and-research-questions>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
The primary objective of this study is to develop a multi-informant subtest of the Achenbach System of Empirically Based Assessment (ASEBA) that balances shared and informant-specific perspectives, while also retaining a manageable number of items for economic administration in clinical settings.

Specifically, we aim to identify a combination of items that function invariantly across informants (capturing common variance) and items that exhibit informant-specific functioning (capturing unique variance relevant to each informant). As part of our construction goal, we will attempt to ensure that all ASEBA clinical subscales are reflected in the final item set to additionally support the content validity of the subtest. To achieve this objective, we will leverage the combinatorial nature of item selection (#link(<ref-schultze2017>)[Schultze, 2017];) using an automatic item selection approach to identify item sets that optimally satisfy a predefined set of construction criteria.

== Hypotheses
<hypotheses>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
The following hypotheses will be tested in the current study:

+ $H_1$: The model fit of the developed subtest will meet a predefined set of Minimum Viable Criteria (MVC) (see section \#link()\[Minimum Viable Criteria (MVC)\] for details relating to their definition).

+ $H_2$: The subset of items intended to reflect the shared cross-informant perspective will demonstrate measurement invariance across different informants (child and parent).

+ $H_3$: The subset of items intended to reflect the informant-specific perspectives will demonstrate informant-specific functioning, indicating that these items capture unique variance relevant to each informant's perspective.

#figure([
#show figure: set block(breakable: true)

#block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "0_0": 0, "0_1": 0, "1_1": 0, "2_1": 0, "3_1": 0, "4_1": 0, "5_1": 0, "6_1": 0, "7_1": 0, "8_1": 0, "0_2": 0, "1_2": 0, "2_2": 0, "3_2": 0, "4_2": 0, "5_2": 0, "6_2": 0, "7_2": 0, "8_2": 0, "0_3": 0, "1_3": 0, "2_3": 0, "3_3": 0, "4_3": 0, "5_3": 0, "6_3": 0, "7_3": 0, "8_3": 0, "1_0": 1, "2_0": 1, "3_0": 1, "4_0": 1, "5_0": 1, "6_0": 1, "7_0": 1, "8_0": 1
  )

  #let style-array = ( 
    // tinytable cell style after
    (align: center,),
    (align: left,),
  )

  // Helper function to get cell style
  #let get-style(x, y) = {
    let key = str(y) + "_" + str(x)
    if key in style-dict { style-array.at(style-dict.at(key)) } else { none }
  }

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 { return it }
    
    let style = get-style(it.x, it.y)
    if style == none { return it }
    
    let tmp = it
    if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
    if ("color" in style) { tmp = text(fill: style.color, tmp) }
    if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
    if ("underline" in style) { tmp = underline(tmp) }
    if ("italic" in style) { tmp = emph(tmp) }
    if ("bold" in style) { tmp = strong(tmp) }
    if ("mono" in style) { tmp = math.mono(tmp) }
    if ("strikeout" in style) { tmp = strike(tmp) }
    if ("smallcaps" in style) { tmp = smallcaps(tmp) }
    tmp
  }

  #align(center, [

  #table( // tinytable table start
    columns: (25.00%, 25.00%, 25.00%, 25.00%),
    stroke: none,
    rows: auto,
    align: (x, y) => {
      let style = get-style(x, y)
      if style != none and "align" in style { style.align } else { left }
    },
    fill: (x, y) => {
      let style = get-style(x, y)
      if style != none and "background" in style { style.background }
    },
 table.hline(y: 1, start: 0, end: 4, stroke: 0.05em + black),
 table.hline(y: 9, start: 0, end: 4, stroke: 0.1em + black),
 table.hline(y: 0, start: 0, end: 4, stroke: 0.1em + black),
    // tinytable lines before

    // tinytable header start
    table.header(
      repeat: true,
[Subscale], [$max(phi)$], [Convergence (%)], [$N$],
    ),
    // tinytable header end

    // tinytable cell content after
[AB], [0.85], [8.23], [2829888],
[AD], [0.88], [11.58], [474552],
[AP], [0.83], [6.47], [58320],
[RB], [0.87], [3.20], [1499400],
[SC], [0.89], [5.02], [111375],
[SP], [0.95], [4.60], [166375],
[TP], [0.86], [3.30], [317625],
[WD], [0.82], [3.30], [21952],

    // tinytable footer after

  ) // end table

  ]) // end align

] // end block
], caption: figure.caption(
position: top, 
[
Maximum Pheromone, Convergence and Number of Combinations of the Brute-Force Search
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-test>


#block[
#block[
#emph[Note];. This~is the first paragraph.
]
#block[
This is a second paragraph.
]
]
= Methods
<methods>
#figure([
#show figure: set block(breakable: true)

#block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "0_0": 0, "1_0": 0, "0_1": 0, "1_1": 0, "2_1": 0, "3_1": 0, "4_1": 0, "5_1": 0, "6_1": 0, "7_1": 0, "8_1": 0, "9_1": 0, "0_2": 0, "1_2": 0, "2_2": 0, "3_2": 0, "4_2": 0, "5_2": 0, "6_2": 0, "7_2": 0, "8_2": 0, "9_2": 0, "0_3": 0, "1_3": 0, "2_3": 0, "3_3": 0, "4_3": 0, "5_3": 0, "6_3": 0, "7_3": 0, "8_3": 0, "9_3": 0, "0_4": 0, "1_4": 0, "2_4": 0, "3_4": 0, "4_4": 0, "5_4": 0, "6_4": 0, "7_4": 0, "8_4": 0, "9_4": 0, "0_5": 0, "1_5": 0, "2_5": 0, "3_5": 0, "4_5": 0, "5_5": 0, "6_5": 0, "7_5": 0, "8_5": 0, "9_5": 0, "0_6": 0, "1_6": 0, "2_6": 0, "3_6": 0, "4_6": 0, "5_6": 0, "6_6": 0, "7_6": 0, "8_6": 0, "9_6": 0, "0_7": 0, "1_7": 0, "2_7": 0, "3_7": 0, "4_7": 0, "5_7": 0, "6_7": 0, "7_7": 0, "8_7": 0, "9_7": 0, "2_0": 1, "3_0": 1, "4_0": 1, "5_0": 1, "6_0": 1, "7_0": 1, "8_0": 1, "9_0": 1
  )

  #let style-array = ( 
    // tinytable cell style after
    (align: center,),
    (align: left,),
  )

  // Helper function to get cell style
  #let get-style(x, y) = {
    let key = str(y) + "_" + str(x)
    if key in style-dict { style-array.at(style-dict.at(key)) } else { none }
  }

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, left, left, left, left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 { return it }
    
    let style = get-style(it.x, it.y)
    if style == none { return it }
    
    let tmp = it
    if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
    if ("color" in style) { tmp = text(fill: style.color, tmp) }
    if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
    if ("underline" in style) { tmp = underline(tmp) }
    if ("italic" in style) { tmp = emph(tmp) }
    if ("bold" in style) { tmp = strong(tmp) }
    if ("mono" in style) { tmp = math.mono(tmp) }
    if ("strikeout" in style) { tmp = strike(tmp) }
    if ("smallcaps" in style) { tmp = smallcaps(tmp) }
    tmp
  }

  #align(center, [

  #table( // tinytable table start
    column-gutter: 5pt,
    columns: (11.25%, 11.25%, 11.25%, 11.25%, 11.25%, 11.25%, 11.25%, 11.25%),
    stroke: none,
    rows: auto,
    align: (x, y) => {
      let style = get-style(x, y)
      if style != none and "align" in style { style.align } else { left }
    },
    fill: (x, y) => {
      let style = get-style(x, y)
      if style != none and "background" in style { style.background }
    },
 table.hline(y: 1, start: 2, end: 5, stroke: 0.05em + black), table.hline(y: 1, start: 5, end: 8, stroke: 0.05em + black),
 table.hline(y: 2, start: 0, end: 8, stroke: 0.05em + black),
 table.hline(y: 10, start: 0, end: 8, stroke: 0.1em + black),
 table.hline(y: 0, start: 0, end: 8, stroke: 0.1em + black),
    // tinytable lines before

    // tinytable header start
    table.header(
      repeat: true,
[ ], [ ], table.cell(colspan: 3, align: center)[CBCL], table.cell(colspan: 3, align: center)[YSR],
[Subscale], [Agreement], [$alpha$], [$alpha^*$], [_N_], [$alpha$], [$alpha^*$], [_N_],
    ),
    // tinytable header end

    // tinytable cell content after
[AB], [0.52], [0.94], [0.635], [18], [0.90], [0.514], [17],
[AD], [0.45], [0.84], [0.447], [13], [0.84], [0.447], [13],
[AP], [0.48], [0.86], [0.551], [10], [0.79], [0.455], [9],
[RB], [0.55], [0.85], [0.400], [17], [0.81], [0.362], [15],
[SP], [0.49], [0.82], [0.453], [11], [0.74], [0.341], [11],
[SC], [0.40], [0.78], [0.392], [11], [0.80], [0.444], [10],
[TP], [0.37], [0.78], [0.321], [15], [0.78], [0.371], [12],
[WD], [0.40], [0.80], [0.500], [8], [0.71], [0.380], [8],

    // tinytable footer after

  ) // end table

  ]) // end align

] // end block
], caption: figure.caption(
position: top, 
[
Cross-Informant Agreement and Reliability Estimates for all ASEBA Subscales
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-tab3>


#block[
#block[
#emph[Note];. Test
]
]
== Sample
<sample>
#figure([
#show figure: set block(breakable: true)

#block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "0_0": 0, "1_0": 0, "0_1": 0, "1_1": 0, "3_1": 0, "4_1": 0, "5_1": 0, "6_1": 0, "7_1": 0, "8_1": 0, "9_1": 0, "10_1": 0, "12_1": 0, "13_1": 0, "14_1": 0, "15_1": 0, "16_1": 0, "17_1": 0, "18_1": 0, "19_1": 0, "0_2": 0, "1_2": 0, "3_2": 0, "4_2": 0, "5_2": 0, "6_2": 0, "7_2": 0, "8_2": 0, "9_2": 0, "10_2": 0, "12_2": 0, "13_2": 0, "14_2": 0, "15_2": 0, "16_2": 0, "17_2": 0, "18_2": 0, "19_2": 0, "0_3": 0, "1_3": 0, "3_3": 0, "4_3": 0, "5_3": 0, "6_3": 0, "7_3": 0, "8_3": 0, "9_3": 0, "10_3": 0, "12_3": 0, "13_3": 0, "14_3": 0, "15_3": 0, "16_3": 0, "17_3": 0, "18_3": 0, "19_3": 0, "0_4": 0, "1_4": 0, "3_4": 0, "4_4": 0, "5_4": 0, "6_4": 0, "7_4": 0, "8_4": 0, "9_4": 0, "10_4": 0, "12_4": 0, "13_4": 0, "14_4": 0, "15_4": 0, "16_4": 0, "17_4": 0, "18_4": 0, "19_4": 0, "0_5": 0, "1_5": 0, "3_5": 0, "4_5": 0, "5_5": 0, "6_5": 0, "7_5": 0, "8_5": 0, "9_5": 0, "10_5": 0, "12_5": 0, "13_5": 0, "14_5": 0, "15_5": 0, "16_5": 0, "17_5": 0, "18_5": 0, "19_5": 0, "0_6": 0, "1_6": 0, "3_6": 0, "4_6": 0, "5_6": 0, "6_6": 0, "7_6": 0, "8_6": 0, "9_6": 0, "10_6": 0, "12_6": 0, "13_6": 0, "14_6": 0, "15_6": 0, "16_6": 0, "17_6": 0, "18_6": 0, "19_6": 0, "3_0": 1, "4_0": 1, "5_0": 1, "6_0": 1, "7_0": 1, "8_0": 1, "9_0": 1, "10_0": 1, "12_0": 1, "13_0": 1, "14_0": 1, "15_0": 1, "16_0": 1, "17_0": 1, "18_0": 1, "19_0": 1, "2_0": 2, "11_0": 2, "2_1": 2, "11_1": 2, "2_2": 2, "11_2": 2, "2_3": 2, "11_3": 2, "2_4": 2, "11_4": 2, "2_5": 2, "11_5": 2, "2_6": 2, "11_6": 2
  )

  #let style-array = ( 
    // tinytable cell style after
    (align: center,),
    (align: left,),
    (bold: true, align: center,),
  )

  // Helper function to get cell style
  #let get-style(x, y) = {
    let key = str(y) + "_" + str(x)
    if key in style-dict { style-array.at(style-dict.at(key)) } else { none }
  }

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, left, left, left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 { return it }
    
    let style = get-style(it.x, it.y)
    if style == none { return it }
    
    let tmp = it
    if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
    if ("color" in style) { tmp = text(fill: style.color, tmp) }
    if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
    if ("underline" in style) { tmp = underline(tmp) }
    if ("italic" in style) { tmp = emph(tmp) }
    if ("bold" in style) { tmp = strong(tmp) }
    if ("mono" in style) { tmp = math.mono(tmp) }
    if ("strikeout" in style) { tmp = strike(tmp) }
    if ("smallcaps" in style) { tmp = smallcaps(tmp) }
    tmp
  }

  #align(center, [

  #table( // tinytable table start
    column-gutter: 5pt,
    columns: (auto, auto, auto, auto, auto, auto, auto),
    stroke: none,
    rows: auto,
    align: (x, y) => {
      let style = get-style(x, y)
      if style != none and "align" in style { style.align } else { left }
    },
    fill: (x, y) => {
      let style = get-style(x, y)
      if style != none and "background" in style { style.background }
    },
 table.hline(y: 1, start: 1, end: 4, stroke: 0.05em + black), table.hline(y: 1, start: 4, end: 7, stroke: 0.05em + black),
 table.hline(y: 2, start: 0, end: 7, stroke: 0.05em + black),
 table.hline(y: 20, start: 0, end: 7, stroke: 0.1em + black),
 table.hline(y: 0, start: 0, end: 7, stroke: 0.1em + black),
    // tinytable lines before

    // tinytable header start
    table.header(
      repeat: true,
[ ], table.cell(colspan: 3, align: center)[Training], table.cell(colspan: 3, align: center)[Testing],
[Subscale], [0], [1], [2], [0], [1], [2],
    ),
    // tinytable header end

    // tinytable cell content after
table.cell(colspan: 7)[CBCL],
[AB], [62.9 (10.8)], [13.9 (9)], [2.7 (2.1)], [63.8 (13.4)], [13.8 (8.6)], [2.4 (1.9)],
[AD], [70.2 (12.1)], [9.9 (6.4)], [1.5 (1)], [73.3 (15.5)], [10.2 (6.4)], [1.4 (0.8)],
[AP], [63.6 (14.5)], [16.1 (6.6)], [2.6 (1.7)], [60.9 (8.5)], [15 (7.4)], [2.6 (1.4)],
[RB], [72.1 (15.2)], [8.1 (7.9)], [2.7 (1.8)], [74.1 (18.7)], [8.9 (8.6)], [2.2 (1.3)],
[SC], [72.8 (10.5)], [8.1 (4.5)], [1.1 (0.9)], [71.8 (10.5)], [8 (4)], [1.1 (1)],
[SP], [68.8 (6.9)], [9.2 (5.7)], [1.5 (1.5)], [73.4 (12.8)], [8.8 (5.2)], [1.3 (1.7)],
[TP], [82.1 (25)], [6 (5.6)], [1.2 (1.1)], [79.6 (16)], [5.6 (4.8)], [1.1 (1.3)],
[WD], [60.1 (9.8)], [16.2 (7.9)], [3.2 (2)], [59.2 (10.9)], [16.7 (9.5)], [2.5 (1.6)],
table.cell(colspan: 7)[YSR],
[AB], [57.9 (11.3)], [15.7 (8)], [4.4 (4)], [58.1 (11.1)], [14.8 (7.9)], [3.8 (3.9)],
[AD], [63.4 (11.2)], [11.4 (8.5)], [3.1 (3)], [61.9 (11.9)], [11.7 (9.1)], [3.1 (3.2)],
[AP], [51.5 (9.6)], [21.3 (6.6)], [5.2 (3.4)], [52.4 (10.2)], [19.6 (6.9)], [4.8 (3.4)],
[RB], [60.8 (13.9)], [13.7 (10.9)], [3.5 (3.5)], [58.5 (13.9)], [14 (10.4)], [4.2 (4.1)],
[SC], [62.4 (6.8)], [13.1 (5.6)], [2.5 (1.6)], [60.5 (7.1)], [13.5 (5.6)], [2.8 (1.9)],
[SP], [65 (5.4)], [10.9 (4.8)], [2.1 (0.8)], [64.8 (4.7)], [10.3 (4.1)], [1.6 (0.8)],
[TP], [61 (16.6)], [15.4 (8.6)], [4.3 (2.7)], [60.2 (17.1)], [14.9 (9.2)], [4.4 (2.7)],
[WD], [53.8 (10.5)], [19.5 (7)], [4.6 (4)], [54.2 (10.4)], [17.6 (6.7)], [4.9 (4)],

    // tinytable footer after

  ) // end table

  ]) // end align

] // end block
], caption: figure.caption(
position: top, 
[
Test
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-sample1>


#block[
#block[
#emph[Note];. 0:~Not true, 1: Somwhat or somtimes true, 2: Very true or often true. Values before parentheses indicate the mean proportion across all items belonging to the subscale for each eacher. Values in parentheses indicates the respective standard deviations. WD: Withdrawn/Depressed, TP: Thought Problems, SP: Social Problems, SC: Somatic Complaints, RB: Rule-breaking Beahavior, AP: Attention Problems, AD: Anxious/Depressed, AB: Aggressive Behavior. CBCL: Child Behavior Checklist, YSR: Youth Self Report.
]
]
== Objective Function
<objective-function>
=== Criteria
<criteria>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
To select a set of items that meets the construction goal, an objective function will be defined, consisting of the following criteria:

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Model Fit.
]
)
]
Two model fit indices will be included as criteria for the objective function: The sample-corrected robust Root Mean Square Error of Approximation (#link(<ref-li2006>)[Li & Bentler, 2006];).

$ upright(R M S E A) = sqrt(max {0 \, #h(0em) frac(hat(F)_(upright(M L)), d f) - frac(hat(c), n - 1)}) $

where $hat(c)$ is correction constant, $hat(F)_(upright(M L))$ is the value of the minimized fit function, $d f$ are the degrees of freedom and $n$ is the sample size (#link(<ref-brosseau-liard2012>)[Brosseau-Liard et al., 2012];). This corresponds to the "rmsea.robust" fit measure in the #emph[lavaan] package (#link(<ref-rosseel2012>)[Rosseel, 2012];).

Additionaly, the Standardized Root Mean Square Residual (#link(<ref-bentler1995>)[Bentler, 1995];) will be included as a second model fit criterion

$ upright(S R M R) = sqrt(frac(2, p (p + 1)) sum_(u = 1)^p sum_(v = 1)^p (frac(s_(u v) - hat(sigma)_(u v), s_(u u) thin s_(v v)))^2) $

where $p$ is the number of manifest variables in the model $s_(u v)$ is the sample covariance between manifest variables $u$ and $v$ and $hat(sigma)_(u v)$ is their estimated covariance . This corresponds to the "srmr" criterion in the #emph[lavaan] pacakge (#link(<ref-rosseel2012>)[Rosseel, 2012];).

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Reliability.
]
)
]
We will additionally include a criterion for the average reliability across the four latent factors, given by

$ overline(omega) = 1 / l sum_(j = 1)^l [frac((sum_(i = 1)^p lambda_(i j k l))^2, (sum_(i = 1)^p lambda_(i j k l))^2 + sum_(i = 1)^p theta_(i j k l))] $

where $l$ is the number of latent factors (in this case $l = 4$), $lambda_(i j k l)$ is the factor loading of item $i$ ($i = 1 \, dots.h \, I_j$) within the $j$-th clinical subscale ($j = 1 \, dots.h \, J$) for the $k$-th information ($k in { 1 \, 2 }$) loading on the $l$-th latent factor ($l in { upright(C I - C \, C I - P \, I S - C \, I S - P) }$), and $theta_(i j k l)$ is the corresponding error variance of that item.

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Cross-Informant Regression.
]
)
]
Highlighted in orange in the model in #link(<fig-model>)[Figure~1];, the regression coefficient $gamma$ from the cross-informant parent factor (CI-P) to the cross-informant child factor (CI-C) will be included as a criterion in the objective function. This coefficient reflects the extent item selected for these factors are answered consistently across both informants.

#block[
#heading(
level: 
4
, 
numbering: 
none
, 
[
Informant-Specific Correlation.
]
)
]
Finally, the latent correlation $phi$ highlighted in blue in #link(<fig-model>)[Figure~1] between the informant-specific factors (IS-C and IS-P) will be included as a criterion in the objective function. This correlation reflects the extent to which the items selected for these factors capture informant-specific perspectives by aiming for a low correlation between the two factors.

=== Combintation of the Criteria
<combintation-of-the-criteria>
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
Each criterion will be transformed onto a common scale using the cumulative distribution function of the normal distribution $Phi (x_q ; hat(mu)_(x_q) \, hat(sigma)_(q_w))$, with parameters corresponding to difficulty $hat(mu)_(x_q)$ (point of maximum discrimination) and discrimination $hat(sigma)_(q_w)$ (slope). These parameters will be empirically estimated from $k$ = 5000 random solutions sampled from the search space of all possible item combinations from the model specified in #ref(<fig-model>, supplement: [Figure]). The mean and standard deviation of the top 10% of valid solutions will be used for the transformation.

The combined empirical objective function $f$ is then given by a weighted sum of the set of transformed criteria $cal(X) : { upright(R M S E A) \, upright(S R M R) \, hat(omega) \, phi \, gamma }$:

$ f = sum_(q = 1)^r w_q dot.op Phi (x_q ; hat(mu)_(x_q) \, hat(sigma)_(q_w)) $

with weights $cal(W)$ set as $w_(upright(R M S E A)) = w_(upright(S R M R)) = w_gamma = w_phi = 1 / 6$ and $w_(hat(omega)) = 1 / 3$. This means that objective function balances equally between model fit criteria, criteria relating to the multi-informant quality of the instrument, and reliability.

#figure([
#box(image("../figures/model.svg"))
], caption: figure.caption(
position: top, 
[
Hypothesized CTC(M-1) Strucural Equation Model of a Single Clinical Subscale of ASEBA
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-model>


#block[
#block[
#emph[Note];. Subscripts~$X_(i j k)$ denote the item $i$, clinical subscale $j$ and rater $k$. Double-headed arrows represent covariances, single-headed arrows represent regression. Round $delta$ nodes are error variables of each item. CI-C: Cross-Informant Child factor. CI-P: Cross-Informant Parent factor, IS-C: Informant-Specific Child factor, IS-P: Informant-Specific Parent factor. $phi$: latent correlation between the informant-specific factors. $gamma$: latent regression parameter of the cross-informant factors. Figure generated using the typst package #emph[fletcher] (#link(<ref-wilson2026>)[Wilson, 2026];).
]
]
#par()[#text(size:0.5em)[#h(0.0em)]]
#v(-18pt)
$ rho^(\*) = (r rho) / (1 + (r - 1) rho) $

= Results
<results>
#figure([
#show figure: set block(breakable: true)

#block[ // start block

  #let style-dict = (
    // tinytable style-dict after
    "0_0": 0, "0_1": 0, "1_1": 0, "2_1": 0, "3_1": 0, "4_1": 0, "5_1": 0, "6_1": 0, "7_1": 0, "8_1": 0, "0_2": 0, "1_2": 0, "2_2": 0, "3_2": 0, "4_2": 0, "5_2": 0, "6_2": 0, "7_2": 0, "8_2": 0, "0_3": 0, "1_3": 0, "2_3": 0, "3_3": 0, "4_3": 0, "5_3": 0, "6_3": 0, "7_3": 0, "8_3": 0, "0_4": 0, "1_4": 0, "2_4": 0, "3_4": 0, "4_4": 0, "5_4": 0, "6_4": 0, "7_4": 0, "8_4": 0, "0_5": 0, "1_5": 0, "2_5": 0, "3_5": 0, "4_5": 0, "5_5": 0, "6_5": 0, "7_5": 0, "8_5": 0, "1_0": 1, "2_0": 1, "3_0": 1, "4_0": 1, "5_0": 1, "6_0": 1, "7_0": 1, "8_0": 1
  )

  #let style-array = ( 
    // tinytable cell style after
    (align: center,),
    (align: left,),
  )

  // Helper function to get cell style
  #let get-style(x, y) = {
    let key = str(y) + "_" + str(x)
    if key in style-dict { style-array.at(style-dict.at(key)) } else { none }
  }

  // tinytable align-default-array before
  #let align-default-array = ( left, left, left, left, left, left, ) // tinytable align-default-array here
  #show table.cell: it => {
    if style-array.len() == 0 { return it }
    
    let style = get-style(it.x, it.y)
    if style == none { return it }
    
    let tmp = it
    if ("fontsize" in style) { tmp = text(size: style.fontsize, tmp) }
    if ("color" in style) { tmp = text(fill: style.color, tmp) }
    if ("indent" in style) { tmp = pad(left: style.indent, tmp) }
    if ("underline" in style) { tmp = underline(tmp) }
    if ("italic" in style) { tmp = emph(tmp) }
    if ("bold" in style) { tmp = strong(tmp) }
    if ("mono" in style) { tmp = math.mono(tmp) }
    if ("strikeout" in style) { tmp = strike(tmp) }
    if ("smallcaps" in style) { tmp = smallcaps(tmp) }
    tmp
  }

  #align(center, [

  #table( // tinytable table start
    columns: (16.67%, 16.67%, 16.67%, 16.67%, 16.67%, 16.67%),
    stroke: none,
    rows: auto,
    align: (x, y) => {
      let style = get-style(x, y)
      if style != none and "align" in style { style.align } else { left }
    },
    fill: (x, y) => {
      let style = get-style(x, y)
      if style != none and "background" in style { style.background }
    },
 table.hline(y: 1, start: 0, end: 6, stroke: 0.05em + black),
 table.hline(y: 9, start: 0, end: 6, stroke: 0.1em + black),
 table.hline(y: 0, start: 0, end: 6, stroke: 0.1em + black),
    // tinytable lines before

    // tinytable header start
    table.header(
      repeat: true,
[Subscale], [RMSEA], [SRMR], [$omega$], [$gamma$], [$phi$],
    ),
    // tinytable header end

    // tinytable cell content after
[AB], [0.14 (0.01)], [0.10 (0.01)], [0.61 (0.03)], [4.08 (2.59)], [0.50 (0.05)],
[AD], [0.12 (0.01)], [0.08 (0.01)], [0.55 (0.04)], [1.10 (0.24)], [0.75 (0.08)],
[AP], [0.15 (0.01)], [0.11 (0.01)], [0.58 (0.02)], [2.58 (0.54)], [0.61 (0.08)],
[RB], [0.16 (0.01)], [0.11 (0.00)], [0.59 (0.02)], [3.91 (1.54)], [0.72 (0.12)],
[SC], [0.13 (0.01)], [0.09 (0.01)], [0.57 (0.03)], [0.49 (0.22)], [0.70 (0.10)],
[SP], [0.10 (0.01)], [0.07 (0.01)], [0.49 (0.03)], [1.36 (0.35)], [0.75 (0.07)],
[TP], [0.12 (0.02)], [0.08 (0.01)], [0.55 (0.04)], [3.14 (2.77)], [0.60 (0.10)],
[WD], [0.11 (0.01)], [0.07 (0.00)], [0.51 (0.02)], [2.97 (0.51)], [0.81 (0.08)],

    // tinytable footer after

  ) // end table

  ]) // end align

] // end block
], caption: figure.caption(
position: top, 
[
Estimated Means and Standard Deviations of Random Solutions for Objective Function Parameters
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-m-sd-objective>


#block[
#block[
#emph[Note];. Values~before parentheses indicate mean, values in parentheses standard deviation. WD: Withdrawn/Depressed, TP: Thought Problems, SP: Social Problems, SC: Somatic Complaints, RB: Rule-breaking Beahavior, AP: Attention Problems, AD: Anxious/Depressed, AB: Aggressive Behavior. RMSEA: Root Mean Squared Error of Approximation, SRMR: Standardized Root Mean Residual, $omega$: Reliability, $phi$: latent correlation between the informant-specific factors of the child and parent informants, $gamma$: regression weight of the cross-informant factors between the child and parent informants. These values are determined based on the top 10% of $k$ = 5000 random solution
]
]
#figure([
#box(image("../figures/obj_criteria_dist.svg"))
], caption: figure.caption(
position: top, 
[
Distribution of Empirical Pheromone and Objective Function Criteria Across Clinical Subscales
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-obj-crit>


#block[
#block[
#emph[Note];. WD:~Withdrawn/Depressed, TP: Thought Problems, SP: Social Problems, SC: Somatic Complaints, RB: Rule-breaking Beahavior, AP: Attention Problems, AD: Anxious/Depressed, AB: Aggressive Behavior. RMSEA: Root Mean Squared Error of Approximation, SRMR: Standardized Root Mean Residual, $omega$: Reliability of the latent factors cross-informant and informant specific child and parent factors, $gamma$: Regression weight of the cross-informant factors between the child and parent informants, $phi.alt$: latent correlation between the informant-specific factors of the child and parent informants. Black bar indicates criterion value, where the specific item combination yields the maximum pheromone values.
]
]
#figure([
#box(image("../figures/mvc_combined.svg"))
], caption: figure.caption(
position: top, 
[
Brute-Force Identified Criteria Reject Cutoffs Across Subscales in Training and Testing Samples
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-mvc>


#block[
#block[
#emph[Note];. WD:~Withdrawn/Depressed, TP: Thought Problems, SP: Social Problems, SC: Somatic Complaints, RB: Rule-breaking Beahavior, AP: Attention Problems, AD: Anxious/Depressed, AB: Aggressive Behavior. RMSEA: Root Mean Squared Error of Approximation, SRMR: Standardized Root Mean Residual, $omega$: Reliability of the latent factors cross-informant and informant specific child and parent factors, $gamma$: Regression weight of the cross-informant factors between the child and parent informants, $phi.alt$: latent correlation between the informant-specific factors of the child and parent informants. Black bars represent the predefined cutoff values for each criterion. Blue and orange symbols indicate the decision outcome (accept vs.~reject), with color saturation differentiating the sample type (darker for training, lighter for testing). No testing-sample results are reported for the SC and AP subscales due to model nonconvergence. For the SP subscale, the $beta$ parameter is omitted because of negative estimated latent factor variances.
]
]
= Discussion
<discussion>
#pagebreak()
= References
<references>
#set par(first-line-indent: 0in, hanging-indent: 0.5in)
#block[
#block[
Achenbach, T. M., McConaughy, S. H., & Howell, C. T. (1987). Child/adolescent behavioral and emotional problems: Implications of cross-informant correlations for situational specificity. #emph[Psychological Bulletin];, #emph[101];(2), 213--232. #link("https://doi.org/10.1037/0033-2909.101.2.213")

] <ref-achenbach1987>
#block[
Achenbach, T. M., & Rescorla, L. A. (2001). #emph[Manual for the ASEBA School-age Forms & Profiles: An Integrated System of Multi-informant Assessment];. ASEBA.

] <ref-achenbach2001a>
#block[
Achenbach, T., Mcconaughy, S., Ivanova, M., & Rescorla, L. (2011). Manual for the ASEBA Brief Problem Monitor™(BPM). #emph[Burlington, VT: ASEBA];.

] <ref-achenbach2011>
#block[
Bentler, P. (1995). #emph[EQS : Structural equations program manual];. #link("https://www.semanticscholar.org/paper/EQS-%3A-structural-equations-program-manual-Bentler/3b39d1d27934a461f04e0e076ddb6da5b87193b0")

] <ref-bentler1995>
#block[
Brosseau-Liard, P. E., Savalei, V., & Li, L. (2012). An Investigation of the Sample Performance of Two Nonnormality Corrections for RMSEA. #emph[Multivariate Behavioral Research];, #emph[47];(6), 904--930. #link("https://doi.org/10.1080/00273171.2012.715252")

] <ref-brosseau-liard2012>
#block[
Campbell, D. T., & Fiske, D. W. (1959). Convergent and discriminant validation by the multitrait-multimethod matrix. #emph[Psychological Bulletin];, #emph[56];(2), 81--105. #link("https://doi.org/10.1037/h0046016")

] <ref-campbell1959a>
#block[
De Los Reyes, A. (2011). Introduction to the Special Section: More Than Measurement Error: Discovering Meaning Behind Informant Discrepancies in Clinical Assessments of Children and Adolescents. #emph[Journal of Clinical Child & Adolescent Psychology];, #emph[40];(1), 1--9. #link("https://doi.org/10.1080/15374416.2011.533405")

] <ref-delosreyes2011>
#block[
De Los Reyes, A., & and Epkins, C. C. (2023). Introduction to the Special Issue. A Dozen Years of Demonstrating That Informant Discrepancies are More Than Measurement Error: Toward Guidelines for Integrating Data from Multi-Informant Assessments of Youth Mental Health. #emph[Journal of Clinical Child & Adolescent Psychology];, #emph[52];(1), 1--18. #link("https://doi.org/10.1080/15374416.2022.2158843")

] <ref-delosreyes2023>
#block[
De Los Reyes, A., Augenstein, T., Wang, M., Thomas, S., Drabick, D., Burgers, D., & Rabinowitz, J. (2015). The Validity of the Multi-Informant Approach to Assessing Child and Adolescent Mental Health. #emph[Psychological Bulletin];, #emph[141];, 858--900. #link("https://doi.org/10.1037/a0038498")

] <ref-delosreyes2015>
#block[
De Los Reyes, A., Thomas, S. A., Goodman, K. L., & Kundey, S. M. A. (2013). Principles Underlying the Use of Multiple Informants' Reports. #emph[Annual Review of Clinical Psychology];, #emph[9];, 123--149. #link("https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4103654/")

] <ref-delosreyes2013>
#block[
De Los Reyes, A., Wang, M., Lerner, M. D., Makol, B. A., Fitzpatrick, O. M., & Weisz, J. R. (2023). The Operations Triad Model and Youth Mental Health Assessments: Catalyzing a Paradigm Shift in Measurement Validation. #emph[Journal of Clinical Child & Adolescent Psychology];, #emph[52];(1), 19--54. #link("https://www.tandfonline.com/doi/full/10.1080/15374416.2022.2111684")

] <ref-delosreyes2023a>
#block[
Goetz, C., Coste, J., Lemetayer, F., Rat, A.-C., Montel, S., Recchia, S., Debouverie, M., Pouchot, J., Spitz, E., & Guillemin, F. (2013). Item reduction based on rigorous methodological guidelines is necessary to maintain validity when shortening composite measurement scales. #emph[Journal of Clinical Epidemiology];, #emph[66];(7), 710--718. #link("https://www.sciencedirect.com/science/article/pii/S0895435613000346")

] <ref-goetz2013>
#block[
Hunsley, J., & Mash, E. (2007). Evidence-Based Assessment. #emph[Annual Review of Clinical Psychology];, #emph[3];, 29--51. #link("https://doi.org/10.1146/annurev.clinpsy.3.022806.091419")

] <ref-hunsley2007>
#block[
Jungersen, C. (2023). #emph[Examination of Rating Discrepancies in Multi-Informant Assessments of Childhood Behaviors Across Domains: A Meta-Analytic Study] \[PhD thesis\]. #link("https://www.proquest.com/docview/2868578856/abstract/5312B405C074FC0PQ/1")

] <ref-jungersen2023>
#block[
Li, L., & Bentler, P. (2006). #emph[Robust Statistical Tests for Evaluating the Hypothesis of Close fit of Misspecified Mean and Covariance Structural Models];. #link("https://escholarship.org/uc/item/4t29r830")

] <ref-li2006>
#block[
Mash, E. J., & Hunsley, J. (2005). Evidence-Based Assessment of Child and Adolescent Disorders: Issues and Challenges. #emph[Journal of Clinical Child & Adolescent Psychology];, #emph[34];(3), 362--379. #link("https://doi.org/10.1207/s15374424jccp3403_1")

] <ref-mash2005>
#block[
Rosseel, Y. (2012). Lavaan: An R Package for Structural Equation Modeling. #emph[Journal of Statistical Software];, #emph[48];, 1--36. #link("https://doi.org/10.18637/jss.v048.i02")

] <ref-rosseel2012>
#block[
Schultze, M. (2017). #emph[Constructing Subtests Using Ant Colony Optimization] \[PhD thesis\]. #link("https://refubium.fu-berlin.de/handle/fub188/2951")

] <ref-schultze2017>
#block[
Wilson, J. (2026). #emph[Fletcher: Draw diagrams with nodes and arrows.] #link("https://github.com/Jollywatt/typst-fletcher")

] <ref-wilson2026>
] <refs>
#set par(first-line-indent: 0.5in, hanging-indent: 0in)


 
  
#set bibliography(style: "apa.csl") 


