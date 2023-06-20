---
title: Reference Sheets for Pumas-AI NLME Covariates, Dose Control Parameters, and PKPD Indirect Response Models Workshop
---

[![CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-sa/4.0/)

## Key Points

- You can parse covariates while reading a `DataFrame` with the `covariates` keyword argument in `read_pumas`.
- Covariates can be included in a Pumas model with the `@covariates` block and used throughtout.
- Dose control parameters can be defined in the `@dosecontro` in a Pumas model.
- Indirect response models, and other PKPD models, can be defined in one joint Pumas model using the model blocks for both PK and PD components.
- You can set the subjects' initial compartment values with the `@init` model block.
- The `@vars` model block allows you to define aliases that can help decluttering your ODEs in the `@dynamics` block.

## Summary of Basic Commands

| Action      | Command       | Observations          |
| ----------- | ------------- | --------------------- |
| Parse data with covariates into a `Population` | `read_pumas(pkdata; covariates=[:covar1, :covar2, ...])` | `covariates` is a vector of column names where covariate data is stored in the `pkdata` `DataFrame` |
| Add covariates to a model | `@covariates covar1 covar2 ...` | The `@covariates` block should be used inside a model. Also note that the matching `Population` used in the `fit` with the desired model should also have the same covariates available |
| Add a dose control parameter to a model | `@dosecontrol begin dcp = (; Cmt=value) end` | The `@dosecontrol` block should be used inside a model. `dcp` is a dose control parameter (`lags`, `bioav`, `rate` or `duration`) and `Cmt` is the compartment name where the DCP effect should be applied and `value` is the value of the effect. You can have multiples `Cmt`s and also multiples `dcp`s. |
| Parse data with multiple observations into a `Population` | `read_pumas(pkdata; observations=[:obs1, :obs2, ...])` | `observations` is a vector of column names where observation data is stored in the `pkdata` `DataFrame` |
| Define initial values for compartments in a model | `@init begin Cmt = value end` | The compartment always has an initial value of 0 or the dosing event at time 0 if not specified with `@init` | 
| Define aliases for the `@dynamics` and `@derived` block | `@vars begin alias = value end` | These are used mainly to declutter your ODEs in the `@dynamics` block | 

## Glossary

Covariate

: Any characteristic or feature that can impact the response to a drug. These could include demographic factors (like age, sex, or weight), disease characteristics (like disease stage or presence of other health conditions), genetic factors, or lab values (like liver function tests or kidney function tests).

Creatinine clearance

: Creatinine clearance is a measure used to assess the functioning of the kidneys. Specifically, it provides an estimate of the glomerular filtration rate (GFR), which is the rate at which the kidneys filter waste from the blood.

Base model

: A model without any covariate effects on its parameters. This represents the _null_ model against which covariate models can be tested after checking if covariate inclusion is helpful in our model.

Allometric scaling

: Allometric scaling is a method used to adjust pharmacokinetic parameters, such as clearance and volume of distribution, based on body size and composition.

Dose control parameters (DCP)

: Parameters used to optimize and control the dose of a drug in a pharmacokinetic (PK) or pharmacodynamic (PD) model. These parameters can include lag, bioavaliability, rate and duration.

Lag of the dose

: The time delay between drug administration and the commencement of its absorption into the systemic circulation.

Bioavailability of the dose

: The fraction of an administered dose of a drug that reaches the systemic circulation in its unchanged or active form. 

Rate of the dose

: The rate of the drug absorption.

Duration of the dose

: Length of time that drug concentrations remain within the therapeutic range after a dose is administered.

Indirect response model (IDR)

: Type of pharmacodynamic model used to describe situations where a drug's effect occurs through a mechanism separate from the drug's direct action on a biological target. In other words, the drug doesn't act directly on the response, but influences it indirectly, often by modulating a rate of production or loss of the measured response. These models are often used when there is a delay between drug concentration and observable effect, or when the drug effect is believed to act through some intermediary process.

## Get in touch

If you have any suggestions or want to get in touch with our education team,
please send an email to <training@pumas.ai>.

## License

This content is licensed under [Creative Commons Attribution-ShareAlike 4.0 International](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
