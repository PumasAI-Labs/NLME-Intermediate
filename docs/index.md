---
title: Pumas-AI Workshop NLME Covariates, Dose Control Parameters, and PKPD Indirect Response Models Workshop
description: Template for Pumas-AI Workshop NLME Covariates, Dose Control Parameters, and PKPD Indirect Response Models Workshop.
---

[![CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-sa/4.0/)

This workshop is an intermediate-level NLME workshop in Pumas.
It covers:

- **Covariate Model Building**
- **Dose Control Parameters**:
  - `lags`: lag of the dose
  - `bioav`: bioavailability of the dose
  - `rate`: rate of the dosing
  - `duration`: duration of the dose
- **PKPD Indirect Response Models**

The following Julia files are provided:

1. `01-covariate.jl`: an overview on how to define covariate models
1. `02-dose_control.jl`: explains how to add dose control parameters to models
1. `03-indirect_response`: covers how to define indirect response models

!!! success "Prerequisites"

    We recommend users being familiar with the Pumas `@model` specification, how to parse data into a `Population`, and how to use the `fit` function.
    Additionally users need to know how to perform model assessment and how to compare models.

    The formal requirements are the [Pumas NLME Model Assessment Workshop](https://pumasai-labs.github.io/NLME-Assessment/).

## Schedule

| Time (HH:MM) | Activity | Description                              |
| ------------ | -------- | ---------------------------------------- |
| 00:00        | Setup    | Download files required for the workshop |
| 00:05        | Covariate Model Building    | Showcase `01-covariate.jl` |
| 00:20        | Dose Control Parameters    | Showcase `02-dose_control.jl` |
| 00:40        | Indirect Response Model    | Showcase `03-indirect_response.jl` |
| 00:55        | Closing Remarks            | See if there are any questions and feedback |

## Get in touch

If you have any suggestions or want to get in touch with our education team,
please send an email to <training@pumas.ai>.

## Authors

- Jose Storopoli - <jose@pumas.ai>

## License

This content is licensed under [Creative Commons Attribution-ShareAlike 4.0 International](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
