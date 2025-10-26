

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
    xeb2d7cac8a1ce544>"Function"]:::none
    xd03d7c7dd2ddda2b(["Regular target"]):::none
    x6f7e04ea3427f824["Dynamic branches"]:::none
  end
  subgraph Graph
    direction LR
    xf79721e0f5e33594>"make_obj_fn"]:::uptodate --> xd20899a452aea33a>"build_obj"]:::uptodate
    xc4d18a019ca90843>"get_empirical"]:::uptodate --> xd20899a452aea33a>"build_obj"]:::uptodate
    xdd09909d76aac889>"make_mats"]:::uptodate --> xd20899a452aea33a>"build_obj"]:::uptodate
    xa59b086f8c0dd786>"make_fixed"]:::uptodate --> xd20899a452aea33a>"build_obj"]:::uptodate
    x50dee087cea480d6>"spearman_brown"]:::uptodate --> xeafdb142e30e0f1e>"create_cutoff"]:::uptodate
    x80190a1ecd7fc8cd>"create_aseba"]:::uptodate --> x647af5ca2a750e19(["data_aseba"]):::outdated
    x53cf5ba2a7a40912(["data_safe"]):::outdated --> x647af5ca2a750e19(["data_aseba"]):::outdated
    x474e7b3612aa05fe(["dropout"]):::outdated --> x647af5ca2a750e19(["data_aseba"]):::outdated
    xdb4e59bc3d0ac3b3(["agr_file"]):::uptodate --> xe078f1fb87a5f306(["data_cutoff"]):::uptodate
    x6e3a455736075628(["rel_file"]):::uptodate --> xe078f1fb87a5f306(["data_cutoff"]):::uptodate
    xeafdb142e30e0f1e>"create_cutoff"]:::uptodate --> xe078f1fb87a5f306(["data_cutoff"]):::uptodate
    x1e2f6b892b676f51["sav_files"]:::outdated --> x53cf5ba2a7a40912(["data_safe"]):::outdated
    xa40ba6aba0ec489c>"create_safechild"]:::uptodate --> x53cf5ba2a7a40912(["data_safe"]):::outdated
    x53cf5ba2a7a40912(["data_safe"]):::outdated --> x3ed5bb9884f4eeb7(["dict"]):::outdated
    xadb06c49920217cf>"create_dictionary"]:::uptodate --> x3ed5bb9884f4eeb7(["dict"]):::outdated
    x5a6d57d7231da317>"handle_attrition"]:::uptodate --> x474e7b3612aa05fe(["dropout"]):::outdated
    x53cf5ba2a7a40912(["data_safe"]):::outdated --> x474e7b3612aa05fe(["dropout"]):::outdated
    x9b27dfb35d384d60>"top_frac"]:::uptodate --> xc4d18a019ca90843>"get_empirical"]:::uptodate
    x636fade0f61375ee>"get_m_sd"]:::uptodate --> xc4d18a019ca90843>"get_empirical"]:::uptodate
    x06c0f8476667fd3f(["meta_ysr"]):::uptodate --> x6a90fc6145ebf215(["item_assignment"]):::uptodate
    xdd70d048569563e8>"create_item_assignment"]:::uptodate --> x6a90fc6145ebf215(["item_assignment"]):::uptodate
    xa7c0e709c76a0ac5(["meta_cbcl"]):::uptodate --> x6a90fc6145ebf215(["item_assignment"]):::uptodate
    x6a90fc6145ebf215(["item_assignment"]):::uptodate --> x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated
    x8d4cf3dd7520449b>"fix_item_assignment"]:::uptodate --> x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated
    x0c307f7e4efbd259(["missing_items"]):::outdated --> x4bfa2536b5912c35(["item_assignment_fixed"]):::outdated
    x5d64aea7dea2f65d>"combine_crit"]:::uptodate --> xf79721e0f5e33594>"make_obj_fn"]:::uptodate
    xbcbbd35f337db770>"make_crit"]:::uptodate --> xf79721e0f5e33594>"make_obj_fn"]:::uptodate
    xe273b2a40886dfdb>"read_meta_aseba"]:::uptodate --> xa7c0e709c76a0ac5(["meta_cbcl"]):::uptodate
    xd9e5ec19b55a4a31(["file_meta_aseba"]):::uptodate --> xa7c0e709c76a0ac5(["meta_cbcl"]):::uptodate
    xe273b2a40886dfdb>"read_meta_aseba"]:::uptodate --> x06c0f8476667fd3f(["meta_ysr"]):::uptodate
    xd9e5ec19b55a4a31(["file_meta_aseba"]):::uptodate --> x06c0f8476667fd3f(["meta_ysr"]):::uptodate
    xec06d6d77dd97950>"check_item_assignment"]:::uptodate --> x0c307f7e4efbd259(["missing_items"]):::outdated
    x71630008d1c0fd02(["training_set"]):::outdated --> x0c307f7e4efbd259(["missing_items"]):::outdated
    x6a90fc6145ebf215(["item_assignment"]):::uptodate --> x0c307f7e4efbd259(["missing_items"]):::outdated
    x7849ff489c55a199(["sav_files_files"]):::outdated --> x1e2f6b892b676f51["sav_files"]:::outdated
    x647af5ca2a750e19(["data_aseba"]):::outdated --> xe28e6a915fe1f815(["split_list"]):::outdated
    x11c22b6039cb940b>"split_data"]:::uptodate --> xe28e6a915fe1f815(["split_list"]):::outdated
    x331f289e36e062ff>"extract_datasets"]:::uptodate --> xa673c03795543c98(["test_set"]):::outdated
    xe28e6a915fe1f815(["split_list"]):::outdated --> xa673c03795543c98(["test_set"]):::outdated
    xe28e6a915fe1f815(["split_list"]):::outdated --> x71630008d1c0fd02(["training_set"]):::outdated
    x331f289e36e062ff>"extract_datasets"]:::uptodate --> x71630008d1c0fd02(["training_set"]):::outdated
    x4c122faa1e23fe53>"get_dfi"]:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
```
