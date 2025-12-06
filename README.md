

<!-- badges: start -->

<!-- badges: end -->

# Forschungsmodul *PsyMSc5*

## General Information

<table>

<tr>

<td>

<h5>

Project Title
</h5>

</td>

<td>

<h5>

Student
</h5>

</td>

<td>

<h5>

Coordination
</h5>

</td>

<td>

<h5>

Semester
</h5>

</td>

</tr>

<tr>

<td>

Using Automatic Item Selection in Multi-Informant Assessment of Child
Mental Health
</td>

<td>

Luca Schnatz
</td>

<td>

Prof. Martin Schultze
</td>

<td>

SS25 + WS25/26
</td>

</tr>

<tr>

<td colspan="4">

<h5>

Abstract
</h5>

<p>

Comprehensive clinical assessment of mental health in children and
adolescents often relies on multiple informants, such as parents,
teachers and children themselves. However, discrepancies in reports from
different raters are common, leading to challenges in interpreting the
results of assessment procedures. These discrepancies may arise because
some items capture behaviors that are commonly observed across
informants, while others reflect informant-specific perspectives unique
to each rater. At the same time, there is a need for economic
instruments that reduce burden for respondents and clinicians while
maintaining reliability and validity. To address these challenges the
present study aims to develop a subtest containing 32 items of the
commonly employed multi-informant assessment instrument Achenbach System
of Empirically Based Assessment (ASEBA) that balances shared and
informant-specific perspectives while retaining a manageable number of
items for economic administration in clinical settings. This will be
achieved within a structural equation modeling framework leveraging an
automatic item selection approach to identify an item set that optimally
satisfies a predefined set of construction criteria. The present study
will use two waves of data of parent and child ratings on the ASEBA
Child Behavior Checklist (CBCL/6-18) and Youth Self Report (YSR/11-18)
from the SAFE children study (Tolan et al., 2016), a longitudinal
randomized controlled trial with N = 424 children and their primary
caregivers that participated in a family-centered preventive
intervention program.
</p>

</td>

</tr>

</table>

## License

The code in the repository is licensed under the [GPL-3.0
License](https://www.gnu.org/licenses/gpl-3.0.de.html).

## Preregistration

The preregistration for this project was submitted on October, 1st, 2025
and can be found in the folder `preregistration/preregistration.pdf`.
The OSF preregistration page can be found on
<https://doi.org/10.17605/OSF.IO/FERJ5>.

## Data Download

Data used for this study is sourced from the Schools and Families
Educating (SAFE) Children Study (ICPSR 34368), see
https://doi.org/10.3886/ICPSR34368.v1. Data must not be redistributed on
this platformaccording to the data use agreement but may be downloaded
from the original source. To download the data, please register using an
institutional email address and agree to the terms of the data use
agreement. After registration, you can download the data directly from
the [ICPSR
website](https://www.icpsr.umich.edu/web/ICPSR/studies/34368). For
reproducibility purposes, we recommend downloading the data as SAV
(SPSS) files.

## Reproducibility of Project

### Dependecy Graph of *targets* Pipeline

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    xf1522833a4d242c5(["Up to date"]):::uptodate
    x2db1ec7a48f65a9b(["Outdated"]):::outdated
    xd03d7c7dd2ddda2b(["Regular target"]):::none
    x6f7e04ea3427f824["Dynamic branches"]:::none
  end
  subgraph Graph
    direction LR
    xe078f1fb87a5f306(["data_cutoff"]):::uptodate --> xe0db2d402d09558a(["cutoffs_AB"]):::outdated
    x9f1f644ccc1a57e8(["solution_AB"]):::outdated --> xe0db2d402d09558a(["cutoffs_AB"]):::outdated
    xe078f1fb87a5f306(["data_cutoff"]):::uptodate --> x0480ac0541dbaa5f(["cutoffs_AD"]):::outdated
    x13b6d3cc35bfc623(["solution_AD"]):::outdated --> x0480ac0541dbaa5f(["cutoffs_AD"]):::outdated
    xe078f1fb87a5f306(["data_cutoff"]):::uptodate --> x67b2b52b9ccc3fd5(["cutoffs_AP"]):::outdated
    x2281cb03d5dddcda(["solution_AP"]):::outdated --> x67b2b52b9ccc3fd5(["cutoffs_AP"]):::outdated
    xa5df33531960f2cc(["solution_RB"]):::outdated --> xb6193fa99ce7445e(["cutoffs_RB"]):::outdated
    xe078f1fb87a5f306(["data_cutoff"]):::uptodate --> xb6193fa99ce7445e(["cutoffs_RB"]):::outdated
    xe078f1fb87a5f306(["data_cutoff"]):::uptodate --> xfef4e7f2979c5687(["cutoffs_SC"]):::outdated
    x3a7e60512ad4a028(["solution_SC"]):::outdated --> xfef4e7f2979c5687(["cutoffs_SC"]):::outdated
    x1200691f4b62af4a(["solution_SP"]):::outdated --> x25e4606903bb5cd9(["cutoffs_SP"]):::outdated
    xe078f1fb87a5f306(["data_cutoff"]):::uptodate --> x25e4606903bb5cd9(["cutoffs_SP"]):::outdated
    xe078f1fb87a5f306(["data_cutoff"]):::uptodate --> x00a5b28f1e6cf291(["cutoffs_TP"]):::outdated
    x94c15ca1564b7a81(["solution_TP"]):::outdated --> x00a5b28f1e6cf291(["cutoffs_TP"]):::outdated
    xe078f1fb87a5f306(["data_cutoff"]):::uptodate --> xbea11ac8aed9ec0a(["cutoffs_WD"]):::outdated
    xa991b6d2b4431cb9(["solution_WD"]):::outdated --> xbea11ac8aed9ec0a(["cutoffs_WD"]):::outdated
    x474e7b3612aa05fe(["dropout"]):::outdated --> x647af5ca2a750e19(["data_aseba"]):::outdated
    x53cf5ba2a7a40912(["data_safe"]):::outdated --> x647af5ca2a750e19(["data_aseba"]):::outdated
    xdb4e59bc3d0ac3b3(["agr_file"]):::uptodate --> xe078f1fb87a5f306(["data_cutoff"]):::uptodate
    x6e3a455736075628(["rel_file"]):::uptodate --> xe078f1fb87a5f306(["data_cutoff"]):::uptodate
    x1e2f6b892b676f51["sav_files"]:::outdated --> x53cf5ba2a7a40912(["data_safe"]):::outdated
    x53cf5ba2a7a40912(["data_safe"]):::outdated --> x3ed5bb9884f4eeb7(["dict"]):::outdated
    x53cf5ba2a7a40912(["data_safe"]):::outdated --> x474e7b3612aa05fe(["dropout"]):::outdated
    xf60d83bc019bc9d7(["training_subset_AB"]):::outdated --> xcb78b2803fa3be2c(["fs_AB"]):::outdated
    x3473628798949931(["training_subset_AD"]):::outdated --> xcf9c67916e997734(["fs_AD"]):::outdated
    x4ba6a6489e391b5d(["training_subset_AP"]):::outdated --> xb1a628294e9ab995(["fs_AP"]):::outdated
    x690aaa23c060b0c7(["training_subset_RB"]):::outdated --> x8605b3768caaab21(["fs_RB"]):::outdated
    x9dd12e61daa5c580(["training_subset_SC"]):::outdated --> x2f08e535180f031f(["fs_SC"]):::outdated
    x2f73011017deaa39(["training_subset_SP"]):::outdated --> x71e324cc06f2c42f(["fs_SP"]):::outdated
    xef5410a5dce77230(["training_subset_TP"]):::outdated --> xbee8fb64ded30192(["fs_TP"]):::outdated
    xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated --> xa4678874b5695712(["fs_WD"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> x33425557521a5715(["h2_AB"]):::outdated
    x9f1f644ccc1a57e8(["solution_AB"]):::outdated --> x33425557521a5715(["h2_AB"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> xeac1355c62f46484(["h2_AD"]):::outdated
    x13b6d3cc35bfc623(["solution_AD"]):::outdated --> xeac1355c62f46484(["h2_AD"]):::outdated
    x2281cb03d5dddcda(["solution_AP"]):::outdated --> x1c2baf73b8b9013f(["h2_AP"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> x1c2baf73b8b9013f(["h2_AP"]):::outdated
    xa5df33531960f2cc(["solution_RB"]):::outdated --> xa423733ded11340e(["h2_RB"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> xa423733ded11340e(["h2_RB"]):::outdated
    x3a7e60512ad4a028(["solution_SC"]):::outdated --> x54d76411cdc17880(["h2_SC"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> x54d76411cdc17880(["h2_SC"]):::outdated
    x1200691f4b62af4a(["solution_SP"]):::outdated --> xb33e0c820ad81765(["h2_SP"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> xb33e0c820ad81765(["h2_SP"]):::outdated
    x94c15ca1564b7a81(["solution_TP"]):::outdated --> xeb4fc7960bdc5acf(["h2_TP"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> xeb4fc7960bdc5acf(["h2_TP"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> x37072e48cf4465a2(["h2_WD"]):::outdated
    xa991b6d2b4431cb9(["solution_WD"]):::outdated --> x37072e48cf4465a2(["h2_WD"]):::outdated
    x9f1f644ccc1a57e8(["solution_AB"]):::outdated --> x90c9236e4e768b0b(["h3_AB"]):::outdated
    x13b6d3cc35bfc623(["solution_AD"]):::outdated --> xe9b98d57d0c60fed(["h3_AD"]):::outdated
    x2281cb03d5dddcda(["solution_AP"]):::outdated --> xab08567b967ea9e4(["h3_AP"]):::outdated
    xa5df33531960f2cc(["solution_RB"]):::outdated --> x697ca187f42fb802(["h3_RB"]):::outdated
    x3a7e60512ad4a028(["solution_SC"]):::outdated --> x49710659d920eeba(["h3_SC"]):::outdated
    x1200691f4b62af4a(["solution_SP"]):::outdated --> x624bd8800368c7be(["h3_SP"]):::outdated
    x94c15ca1564b7a81(["solution_TP"]):::outdated --> x1b03a215bf036ea1(["h3_TP"]):::outdated
    xa991b6d2b4431cb9(["solution_WD"]):::outdated --> xe3f9d2a8a27258ca(["h3_WD"]):::outdated
    xa7c0e709c76a0ac5(["meta_cbcl"]):::uptodate --> x6a90fc6145ebf215(["item_assignment"]):::uptodate
    x06c0f8476667fd3f(["meta_ysr"]):::uptodate --> x6a90fc6145ebf215(["item_assignment"]):::uptodate
    x6a90fc6145ebf215(["item_assignment"]):::uptodate --> x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated
    x0c307f7e4efbd259(["missing_items"]):::outdated --> x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated
    xd9e5ec19b55a4a31(["file_meta_aseba"]):::uptodate --> xa7c0e709c76a0ac5(["meta_cbcl"]):::uptodate
    xd9e5ec19b55a4a31(["file_meta_aseba"]):::uptodate --> x06c0f8476667fd3f(["meta_ysr"]):::uptodate
    x6a90fc6145ebf215(["item_assignment"]):::uptodate --> x0c307f7e4efbd259(["missing_items"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> x0c307f7e4efbd259(["missing_items"]):::outdated
    xf60d83bc019bc9d7(["training_subset_AB"]):::outdated --> x3cb85ffeed963a54(["objective_fun_AB"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> x3cb85ffeed963a54(["objective_fun_AB"]):::outdated
    xcb78b2803fa3be2c(["fs_AB"]):::outdated --> x3cb85ffeed963a54(["objective_fun_AB"]):::outdated
    x3473628798949931(["training_subset_AD"]):::outdated --> xbfdb472195c4518d(["objective_fun_AD"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> xbfdb472195c4518d(["objective_fun_AD"]):::outdated
    xcf9c67916e997734(["fs_AD"]):::outdated --> xbfdb472195c4518d(["objective_fun_AD"]):::outdated
    x4ba6a6489e391b5d(["training_subset_AP"]):::outdated --> x9cce0ead64844b28(["objective_fun_AP"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> x9cce0ead64844b28(["objective_fun_AP"]):::outdated
    xb1a628294e9ab995(["fs_AP"]):::outdated --> x9cce0ead64844b28(["objective_fun_AP"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> xd7d5e3779ecc1b7b(["objective_fun_RB"]):::outdated
    x8605b3768caaab21(["fs_RB"]):::outdated --> xd7d5e3779ecc1b7b(["objective_fun_RB"]):::outdated
    x690aaa23c060b0c7(["training_subset_RB"]):::outdated --> xd7d5e3779ecc1b7b(["objective_fun_RB"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> xa1c49a793f5e3cf5(["objective_fun_SC"]):::outdated
    x9dd12e61daa5c580(["training_subset_SC"]):::outdated --> xa1c49a793f5e3cf5(["objective_fun_SC"]):::outdated
    x2f08e535180f031f(["fs_SC"]):::outdated --> xa1c49a793f5e3cf5(["objective_fun_SC"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> x794ff61a4b518494(["objective_fun_SP"]):::outdated
    x2f73011017deaa39(["training_subset_SP"]):::outdated --> x794ff61a4b518494(["objective_fun_SP"]):::outdated
    x71e324cc06f2c42f(["fs_SP"]):::outdated --> x794ff61a4b518494(["objective_fun_SP"]):::outdated
    xbee8fb64ded30192(["fs_TP"]):::outdated --> xa5a448ba6ee321c2(["objective_fun_TP"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> xa5a448ba6ee321c2(["objective_fun_TP"]):::outdated
    xef5410a5dce77230(["training_subset_TP"]):::outdated --> xa5a448ba6ee321c2(["objective_fun_TP"]):::outdated
    x370c26d77466d196(["model_args"]):::uptodate --> xab506cb1f85898ca(["objective_fun_WD"]):::outdated
    xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated --> xab506cb1f85898ca(["objective_fun_WD"]):::outdated
    xa4678874b5695712(["fs_WD"]):::outdated --> xab506cb1f85898ca(["objective_fun_WD"]):::outdated
    x7849ff489c55a199(["sav_files_files"]):::outdated --> x1e2f6b892b676f51["sav_files"]:::outdated
    xf60d83bc019bc9d7(["training_subset_AB"]):::outdated --> x9f1f644ccc1a57e8(["solution_AB"]):::outdated
    x3cb85ffeed963a54(["objective_fun_AB"]):::outdated --> x9f1f644ccc1a57e8(["solution_AB"]):::outdated
    xbfdb472195c4518d(["objective_fun_AD"]):::outdated --> x13b6d3cc35bfc623(["solution_AD"]):::outdated
    x3473628798949931(["training_subset_AD"]):::outdated --> x13b6d3cc35bfc623(["solution_AD"]):::outdated
    x4ba6a6489e391b5d(["training_subset_AP"]):::outdated --> x2281cb03d5dddcda(["solution_AP"]):::outdated
    x9cce0ead64844b28(["objective_fun_AP"]):::outdated --> x2281cb03d5dddcda(["solution_AP"]):::outdated
    xd7d5e3779ecc1b7b(["objective_fun_RB"]):::outdated --> xa5df33531960f2cc(["solution_RB"]):::outdated
    x690aaa23c060b0c7(["training_subset_RB"]):::outdated --> xa5df33531960f2cc(["solution_RB"]):::outdated
    xa1c49a793f5e3cf5(["objective_fun_SC"]):::outdated --> x3a7e60512ad4a028(["solution_SC"]):::outdated
    x9dd12e61daa5c580(["training_subset_SC"]):::outdated --> x3a7e60512ad4a028(["solution_SC"]):::outdated
    x794ff61a4b518494(["objective_fun_SP"]):::outdated --> x1200691f4b62af4a(["solution_SP"]):::outdated
    x2f73011017deaa39(["training_subset_SP"]):::outdated --> x1200691f4b62af4a(["solution_SP"]):::outdated
    xef5410a5dce77230(["training_subset_TP"]):::outdated --> x94c15ca1564b7a81(["solution_TP"]):::outdated
    xa5a448ba6ee321c2(["objective_fun_TP"]):::outdated --> x94c15ca1564b7a81(["solution_TP"]):::outdated
    xab506cb1f85898ca(["objective_fun_WD"]):::outdated --> xa991b6d2b4431cb9(["solution_WD"]):::outdated
    xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated --> xa991b6d2b4431cb9(["solution_WD"]):::outdated
    x647af5ca2a750e19(["data_aseba"]):::outdated --> xe28e6a915fe1f815(["split_list"]):::outdated
    xe28e6a915fe1f815(["split_list"]):::outdated --> xa673c03795543c98(["test_set"]):::outdated
    xe28e6a915fe1f815(["split_list"]):::outdated --> x71630008d1c0fd02(["training_set"]):::outdated
    x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated --> xf60d83bc019bc9d7(["training_subset_AB"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> xf60d83bc019bc9d7(["training_subset_AB"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> x3473628798949931(["training_subset_AD"]):::outdated
    x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated --> x3473628798949931(["training_subset_AD"]):::outdated
    x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated --> x4ba6a6489e391b5d(["training_subset_AP"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> x4ba6a6489e391b5d(["training_subset_AP"]):::outdated
    x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated --> x690aaa23c060b0c7(["training_subset_RB"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> x690aaa23c060b0c7(["training_subset_RB"]):::outdated
    x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated --> x9dd12e61daa5c580(["training_subset_SC"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> x9dd12e61daa5c580(["training_subset_SC"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> x2f73011017deaa39(["training_subset_SP"]):::outdated
    x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated --> x2f73011017deaa39(["training_subset_SP"]):::outdated
    x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated --> xef5410a5dce77230(["training_subset_TP"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> xef5410a5dce77230(["training_subset_TP"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated
    x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated --> xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated
    
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
```
