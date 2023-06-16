---
title: Reference Sheets for Pumas-AI Workshop PLACEHOLDER
---

[![CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-sa/4.0/)

## Key Points

This can be either a markdown table or a list.

## Summary of Basic Commands

| Action      | Command       | Observations          |
| ----------- | ------------- | --------------------- |
| Parse data with covariates into a `Population` | `read_pumas(pkdatplaceholdera; covariates=[:covar1, :covar2, ...])` | `covariates` is a vector of column names where covariate data is stored in the `pkdata` `DataFrame` |

## Glossary

Covariate

: Any characteristic or feature that can impact the response to a drug. These could include demographic factors (like age, sex, or weight), disease characteristics (like disease stage or presence of other health conditions), genetic factors, or lab values (like liver function tests or kidney function tests).

Creatinine clearance

: Creatinine clearance is a measure used to assess the functioning of the kidneys. Specifically, it provides an estimate of the glomerular filtration rate (GFR), which is the rate at which the kidneys filter waste from the blood.

Base model

: A model without any covariate effects on its parameters. This represents the _null_ model against which covariate models can be tested after checking if covariate inclusion is helpful in our model.

Allometric scaling

: Allometric scaling is a method used to adjust pharmacokinetic parameters, such as clearance and volume of distribution, based on body size and composition.

## Get in touch

If you have any suggestions or want to get in touch with our education team,
please send an email to <training@pumas.ai>.

## License

This content is licensed under [Creative Commons Attribution-ShareAlike 4.0 International](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
