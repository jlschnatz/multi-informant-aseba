//* Imports
#import "@preview/pinit:0.2.2": *
#import "@preview/cheq:0.2.2": checklist
#import "@preview/pubmatter:0.2.1"
#import "@preview/gantty:0.3.0": gantt

//* Format checklist items
#show: checklist
#show: checklist.with(fill: luma(95%), stroke: navy, radius: .3em)

//* Heading formatting
#show heading: set text(size: 11pt)
#show heading: it => emph(strong[#it.body.])
#show heading.where(level: 1): it => align(center, strong(it.body))
#show heading.where(level: 2): it => par(first-line-indent: 0in, strong(it.body))

#show heading.where(level: 3): it => par(first-line-indent: 0in, emph(strong(it.body)))

#show heading.where(level: 4): it => strong[#it.body.]
#show heading.where(level: 5): it => emph(strong[#it.body.])

//* Page formatting */
#set page(
  columns: 1,
  paper: "a4",
  margin: 1in
)

#set par(
  justify: true, 
  spacing: 1em,   
  )

#show heading: set block(above: 1em, below: 1em)
#set text(size: 11pt)

//* Numbering equations and cross-reference
#set math.equation(
  numbering: "(1)",
  supplement: none,
)

#show ref: it => {
  // provide custom reference for equations
  if it.element != none and it.element.func() == math.equation {
    // optional: wrap inside link, so whole label is linked
    link(it.target)[eq.~(#it)]
  } else {
    it
  }
}

//* Define citation display */
#show cite.where(form: "prose"): it => {
  show "&": "and"
  it
}

//* Define keywords display 
#let show-keywords(fm, size) = {
  let keywords
  if (type(fm) == dictionary and "keywords" in fm) {
    keywords = fm.keywords
  } else {
    return
  }
  if (keywords.len() > 0) {
    pubmatter.with-theme((theme) => {
      text(size: size, font: theme.font, {
        text(fill: theme.color, weight: "semibold", "Keywords:")
        h(8pt)
        keywords.join(", ")
      })
    })
  }
}

//* Define callout box
#let callout(type, body) = {
  box(
    stroke: 1pt + navy,
    width: 100%,
    radius: 4pt,
    fill: navy.lighten(95%),
    inset: (x: 8pt, y: 8pt),
    [ *#type* \
      #body
    ]
  )
}

//* Table formatting
#show table.cell.where(y: 0): set text(style: "normal", weight: "bold")
#set table(stroke: none)
#let toprule = table.hline(stroke: 0.08em)
#let bottomrule = toprule
#let midrule = table.hline(stroke: 0.05em)

//* Figure caption formatting 
#show figure: set align(start)
#set figure.caption(position: top)
#show figure.caption: set par(first-line-indent: 0em)

#set figure.caption(separator: [ \ ])
#show figure.caption: it => {
  [
  #strong[#it.supplement #context it.counter.display(it.numbering)]
  #it.separator 
  #emph[#it.body]
  ]
}

#show link: it => {
  set text(navy)
  underline(it)
}

// *Define Publication Metadata
#let theme = (
  color: navy.darken(20%), 
  font: "Libertinus Serif", size: 18pt
  )
#state("THEME").update(theme)

#let keywords = (
  "Multi-Informant Assessment", 
  //"Ant Colony Optimization", 
  "Automatic Item Selection", 
  "Scale Construction", 
  "Achenbach System of Empirically Based Assessment"
  )

#let fm = pubmatter.load((
  author: (
    (
      name: "J. Luca Schnatz",
      email: "schnatz@psych.uni-frankfurt.de",
      orcid: "0000-0002-1234-5678",
      affiliations: "Goethe University Frankfurt, Institute of Psychology, Department of Psychological Methods with Interdisciplinary Focus",
      github: "jlschnatz"
    ),
    (
      name: "Martin Schultze",
      email: "schultze@psych.uni-frankfurt.de",
      orcid: "0000-0003-1925-2403",
      affiliations: "Goethe University Frankfurt, Institute of Psychology, Department of Psychological Methods with Interdisciplinary Focus",
      github: "martscht"
    )
  ),
  keywords: keywords,
  date: datetime.today(),
  title: "Preregistration",
  subtitle: "Using Automatic Item Selection in Multi-Informant Assessment of Child Mental Health",
 abstracts: (
   title:  [#text(11pt)[Abstract]], 
   content:  [#text(11pt)[
    Comprehensive clinical assessment of mental health in children and adolescents often relies on multiple informants, such as parents, teachers and children themselves. However, discrepancies in reports from different raters are common, leading to challenges in interpreting the results of assessment procedures. These discrepancies may arise because some items capture behaviors that are commonly observed across informants, while others reflect informant-specific perspectives unique to each rater. At the same time, there is a need for economic instruments that reduce burden for respondents and clinicians while maintaining reliability and validity. To address these challenges the present study aims to develop a subtest containing 32 items of the commonly employed multi-informant assessment instrument Achenbach System of Empirically Based Assessment (ASEBA) that balances shared and informant-specific perspectives while retaining a manageable number of items for economic administration in clinical settings. This will be achieved within a structural equation modeling framework leveraging an automatic item selection approach to identify an item set that optimally satisfies a predefined set of construction criteria. The present study will use two waves of data of parent and child ratings on the ASEBA Child Behavior Checklist (CBCL/6-18) and Youth Self Report (YSR/11-18) from the SAFE children study #cite(<tolan2016>), a longitudinal randomized controlled trial with $N = 424$ children and their primary caregivers that participated in a family-centered preventive intervention program.     
   ]]
   )
))

#set page(header: pubmatter.show-page-header(fm), footer: pubmatter.show-page-footer(fm))

#set highlight(
  fill: rgb("#f9311f97"),
  extent: 0.2em,
  radius: 0.4em
)

// Outline formatting
#show outline.entry.where(level: 1): it => {
  set text(weight: "bold")
  it
}

#show outline.entry: set outline.entry(fill: [])
#set text(font: "TeX Gyre Pagella")
#show math.equation: set text(font: "TeX Gyre Pagella Math")

//* —————————————————————————————————————————————————
//* Main document content
//* —————————————————————————————————————————————————

//* Title page
#pubmatter.show-title(fm)
#pubmatter.show-authors(
  fm, 
  size: 11pt, 
  show-github: true, 
  weight: "semibold"
)
#pubmatter.show-affiliations(fm, size: 10pt)
#pubmatter.show-abstracts(fm)
#line()
#show-keywords(fm, 11pt)
#align(bottom)[
#callout([Note], [
  This preregistration is based on the preregistration template for secondary data analysis @vandenakker2021 and the PRP-Quant template version 3 @bosnjak2022 and has been adapted to fit the current study design.
])
]

//* Table of contents */
#pagebreak()
#outline(depth: 
2, title: "Structure")
#pagebreak()

//* Main content

= Project documentation

== Timepoint of Registration


- [ ] Registration prior to  creation of data
- [ ] Registration prior to  any human observation of the  data
- [ ] Registration prior to  accessing the data
- [x] Registration prior to  analysis of the data
- [ ] Other 

To clarify the study design, particularly regarding the assessment waves in which the full item set of the Child Behavior Checklist and Youth Self Report @achenbach2001a were administered, the study manuals and data were accessed prior to preregistration without analyzing the data.

== Author contributions

#let chr = [ ] // invisible character for checkbox

#figure(
  [
  #image("resources/contribution.svg")
  #text(size: 11pt)[
    #par(first-line-indent: 0em, [
    #align(left)[_Note:_ CRediT see https://credit.niso.org/.; figure generated using the _R_ package #link("https://www.jvcasillas.com/contributoR/")[_contributoR_].]
  ])]
  ],
  caption: [CRediT Taxonomy for Planned Author Contributions]
)

#v(1em)

== Estimated Duration Of Project

The project is expected to take approximately 6 months, starting from the date of preregistration. 

== IRB Status

This study is a secondary analysis of existing publicly available data from the SAFE children study (ICPSR 34368). The original study received ethical approval from the University of Illinois at Chicago's Institutional Review Board (IRB) and followed the 1964 Helsinki Declaration and its later amendments. Informed consent was obtained from all caregivers and from participating children at the time of original data collection.

== Conflict of Interest Statement

All authors declare that they have no conflicts of interest in the conduct of this study.

== Software

#v(0.5em)

- Data analysis: _R_ programming language, version 4.5.1 _Great Square Root_ @rcoreteam2025
- Version control: _git_ 
- Scientific writing: _Quarto_ #cite(<allaire2025>, supplement: "version 1.7.32") and _Typst_ #cite(<madje2025>, supplement: "Version 0.13.1")
- Containerization: _Docker_, version 24.0.6 @merkel2014a

== Standardized Lab Practices

We do not intend to use standardized lab practices for this project.

== Sharing Level of Materials

#let t_align = (left, center, center, center, center, center, center, center)
#let t_align = t_align.map(it => it + horizon)

The secondary data and materials used in this study must not be redistributed or shared according to the terms of use of the Inter-University Consortium for Political and Social Research (ICPSR). However, the data and materials can be obtained for public use after registration to the ICPSR website.  The data can be downloaded in various formats (SAS, SPSS, Stata, R, ASCII, Delimited) via this link https://doi.org/10.3886/ICPSR34368.v1. We will provide detailed information how to download the data and set up the environment to ensure the analytic reproducibility. 

#figure(
  [
    #text(size: 9pt)[
      #table(
        columns: 8,
        toprule,
        align: t_align,
        [*Type*], [*Public \ Use*], [*Scientific \ Use*], [*On case \ basis*], [*Via Secure \ Data Center*], [*Per Email \ Request*], [*None*], [*Not applicable*],
        midrule,
        [Analysis code], [- [x] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr],
        [Experimental code], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [x] #chr],
        [Raw data], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [x] #chr], [- [ ] #chr],
        [Processed data], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [ ] #chr], [- [x] #chr], [- [ ] #chr],
        bottomrule
      )
    ]
  ],
  caption: [Availability of Data and Materials]
)

== Planned Repositories

Repositories where project materials will be shared:

#v(0.5em)

- Open Science Framework: https://osf.io/hzus8/
- GitHub: https://github.com/jlschnatz/multi-informant-aseba

#v(0.5em)

= Introduction

== Theoretical background

Evidence-based clinical assessment in children and adolescents often relies on multiple informants, such as parents, teachers, and children themselves, to obtain a comprehensive understanding of child’s mental health @hunsley2007 @mash2005. This typically involves using parallel standardized questionnaires such as the widely used Achenbach System of Empirically Based Assessment (ASEBA) that includes self-report, parent-report, and teacher-report forms @achenbach2001a.

However, extensive meta-analytical empirical evidence has shown that discrepancies in reports from different informants (_informant discrepancies_) are common in these instruments @delosreyes2015 @achenbach1987 @jungersen2023, leading to challenges in understanding and interpreting the results of the assessment procedures. 

Historically, informant discrepancies have been conceived as measurement error, treating them as interchangeable and informant-specific variance as nuisance @delosreyes2023a. This line of interpretation stems from the seminal work of #cite(<campbell1959a>, form: "prose") on multi-trait multi-method analysis, which has shaped both theoretical and empirical efforts to emphasize common variance across informants @delosreyes2023. 

More recent theoretical advances concerning the _Operations Triad Model_ @delosreyes2013 have shifted the focus towards a more nuanced understanding of multi-informant assessment. Specifically, _converging operations_ in this model refer to measurement conditions in which informants' reports align, leading to similar conclusions. The Operations Triad Model distinguishes among informant discrepancies based on their underlying sources. _Diverging_ operations capture instances where informants offer distinct yet domain-relevant perspectives, whereas _compensating_ operations reflect discrepancies that stem from measurement-related confounds, such as random error or rater biases @delosreyes2023. This shift in perspective has led to a growing body of literature that emphasizes the importance of informant-specific perspectives in multi-informant assessment @delosreyes2011 @delosreyes2023a. 

This reconceptualization has contributed to a paradigm shift in measurement, highlighting the need to account for both common variance and meaningful informant-specific variance @delosreyes2023. However, because most existing instruments were developed with an emphasis on common variance, they may lack sensitivity to detect domain-relevant informant discrepancies, highlighting the need to refine current measures or develop new tools that explicitly integrate both shared and informant-specific item content @delosreyes2023.

In addition to the need for instruments that capture both shared and informant-specific perspectives, there is also a growing demand for shortened tests that are feasible to implement in time-limited clinical settings @goetz2013. For example, within the widely used ASEBA system introduced above, the Brief Problem Monitor (BPM) has been developed as a shortened test for the economical assessment of emotional and behavioral problems @achenbach2011. However, the BPM uses the same items across all informants, which may not be optimal for capturing meaningful informant-specific perspectives. This highlights the need for instruments that can effectively balance shared and informant-specific perspectives while also being economical for use in clinical settings.

== Objectives and Research Questions

The primary objective of this study is to develop a multi-informant subtest of the Achenbach System of Empirically Based Assessment (ASEBA) that balances shared and informant-specific perspectives, while also retaining a manageable number of items for economic administration in clinical settings. 

Specifically, we aim to identify a combination of items that function invariantly across informants (capturing common variance) and items that exhibit informant-specific functioning (capturing unique variance relevant to each informant). As part of our construction goal, we will attempt to ensure that all ASEBA clinical subscales are reflected in the final item set to additionally support the content validity of the subtest. To achieve this objective, we will leverage the combinatorial nature of item selection @schultze2017 using an automatic item selection approach to identify item sets that optimally satisfy a predefined set of construction criteria.

== Hypotheses

The following hypotheses will be tested in the current study:

1. $H_1$: The model fit of the developed subtest will meet a predefined set of Minimum Viable Criteria (MVC) (see section #link(<mvc>)[Minimum Viable Criteria (MVC)] for details relating to their definition).

2. $H_2$: The subset of items intended to reflect the shared cross-informant perspective will demonstrate measurement invariance across different informants (child and parent).

3. $H_3$: The subset of items intended to reflect the informant-specific perspectives will demonstrate informant-specific functioning, indicating that these items capture unique variance relevant to each informant's perspective.

== Exploratory Research Questions

To explore the discriminant validity of the four factors (cross-informant and informant-specific perspectives) between different clinical subscales of the ASEBA, we will examine pairwise correlations between the factor scores of different clinical subscales.

= Methods

== Use of Pre-Existing Data

=== Dataset Description

The dataset used for this study is sourced from the SAFE children study (ICPSR 34368), see also #cite(<tolan2016>, form: "prose"). The primary study was a longitudinal randomized controlled trial with a total of 11 waves of data collection from 1997 to 2008. The study aimed to test the efficacy of a multicomponent family-centered preventive intervention for children entering 1st grade in inner-city Chicago schools. The intervention targeted key early risk factors for later substance use and adjustment problems. Data were collected from children, their primary caregivers, and teachers across three phases of the study (initial intervention, booster, and long-term follow-up).

=== Public Availability 

The dataset is publicly available and can be accessed via the Inter-University Consortium for Political and Social Research (ICPSR).

=== Data Access

The dataset can be accessed after registration at the ICPSR website using an academic email address. The data is available for scientific usage only and can be downloaded in various formats (SAS, SPSS, Stata, R, ASCII, Delimited) via this link https://doi.org/10.3886/ICPSR34368.v1. 


=== Access Date

#let access_date = datetime(
  year: 2025,
  month: 6,
  day: 14,
)

The dataset was downloaded and first accessed on #access_date.display("[month repr:long] [day], [year]").

=== Data Collection Method

=== Data Codebook

The data is accompanied by extensive documentation, including codebooks, original questionnaires and user guides for each subcomponent of the study. They can be accessed using the same link as above. (https://doi.org/10.3886/ICPSR34368.v1). 

=== Knowledge of Data

==== Previous Work with Dataset

The data was not used in any previous work by the authors.

==== Previous Knowledge

The structure and contents (i.e., variables) of the dataset are known from the accompanying documentation, including variable lists, codebooks and study descriptions provided by the ICPSR. Relevant metadata on sampling, measurement time points, and instruments used are accessible, and the available variables have been reviewed in preparation for the planned analyses. We do not have prior knowledge of statistical results related to the current hypotheses.

== Piloting

No piloting was conducted for this study. 

== Sample size justification

The sample size of this study is predetermined by the original study design of the SAFE children study. The original study included a total of $N = 424$ children in the first wave. A complete assessment of the Youth Self Report (YSR) and Child Behavior Checklist (CBCL) was carried out only in the 10th and 11th wave. Other waves included only partial assessments of the instruments. Because of this, we only use the data of the 10th and 11th wave for the current study. 

== Participant recruitment, selection, and compensation

The prevention program of the SAFE children study targeted families based on their residence in high-risk neighborhoods in Chicago, rather than on individual characteristics. These neighborhoods were characterized by high rates of poverty, crime and resource deprivation @tolan2004. The study aimed to recruit families with children in the transition from kindergarten to first grade. A total of seven elementary schools were selected to participate based on these criteria. All parents of those identified schools were contacted and invited to participate in the study. A total of 507 families were deemed eligible based of their residence within the designated neighborhood boundaries of the children's schools. Of these, 424 families (84%) agreed to participate in the study and completed baseline assessment @tolan2016. No weighting or stratification was applied to the sample.

== Handling of participant drop-out

To our knowledge, the primary investigators did not implement any specific procedure to handle participant drop-out during the course of the longitudinal study. However, they reported no significant differences in demographic characteristics in the attrition rates for the first five waves for both intervention and control group @tolan2004. According to the metadata provided on ICPSR, the response rates for parents and children in the 10th wave were $72.%$ and $75.0%$, respectively. For the 11th wave, the response rates were $73.6%$ for the parents and $74.1%$ for the children.

== Masking of participants and researchers

No masking of participants or researchers was implemented in the original study design.

== Type of study and study design

The study design was a randomized controlled trial (RCT) with 11 waves of data collection spanning 13 years. The study consisted of three phases: Phase 1 (1st-5th wave) was included carrying out the preventive intervention or control condition. Phase 2 (6th-9th wave) was aimed at differentiating the effect of a second "booster" intervention among a random subsample of the treated families in comparison to non-treated families on the outcomes of interest. The third phase of the study (10th and 11th wave) was focused on the long-term effects of the initial and booster intervention @tolan2016. For the present study, we focus only on the data collected at 10th and 11th wave (see section #link(<Variables>)[Variables])

== Randomization

In the SAFE children study, the initial random assignment to the control or treatment condition was done within classrooms to control for potential confounding school-related effects. They randomly assigned 55% of the children in each classroom to the treatment condition and 45% to the control condition. This intentional imbalance was based on research indicating higher attrition rates for the intervention group @tolan2004. After randomization, families remained in the same conditions throughout the study.  In the second study phase, during fourth grade, approximately half of the families ($N = 114$) in the treatment group were randomly selected to receive a “booster” intervention. 

Regarding the present study, data from the 10th and 11th wave will be randomly split into two equal halves to create a training and testing/validation sample. The training set comprises the first half of the 10th wave and the second half of the 11th wave, whereas the remaining half of the 11th wave constitutes the test set. Randomization will be conducted using the seed `250925192132`.

== Variables 

<Variables>

Based on the study's objective, the main variables of interest are the items of  the Youth Self Report (YSR) and Child Behavior Checklist (CBCL) from the Achenbach System of Empirically Based Assessment @achenbach2001a. The Teacher Report Form (TRF) was excluded from the current study, because there were no overlapping waves of data that included the full item set for all three informants (parent, child, teacher). In the primary study the 2001 version of the ASEBA was used @achenbach2001a. It includes 113 items for the CBCL, and 112 items for the YSR. The items are rated on a three-point Likert scale, where 0 = Not true, 1 = Somewhat or sometimes true, and 2 = Very true or often true. The ASEBA is organized into eight clinical subscales, which are used to assess various dimensions of child behavior and emotional problems (see Table 3). Not all items are included in these subscales, and items that do not correspond to one of the clinical subscales are grouped under "Other problems". These items will be disregarded for the construction of the subtest in the current study. This is due to the fact that the contents of these items focus on very specific psychopathological problems that do not belong to the general psychopathological dimensions that the ASEBA subscales are designed to assess. The YSR and CBCL differ in the number of items per clinical subscale (see Table 3) because  the CBCL includes additional items that cannot be assessed via self-report. The exact mapping of the item identifiers to the clinical subscales for both measures is provided in an additional file in the registration (_aseba_man_2001.xlsx_).

== Exhaustiveness of Variables

The primary study included a wide range of additional variables that were relevant for the original study purpose, but that are irrelevant to the aims of the current study.

#v(1em)

- [ ] All variables of the planned study are outlined here and their roles are clearly defined
- [x] Our planned study includes additional variables that are not listed here.

== Study Materials

Child Behavior Checklist (CBCL) and Youth Self Report (YSR) from the Achenbach System of Empirically Based Assessment @achenbach2001a described in the section #link(<Variables>)[Variables] are the main materials used in this study. 

== Study Procedures

As mentioned previously, only data from the 10th and 11th wave of the SAFE children study will be used in the current study. These waves included the full item set of the YSR and CBCL. 

= Analysis Plan

== Criteria for post-data collection exclusion

All data from the responders of the 10th and 11th wave will be included in the analysis. We will not exclude any data based on post-data collection criteria.

== Data preprocessing

Not applicable.

== Data cleaning and screening

Considering that the items are rated on a three-point Likert-scale and measure clinical constructs that typically follow right-skewed distributions, it is highly likely that the assumption of multivariate normality will be violated. Therefore, the robust maximum likelihood estimator (MLR) will be used to account for non-normality.

== Handling of missing data

To address missing data in the dataset, full information maximum likelihood (FIML) will be used for estimation @enders2001. This approach utilizes all available data, allowing for the inclusion of participants with incomplete data, and thereby avoiding the drawbacks of listwise or pairwise deletion.

== Measurement- and Structural Model

To construct a subtest of the ASEBA that integrates both shared and informant-specific perspectives, a structural equation modeling approach (SEM) will be employed.

Here, each manifest variable $X_(i j k l )$ refers to the $i$-th item ($i = 1, ..., i = I_j$) within the $j$-th clinical subscale of the ASEBA ($j = 1, ..., j = J$) for the $k$-th informant ($k in \{1, 2\}$) loading on the $l$ latent factor where $l in  \{ "CI-C", "CI-P", "IS-C", "IS-P"\}$. For simplicity, the subscript $l$ will be dropped in the following description of the model and only refer to it when necessary.

Building on the outlined Operations Triad Model @delosreyes2013, we posit that the covariance structure of the items of the ASEBA subscales can be explained by two latent variables for each informant: a shared cross-informant factor that reflects common variances across informant (_converging operations_), and an informant-specific factor that should capture unique variance relevant to each informant's perspective (_diverging operations_). 

The cross-informant perspective is modeled by latent factors for both child (CI-C) with manifest items of the YSR and parent (CI-P) with manifest items of the CBCL. As illustrated in @fig2, items assigned to these latent factors must adhere to the constraint of configural invariance, meaning that same items must be selected for both informants. In constrast the informant-specific perspective is modeled by separate latent factors for child (IS-C) and parent (IS-P) with manifest items of the YSR and CBCL, respectively. Items for these latent factors can be freely selected. Factor loadings the first item of each latent factor will be fixed to 1 to set the scale of the latent factors. The CI-P factor will be regressed on the CI-C factor, which is in line with the _CTC(M-1)_ model definition provided by #cite(<eid2000>, form: "prose"). All latent variances, covariances and regression paths will be freely estimated.

Regarding the number of manifest variables $X$ included in the model, we decided on $k = 2$ item per latent factor (as indicated in @fig2) resulting in four items for each informant for each clinical subscale. In total, this equates to $8 dot 4 = 32$ items for each constructed subtest (child and parent informant). 

#figure(
  [
  #include "resources/model.typ"
  #text(size: 11pt)[#par(first-line-indent: 0em, [
    #align(left)[_Note:_ IS: Informant-Specific Factor, CI: Cross-Informant Factor, C: Child informant, P: Parent informant; figure generated using thetypst package #link("https://typst.app/universe/package/fletcher/")[_fletcher_].]
  ])]
  ],
  caption: par(first-line-indent: 0em, [Proposed Structural Equation Model for a Single Clinical Subscale of the ASEBA])
) <fig2>


== Empirical Objective Function

=== Criteria

To select a set of items that meets the construction goal, an objective function will be defined, consisting of the following criteria:

1. _Model fit_

Two model fit indices will be included as criteria for the objective function: The sample-corrected robust Root Mean Square Error of Approximation @li2006.

$
R M S E A = sqrt(max(0, hat(F)_("ML")/(d f) - (hat(c))/(n - 1)))
$ <eq1>

where $hat(c)$ is a correction constant, $hat(F)_("ML")$ is the value of the minimized fit function, $d f$ are the degrees of freedom and $n$ is the sample size @brosseau-liard2012. This corresponds to the _"rmsea.robust"_ criterion in the _lavaan_ package @rosseel2012.  

Additionally, the Standardized Root Mean Square Residual @bentler1995 will be included as a second model fit criterion

$
S R M R = sqrt(2/(p (p + 1)) sum_(u = 1)^p sum_(v=1)^p ((s_(u v) - hat(sigma)_(u v)) / (s_(u u) s_(v v)))^2)
$ <eq2>

where $p$ is the number of manifest variables in the model, $s_(u v)$ is the sample covariance between manifest variables $u$ and $v$, and $hat(sigma)_(u v)$ is the estimated covariance between manifest variables $u$ and $v$. This corresponds to the _"srmr"_ criterion in the _lavaan_ package @rosseel2012.

2. _Average reliability $overline(omega)$_

As a criterion for the reliability across the four latent factors, we will calculate the average composite reliability $overline(omega)$. This is given by the following formula:

$
overline(omega) =
1/l sum_(j = 1)^l  [(sum_(i = 1)^p lambda_(i j k l))^2 / ((sum_(i = 1)^p lambda_(i j k l))^2 + (sum_(i = 1)^p theta_(i j k l)))] 
$ <eq3>

where $l$ is the number of latent factors (i.e., $l = 4$), $lambda_(i j k l)$  is the factor loading of item $i$ ($i = 1, ..., i = I_j$) within the $j$-th clinical subscale of the ASEBA ($j = 1, ..., j = J$) for the $k$-th informant ($k in \{1, 2\}$) loading on the $l$ latent factor ($l in  \{ "CI-C", "CI-P", "IS-C", "IS-P"\}$), and $theta_(i j k l)$ is the corresponding error variance of item.

3. _Regression weight_ $gamma$

Highlighted in orange in the model in @fig2, the regression coefficient $gamma$ from the cross-informant parent factor (CI-P) to the cross-informant child factor (CI-C) will be included as a criterion in the objective function. This coefficient reflects the extent item selected for these factors are answered consistently across both informants.

4. _Latent correlation_ $phi$

Finally, the latent correlation $phi$ highlighted in blue in @fig2
between the informant-specific factors (IS-C and IS-P) will be included as a criterion in the objective function. This correlation reflects the extent to which the items selected for these factors capture informant-specific perspectives by aiming for a low correlation between the two factors.

== Combination of Criteria 

Each criterion will be transformed onto a common scale using the cumulative distribution function of the normal distribution $Phi(x_v\; mu, sigma)$, with parameters corresponding to difficulty (point of maximum discrimination) and discrimination (slope). These parameters will be empirically estimated from 
$k = 5000$ random solutions sampled from the search space of all possible item combinations from the model specified in @fig2 @schultze2021 @schultze2022. The mean and standard deviation of the top 10% of valid solutions will be used for the transformation.

The combined empirical objective function $f$ is then given by a weighted sum of the set of transformed criteria $cal(X): \{ "RMSEA", "SRMR", overline(omega), phi, gamma\}$:

$
f = sum_(q = 1)^r w_q dot Phi(x_q\; hat(mu)_(x_q), hat(sigma)_(x_q))
$ <eq4>

with weights $cal(W)$ set as $w_("RMSEA") = w_("SRMR") = w_phi = w_gamma = 1/6$ and  $w_(overline(omega)) = 1/3$, reflecting their relative importance.


== Model Estimation

Because the search space of all possible item combinations is feasible for a brute-force search, we will use an exhaustive search to identify the item combination that optimally satisfies the criteria of the empirical objective function $f$. As a rationale for the brute-force search, we note that the number of combinations is feasible to compute exhaustively. For the clinical subscale with the most number of items, _Aggressive Behavior (AB)_ with 13 items, the number of possible combinations when selecting two items per factor given the model provided in @fig2 equates to 474552 combinations, which is a manageable number to compute exhaustively. For the remaining clinical subscales, the number of combinations is even smaller, because they have fewer items.

To estimate the structural equation models, the _stuart_ R-package @schultze2023 will be used to perform the search and model estimation, which uses the _lavaan_ package @rosseel2012 as a backend. Because a factor model including all eight clinical subscales at the same time would lead to a very complex model with a large number of parameters, the model in @fig2 will be sequentially estimated for each clinical subscale separately. 

As mentioned previously, we will use both 10th and 11th wave data of the SAFE children study for the present study. Using both waves of data allows us to randomly split the data into two equal parts, combining the first half of the wave 10 data with the second half of the wave 11 data. This combined dataset will be used as a training set for the item selection procedure. All hypotheses and exploratory research questions will be tested on the remaining half of the data, which will be used as a test set. This approach allows us to better assess the generalizability of the constructed subtests and to avoid overfitting the model to the training data.

== Minimum Viable Criteria (MVC) 

<mvc>

In order to assess the overall quality of the constructed subtest ($H_1$), we will define a set of Minimum Viable Criteria (MVC) based on the criteria included in the empirical objective function $f$. The MVC will serve as benchmarks that the constructed subtest _must_ meet to be considered acceptable. 
This will be determined without inferential testing. Instead estimated values of the criteria will be compared to the determined cutoff values of the MVC. If a subscale does not meet one of the criteria, we will run through a diagnostic algorithm (see section #link(<diagnostic_algorithm>)[Diagnostic Algorithm]) to identify potential issues with the item selection.

=== Model Fit Criteria 

Cutoff values for model fit criteria (RMSEA, SRMR) will not be based on conventional fixed cutoffs (e.g., Hu & Bentler, 1999). Instead, dynamic fit indices will be applied using the _ezCutoffs_ package @schmalbach2025. In this approach, the model derived from the item selection procedure is treated as the correctly specified null model. Data are simulated from this model and repeatedly refitted with the same specification, producing an empirical distribution of fit indices under this model. Cutoff values are then defined as the 95th percentile ($alpha = .05$) of this distribution. We will use the `normality = "empirical"` option of the package to empirically account for non-normality in the data in the simulation and simulate 1000 datasets to generate the distribution

=== Average Reliability $overline(omega)$

Selecting only $k = 2$ items per factor to construct the subtest will inherently lead to substantially lower reliability estimates than those for the full scales. Still, consistency within each factor remains a desirable psychometric property of the subtest. 

To establish a reasonable benchmark for the expected reliability given the reduced number of items, we will use the Brown-Spearman prediction formula @brown1910@spearman1910a. This formula allows us to estimate the reliability for a shortened version of a scale based on the reliability of estimates of the original scale and the ratio of number of items between the original and new scale. Reliability estimates reported in the ASEBA manual @achenbach2001a will be used as the original reliability estimates for these calculations. The Brown-Spearman formula is given by:

$
rho^* = (r rho) / (1 + (r-1) rho)
$ <eq6>

where $r$ is the ratio of the number of items in the new test to the number of items in the original test, $rho$ is the reliability of the original test, and $rho^*$ is the predicted reliability of the new test. The calculated reliabilities are summarized in the two right columns of Table 3 below. These values will serve as benchmarks for the reliability of the constructed subtest. 

=== Latent Correlation $phi$

Because the informant-specific factors are intended to capture unique variance relevant to each informant's perspective, we expect that the latent correlation between the informant-specific factors of the child and parent informants should be as low as possible. To have a reasonable benchmark for the expected latent correlation, we refer to the agreement between the parent and child reports of the ASEBA manual @achenbach2001a. Agreement is defined as the correlation between the parent (CBCL) and youth (YSR) reports for each subscale. The agreement values are summarized in the second column of Table 3 above. To satisfy this criterion, agreement in the constructed subtests should be lower for the informant-specific factors than the agreement values reported in the ASEBA manual.

=== Latent Regression Weight $gamma$

Using the same reasoning as for the latent correlation vice versa, we expect that the regression weight of the cross-informant factors between the child and parent informants to be as high as possible, because they are intended to capture the common variance across informants. 
Parallel to the latent correlation, we will again use the agreement values report in the ASEBA manual @achenbach2001a as a benchmark for the expected regression weight. The regression weight should be higher than the agreement values reported in the ASEBA manual.


#let rel = csv("/data/processed/aseba_reliability_calc_sb.csv")

#figure(
  [
    #text(size: 9pt)[
      #table(
        columns: 8,
        align: (left + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
        toprule,
        [*Scale*], [*Agree*], [*CBCL (_N_)*],[*YSR (_N_)*],[*CBCL ($alpha$)*],[*YSR ($alpha$)*], [*CBCL ($rho^*$)*],[*YSR ($rho^*$)*],
        midrule,
        ..rel.slice(1).flatten(),
        bottomrule
      )]
    ],
  caption: [Cross-Informant Agreement and Reliability Estimates for all ASEBA Subscales],
) <table3>

#text(size:9pt)[
  _Note:_ Agree (agreement) refers to the correlation between the parent (CBCL) and youth (YSR) reports for each subscale. Data taken from the ASEBA manual @achenbach2001a. The sample sizes for the CBCL and YSR are denoted as $N$ in parentheses. The reliability estimates ($alpha$) are calculated using Cronbach's alpha for each subscale, with the predicted reliability ($rho^*$) estimated using the Spearman-Brown prediction formula based on the number of items in the new tests compared to the original tests. 
]

== Diagnostic Algorithm 

<diagnostic_algorithm>

In cases when one of the Minimum Viable Criteria (MVC) is not met, we will run through a diagnostic algorithm to identify potential issues with the item selection (see @fig3). 

1. If both RMSEA and SRMR do not meet the MVC, we will drop the clinical subscale from the item selection procedure.
2. If SRMR meets the MVC, but RMSEA does not, the model is likely overparametrized, implying one or more factors may not be necessary. This should manifest in either too low cross-informant consistency (i.e., low regression weight $gamma$) or too low informant-specific uniqueness (i.e., high latent correlation $phi$). See point 3. and 4.
3. If the regression weight $gamma$ does not meet the MVC, we will drop the cross-informant factors (CI-C, CI-P) from the model.
4. If the latent correlation $phi$ does not meet the MVC, we will drop the informant-specific factors (IS-C, IS-P) from the model.
5. If the average reliability $overline(omega)$ is too low and does not meet the MVC, we will check, which of the four factors falls below the reliability threshold. If one of the cross-informant factors (CI-C, CI-P) falls below it, we will drop both factors. If one of the informant-specific factors (IS-C, IS-P) falls below it, we will drop only the respective factor. If at least one of both cross-informant and informant-specific factors falls below the threshold, we will drop the entire clinical subscale from the item selection procedure.

In cases where one or more factors are dropped from the model, we will rerun the item selection procedure with the reduced model specification. For potential cases not covered by the preregistration, exploratory post-hoc analyses will be conducted and explicitly labeled as such. Any findings from these exploratory analyses will require verification with new data.

#figure(
  [
  #include "resources/algorithm.typ"
  #text(size:10pt)[
    #par(first-line-indent: 0em, [
    #align(left)[ _Note:_ \*Only drop the respective factor, if the reliability of only one of the two informants falls below the threshold. CI: Cross-Informant, IS: Informant-Specific; figure generated using the typst package #link("https://typst.app/universe/package/fletcher/")[_fletcher_].
    ]
  ])]
  ],
  caption: [Diagnostic Algorithm for Identifying Issues with the Item Selection]
) <fig3>

== Testing Hypotheses

Because the item selection procedure will be conducted sequentially for each clinical subscale separately, the hypotheses will also be tested separately for each clinical subscale.

=== $H_1$

Hypothesis 1 will be tested by assessing the overall model fit of the constructed subtests using the Minimum Viable Criteria (MVC) approach described above. As mentioned, whether MVC are met will be determined strictly by comparing the estimated values of the criteria to the determined cutoff values of the MVC. 


=== $H_2$

Hypothesis 2 will be tested by assessing the measurement invariance of the cross-informant factors across the child and parent informants. By specification of the measurement model, these factors are already constrained to configural measurement invariance. More restrictive levels of measurement invariance (metric, scalar, strict) will be sequentially tested. For metric invariance, the factor loadings of the items loading onto the cross-informant factors (CI-C, CI-P) will be constrained to be equal across informants. For scalar invariance, both factor loadings and item intercepts will be constrained to be equal across informants. Finally, for strict invariance, factor loadings, item intercepts and item residual variances will be constrained to be equal across informants.

Invariance will be tested using information criteria (AIC, BIC, aBIC; see @eq7 - @eq9) to assess whether the more restrictive models lead to a substantial decrease in model fit. If the information criteria do not agree unanimously, a $chi^2$ difference test will be used to test whether the equivalence in model fit between the less and more restrictive model must be rejected.

$
A I C = -2 log cal(L)(hat(cal(upsilon))) + 2 k
$ <eq7>

$
B I C = -2 log cal(L)(hat(cal(upsilon))) + k log(n)
$ <eq8>

$
a B I C = -2 log cal(L)(hat(cal(upsilon))) + k log(n) + 2 k (k + 1) / (n - k - 1) 
$ <eq9>

=== $H_3$

To test the informant-specific functioning of items selected for the informant-specific factors, a model will be defined where items selected for the informant specific factors (IS-C, IS-P) load onto their respective cross-informant factor counterpart and remove the informant-specific factors from the model completely. 

For instance consider the example items in @fig2. In this case, two models would be defined: In the first model, items $X_(1 1 1)$, $X_(2 1 1)$, $X_(3 1 1)$, $X_(4 1 1)$ would load onto the child factor and items $X_(1 1 2)$, $X_(2 1 2)$, $X_(3 1 2)$, $X_(4 1 2)$ would load onto the parent factor. In the second model, items $X_(1 1 1)$, $X_(2 1 1)$, $X_(5 1 1)$, $X_(6 1 1)$ would load onto the child factor and items $X_(1 1 2)$, $X_(2 1 2)$, $X_(5 1 2)$, $X_(6 1 2)$ would load onto the parent factor. Only if the model fit for both models is rejected, we will conclude that the items selected for the informant-specific factors demonstrate informant-specific functioning. 

Model fit will again be assessed in terms of RMSEA and SRMR using the _ezCutoffs_ approach described above. However, cutoffs determined in this way previously cannot be used and must be recalculated, because the model structure has changed. 

#pagebreak()

== Analysis of Exploratory Research Questions

To analyse our exploratory research question, we will extract factor scores for each of the four latent factors (CI-C, CI-P, IS-C, IS-P) for each clinical subscale of the ASEBA. This will be done using the following approach:

In step one, Bartlett-Factor-Scores (BFS) will be estimated for each of the four latent factors (CI-C, CI-P, IS-C, IS-P) for each clinical subscale of the ASEBA. This will be done using the `lavPredict()` function of the _lavaan_ package @rosseel2012. In step two, the estimated factor scores will be adjusted for measurement error by fitting a single indicator factor model where the estimated factor scores are used as a manifest variable for the respective latent factor with fixed factor loading of one and error variance fixed to the squared standard error of the factor scores. 

After factor scores have been estimated, pairwise correlations between the factor scores of the four latent factors (CI-C, CI-P, IS-C, IS-P) of each clinical subscale with each respective latent factor of all other clinical subscales will be calculated. In total this will result in $4 dot 8 dot 7 = 224$ unique correlations. No inferential testing will be conducted. Instead, the correlations will be interpreted descriptively in an exploratory manner.

#bibliography("resources/references.bib", style: "american-psychological-association")