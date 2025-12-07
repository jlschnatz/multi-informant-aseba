

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

<tr>

</td>

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
reproducibility purposes, we recommend downloading the data as **SAV**
(SPSS) files.

To ensure the reproducibility of the analysis pipeline the raw data must
be downloaded a subfolder `raw` within the `data` directory. If
successfull the folder structure within the `data/raw` folder should
look like this:

``` bash
tree -L 2 -P *.sav data/raw
```

    data/raw
    ├── DS0001
    │   └── 34368-0001-Data.sav
    ├── DS0002
    │   └── 34368-0002-Data.sav
    ├── DS0003
    │   └── 34368-0003-Data.sav
    ├── DS0004
    │   └── 34368-0004-Data.sav
    ├── DS0005
    │   └── 34368-0005-Data.sav
    ├── DS0006
    │   └── 34368-0006-Data.sav
    ├── DS0007
    │   └── 34368-0007-Data.sav
    ├── DS0008
    │   └── 34368-0008-Data.sav
    ├── DS0009
    │   └── 34368-0009-Data.sav
    ├── DS0010
    │   └── 34368-0010-Data.sav
    ├── DS0011
    │   └── 34368-0011-Data.sav
    ├── DS0012
    │   └── 34368-0012-Data.sav
    ├── DS0013
    │   └── 34368-0013-Data.sav
    ├── DS0014
    │   └── 34368-0014-Data.sav
    ├── DS0015
    │   └── 34368-0015-Data.sav
    ├── DS0016
    │   └── 34368-0016-Data.sav
    ├── DS0017
    │   └── 34368-0017-Data.sav
    ├── DS0018
    │   └── 34368-0018-Data.sav
    ├── DS0019
    │   └── 34368-0019-Data.sav
    ├── DS0020
    │   └── 34368-0020-Data.sav
    ├── DS0021
    │   └── 34368-0021-Data.sav
    ├── DS0022
    │   └── 34368-0022-Data.sav
    ├── DS0023
    │   └── 34368-0023-Data.sav
    ├── DS0024
    │   └── 34368-0024-Data.sav
    ├── DS0025
    │   └── 34368-0025-Data.sav
    ├── DS0026
    │   └── 34368-0026-Data.sav
    └── DS0027
        └── 34368-0027-Data.sav

    28 directories, 27 files

The subfolder labelling `DS00$$` is the default naming scheme when
downloading the data from ICPSR. The individual raw data folders
additional include documentation and questionnaire pdf files which are
not shown in the output above.

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
    x19901066f05e46bf(["data_safechild"]):::outdated --> x94fa842736a9e87c(["attrition_info"]):::outdated
    xfcf9dc5587ca812f(["agreement_data_file"]):::uptodate --> x65d0a122328c23eb(["cutoff_reference"]):::uptodate
    x6df6f985c42ccf5e(["rel_data_file"]):::uptodate --> x65d0a122328c23eb(["cutoff_reference"]):::uptodate
    x94fa842736a9e87c(["attrition_info"]):::outdated --> x647af5ca2a750e19(["data_aseba"]):::outdated
    x19901066f05e46bf(["data_safechild"]):::outdated --> x647af5ca2a750e19(["data_aseba"]):::outdated
    xc482bb1c34568587["raw_sav_files"]:::outdated --> x19901066f05e46bf(["data_safechild"]):::outdated
    x647af5ca2a750e19(["data_aseba"]):::outdated --> xdcc831f22b0ea9b0(["data_split"]):::outdated
    xf60d83bc019bc9d7(["training_subset_AB"]):::outdated --> x47bd50c7251a91d7(["factor_structure_AB"]):::outdated
    x3473628798949931(["training_subset_AD"]):::outdated --> xf9c2381a9df472cc(["factor_structure_AD"]):::outdated
    x4ba6a6489e391b5d(["training_subset_AP"]):::outdated --> xdf610cf2fb2c1c8f(["factor_structure_AP"]):::outdated
    x690aaa23c060b0c7(["training_subset_RB"]):::outdated --> x060aca937bf740d1(["factor_structure_RB"]):::outdated
    x9dd12e61daa5c580(["training_subset_SC"]):::outdated --> x60268332a490103c(["factor_structure_SC"]):::outdated
    x2f73011017deaa39(["training_subset_SP"]):::outdated --> x51555ce6802c0fe2(["factor_structure_SP"]):::outdated
    xef5410a5dce77230(["training_subset_TP"]):::outdated --> x33428c0b51cdbdd6(["factor_structure_TP"]):::outdated
    xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated --> x64aa35d356121bcb(["factor_structure_WD"]):::outdated
    x6a90fc6145ebf215(["item_assignment"]):::uptodate --> x7231b392ed9b3488(["fixed_item_assignment"]):::outdated
    xd8d2152144c105b6(["missing_item_info"]):::outdated --> x7231b392ed9b3488(["fixed_item_assignment"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> xaaae40d47c595acd(["informant_specificness_results_AB"]):::outdated
    xe856b436cf3cfb22(["subtest_solution_AB"]):::outdated --> xaaae40d47c595acd(["informant_specificness_results_AB"]):::outdated
    x909db895243e1d0d(["subtest_solution_AD"]):::outdated --> xc4de805e45d3bd16(["informant_specificness_results_AD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> xc4de805e45d3bd16(["informant_specificness_results_AD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x6fcd23830955fd87(["informant_specificness_results_AP"]):::outdated
    x5a4e45af0a265848(["subtest_solution_AP"]):::outdated --> x6fcd23830955fd87(["informant_specificness_results_AP"]):::outdated
    x192c366c8090576c(["subtest_solution_RB"]):::outdated --> x779ab17c7d8c8ae7(["informant_specificness_results_RB"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x779ab17c7d8c8ae7(["informant_specificness_results_RB"]):::outdated
    x7dfb795400228424(["subtest_solution_SC"]):::outdated --> x42605e003a171a8f(["informant_specificness_results_SC"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x42605e003a171a8f(["informant_specificness_results_SC"]):::outdated
    x7d376e0bdc71c3ad(["subtest_solution_SP"]):::outdated --> x02cb166df7768cd7(["informant_specificness_results_SP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x02cb166df7768cd7(["informant_specificness_results_SP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x1638a8332588e142(["informant_specificness_results_TP"]):::outdated
    x3920d41becff1b97(["subtest_solution_TP"]):::outdated --> x1638a8332588e142(["informant_specificness_results_TP"]):::outdated
    x3b6f30bf8f0dce31(["subtest_solution_WD"]):::outdated --> x9787710e2ae41030(["informant_specificness_results_WD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x9787710e2ae41030(["informant_specificness_results_WD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> xa817b6250b280842(["invariance_results_AB"]):::outdated
    xe856b436cf3cfb22(["subtest_solution_AB"]):::outdated --> xa817b6250b280842(["invariance_results_AB"]):::outdated
    x909db895243e1d0d(["subtest_solution_AD"]):::outdated --> x6401587737fb5a24(["invariance_results_AD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x6401587737fb5a24(["invariance_results_AD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x6250da3ea871d69e(["invariance_results_AP"]):::outdated
    x5a4e45af0a265848(["subtest_solution_AP"]):::outdated --> x6250da3ea871d69e(["invariance_results_AP"]):::outdated
    x192c366c8090576c(["subtest_solution_RB"]):::outdated --> x5ef4e7018e493fcf(["invariance_results_RB"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x5ef4e7018e493fcf(["invariance_results_RB"]):::outdated
    x7dfb795400228424(["subtest_solution_SC"]):::outdated --> x75f78bd1abf643d6(["invariance_results_SC"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x75f78bd1abf643d6(["invariance_results_SC"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x2d16bca77cd80811(["invariance_results_SP"]):::outdated
    x7d376e0bdc71c3ad(["subtest_solution_SP"]):::outdated --> x2d16bca77cd80811(["invariance_results_SP"]):::outdated
    x3920d41becff1b97(["subtest_solution_TP"]):::outdated --> x5167fdd47b31911a(["invariance_results_TP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x5167fdd47b31911a(["invariance_results_TP"]):::outdated
    x3b6f30bf8f0dce31(["subtest_solution_WD"]):::outdated --> x6e45e05e0fd16a9a(["invariance_results_WD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x6e45e05e0fd16a9a(["invariance_results_WD"]):::outdated
    x06c0f8476667fd3f(["meta_ysr"]):::uptodate --> x6a90fc6145ebf215(["item_assignment"]):::uptodate
    xa7c0e709c76a0ac5(["meta_cbcl"]):::uptodate --> x6a90fc6145ebf215(["item_assignment"]):::uptodate
    xde27b101f6fd6bed(["aseba_metadata_file"]):::uptodate --> xa7c0e709c76a0ac5(["meta_cbcl"]):::uptodate
    xde27b101f6fd6bed(["aseba_metadata_file"]):::uptodate --> x06c0f8476667fd3f(["meta_ysr"]):::uptodate
    x6a90fc6145ebf215(["item_assignment"]):::uptodate --> xd8d2152144c105b6(["missing_item_info"]):::outdated
    x3fac2193a6071940(["training_data"]):::outdated --> xd8d2152144c105b6(["missing_item_info"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x59f4fc024c377000(["mvc_results_AB"]):::outdated
    x65d0a122328c23eb(["cutoff_reference"]):::uptodate --> x59f4fc024c377000(["mvc_results_AB"]):::outdated
    xe856b436cf3cfb22(["subtest_solution_AB"]):::outdated --> x59f4fc024c377000(["mvc_results_AB"]):::outdated
    x65d0a122328c23eb(["cutoff_reference"]):::uptodate --> x27930d9a6b2f4edd(["mvc_results_AD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x27930d9a6b2f4edd(["mvc_results_AD"]):::outdated
    x909db895243e1d0d(["subtest_solution_AD"]):::outdated --> x27930d9a6b2f4edd(["mvc_results_AD"]):::outdated
    x5a4e45af0a265848(["subtest_solution_AP"]):::outdated --> xbf6077a6e78a05a1(["mvc_results_AP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> xbf6077a6e78a05a1(["mvc_results_AP"]):::outdated
    x65d0a122328c23eb(["cutoff_reference"]):::uptodate --> xbf6077a6e78a05a1(["mvc_results_AP"]):::outdated
    x192c366c8090576c(["subtest_solution_RB"]):::outdated --> x3c8622925748ce55(["mvc_results_RB"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x3c8622925748ce55(["mvc_results_RB"]):::outdated
    x65d0a122328c23eb(["cutoff_reference"]):::uptodate --> x3c8622925748ce55(["mvc_results_RB"]):::outdated
    x7dfb795400228424(["subtest_solution_SC"]):::outdated --> x84387f4354cf5b40(["mvc_results_SC"]):::outdated
    x65d0a122328c23eb(["cutoff_reference"]):::uptodate --> x84387f4354cf5b40(["mvc_results_SC"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x84387f4354cf5b40(["mvc_results_SC"]):::outdated
    x65d0a122328c23eb(["cutoff_reference"]):::uptodate --> x9408e50383babb83(["mvc_results_SP"]):::outdated
    x7d376e0bdc71c3ad(["subtest_solution_SP"]):::outdated --> x9408e50383babb83(["mvc_results_SP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x9408e50383babb83(["mvc_results_SP"]):::outdated
    x3920d41becff1b97(["subtest_solution_TP"]):::outdated --> x1346d14ab76ee491(["mvc_results_TP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x1346d14ab76ee491(["mvc_results_TP"]):::outdated
    x65d0a122328c23eb(["cutoff_reference"]):::uptodate --> x1346d14ab76ee491(["mvc_results_TP"]):::outdated
    x65d0a122328c23eb(["cutoff_reference"]):::uptodate --> x1d45e0e69b52b1c5(["mvc_results_WD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x1d45e0e69b52b1c5(["mvc_results_WD"]):::outdated
    x3b6f30bf8f0dce31(["subtest_solution_WD"]):::outdated --> x1d45e0e69b52b1c5(["mvc_results_WD"]):::outdated
    xf60d83bc019bc9d7(["training_subset_AB"]):::outdated --> x0567e39a7d6d538c(["objective_function_AB"]):::outdated
    x47bd50c7251a91d7(["factor_structure_AB"]):::outdated --> x0567e39a7d6d538c(["objective_function_AB"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x0567e39a7d6d538c(["objective_function_AB"]):::outdated
    x3473628798949931(["training_subset_AD"]):::outdated --> x47db7a93f9283c6c(["objective_function_AD"]):::outdated
    xf9c2381a9df472cc(["factor_structure_AD"]):::outdated --> x47db7a93f9283c6c(["objective_function_AD"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x47db7a93f9283c6c(["objective_function_AD"]):::outdated
    x4ba6a6489e391b5d(["training_subset_AP"]):::outdated --> x75373129f6a80bd4(["objective_function_AP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x75373129f6a80bd4(["objective_function_AP"]):::outdated
    xdf610cf2fb2c1c8f(["factor_structure_AP"]):::outdated --> x75373129f6a80bd4(["objective_function_AP"]):::outdated
    x060aca937bf740d1(["factor_structure_RB"]):::outdated --> x327126533d1727a8(["objective_function_RB"]):::outdated
    x690aaa23c060b0c7(["training_subset_RB"]):::outdated --> x327126533d1727a8(["objective_function_RB"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x327126533d1727a8(["objective_function_RB"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x6f9ba2de4424f672(["objective_function_SC"]):::outdated
    x9dd12e61daa5c580(["training_subset_SC"]):::outdated --> x6f9ba2de4424f672(["objective_function_SC"]):::outdated
    x60268332a490103c(["factor_structure_SC"]):::outdated --> x6f9ba2de4424f672(["objective_function_SC"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x6b5d9814e33af17c(["objective_function_SP"]):::outdated
    x51555ce6802c0fe2(["factor_structure_SP"]):::outdated --> x6b5d9814e33af17c(["objective_function_SP"]):::outdated
    x2f73011017deaa39(["training_subset_SP"]):::outdated --> x6b5d9814e33af17c(["objective_function_SP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> xdee1355dfa6ce4e0(["objective_function_TP"]):::outdated
    xef5410a5dce77230(["training_subset_TP"]):::outdated --> xdee1355dfa6ce4e0(["objective_function_TP"]):::outdated
    x33428c0b51cdbdd6(["factor_structure_TP"]):::outdated --> xdee1355dfa6ce4e0(["objective_function_TP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x992a1413d784592d(["objective_function_WD"]):::outdated
    x64aa35d356121bcb(["factor_structure_WD"]):::outdated --> x992a1413d784592d(["objective_function_WD"]):::outdated
    xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated --> x992a1413d784592d(["objective_function_WD"]):::outdated
    x10097a3b003b2629(["raw_sav_files_files"]):::outdated --> xc482bb1c34568587["raw_sav_files"]:::outdated
    xf60d83bc019bc9d7(["training_subset_AB"]):::outdated --> xe856b436cf3cfb22(["subtest_solution_AB"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> xe856b436cf3cfb22(["subtest_solution_AB"]):::outdated
    x0567e39a7d6d538c(["objective_function_AB"]):::outdated --> xe856b436cf3cfb22(["subtest_solution_AB"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x909db895243e1d0d(["subtest_solution_AD"]):::outdated
    x3473628798949931(["training_subset_AD"]):::outdated --> x909db895243e1d0d(["subtest_solution_AD"]):::outdated
    x47db7a93f9283c6c(["objective_function_AD"]):::outdated --> x909db895243e1d0d(["subtest_solution_AD"]):::outdated
    x75373129f6a80bd4(["objective_function_AP"]):::outdated --> x5a4e45af0a265848(["subtest_solution_AP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x5a4e45af0a265848(["subtest_solution_AP"]):::outdated
    x4ba6a6489e391b5d(["training_subset_AP"]):::outdated --> x5a4e45af0a265848(["subtest_solution_AP"]):::outdated
    x690aaa23c060b0c7(["training_subset_RB"]):::outdated --> x192c366c8090576c(["subtest_solution_RB"]):::outdated
    x327126533d1727a8(["objective_function_RB"]):::outdated --> x192c366c8090576c(["subtest_solution_RB"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x192c366c8090576c(["subtest_solution_RB"]):::outdated
    x6f9ba2de4424f672(["objective_function_SC"]):::outdated --> x7dfb795400228424(["subtest_solution_SC"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x7dfb795400228424(["subtest_solution_SC"]):::outdated
    x9dd12e61daa5c580(["training_subset_SC"]):::outdated --> x7dfb795400228424(["subtest_solution_SC"]):::outdated
    x2f73011017deaa39(["training_subset_SP"]):::outdated --> x7d376e0bdc71c3ad(["subtest_solution_SP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x7d376e0bdc71c3ad(["subtest_solution_SP"]):::outdated
    x6b5d9814e33af17c(["objective_function_SP"]):::outdated --> x7d376e0bdc71c3ad(["subtest_solution_SP"]):::outdated
    xdee1355dfa6ce4e0(["objective_function_TP"]):::outdated --> x3920d41becff1b97(["subtest_solution_TP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x3920d41becff1b97(["subtest_solution_TP"]):::outdated
    xef5410a5dce77230(["training_subset_TP"]):::outdated --> x3920d41becff1b97(["subtest_solution_TP"]):::outdated
    x58fcef4313ecfd8f(["model_parameters"]):::uptodate --> x3b6f30bf8f0dce31(["subtest_solution_WD"]):::outdated
    xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated --> x3b6f30bf8f0dce31(["subtest_solution_WD"]):::outdated
    x992a1413d784592d(["objective_function_WD"]):::outdated --> x3b6f30bf8f0dce31(["subtest_solution_WD"]):::outdated
    xdcc831f22b0ea9b0(["data_split"]):::outdated --> xdf3a23b84b5d733e(["testing_data"]):::outdated
    xdcc831f22b0ea9b0(["data_split"]):::outdated --> x3fac2193a6071940(["training_data"]):::outdated
    x7231b392ed9b3488(["fixed_item_assignment"]):::outdated --> xf60d83bc019bc9d7(["training_subset_AB"]):::outdated
    x3fac2193a6071940(["training_data"]):::outdated --> xf60d83bc019bc9d7(["training_subset_AB"]):::outdated
    x7231b392ed9b3488(["fixed_item_assignment"]):::outdated --> x3473628798949931(["training_subset_AD"]):::outdated
    x3fac2193a6071940(["training_data"]):::outdated --> x3473628798949931(["training_subset_AD"]):::outdated
    x3fac2193a6071940(["training_data"]):::outdated --> x4ba6a6489e391b5d(["training_subset_AP"]):::outdated
    x7231b392ed9b3488(["fixed_item_assignment"]):::outdated --> x4ba6a6489e391b5d(["training_subset_AP"]):::outdated
    x3fac2193a6071940(["training_data"]):::outdated --> x690aaa23c060b0c7(["training_subset_RB"]):::outdated
    x7231b392ed9b3488(["fixed_item_assignment"]):::outdated --> x690aaa23c060b0c7(["training_subset_RB"]):::outdated
    x7231b392ed9b3488(["fixed_item_assignment"]):::outdated --> x9dd12e61daa5c580(["training_subset_SC"]):::outdated
    x3fac2193a6071940(["training_data"]):::outdated --> x9dd12e61daa5c580(["training_subset_SC"]):::outdated
    x7231b392ed9b3488(["fixed_item_assignment"]):::outdated --> x2f73011017deaa39(["training_subset_SP"]):::outdated
    x3fac2193a6071940(["training_data"]):::outdated --> x2f73011017deaa39(["training_subset_SP"]):::outdated
    x3fac2193a6071940(["training_data"]):::outdated --> xef5410a5dce77230(["training_subset_TP"]):::outdated
    x7231b392ed9b3488(["fixed_item_assignment"]):::outdated --> xef5410a5dce77230(["training_subset_TP"]):::outdated
    x3fac2193a6071940(["training_data"]):::outdated --> xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated
    x7231b392ed9b3488(["fixed_item_assignment"]):::outdated --> xecb8f0f67e98a6e5(["training_subset_WD"]):::outdated
    x19901066f05e46bf(["data_safechild"]):::outdated --> x717e14c46dfd703a(["variable_dictionary"]):::outdated
    
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
```
