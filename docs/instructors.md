---
title: Instructor's Notes for Pumas-AI Workshop PLACEHOLDER
---

[![CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-sa/4.0/)

Start with the `01-covariate.jl` file.
In this file you'll guide learners on how to build covariate models.
Start with the `DataFrame` of the `nlme_sample` dataset from `PharmaDatasets`.
You'll see that this dataset has the standard PK dataset columns such as `:ID`, `:TIME`, `:DV`, `:AMT`, `:EVID` and `:CMT`.
Spend some time to remind learners about these NM-TRAN standard columns,
as well how to pass them as values to the keyword arguments of the `read_pumas` function.
The dataset also contains the following list of **covariates**:

- `:WT`: subject weight in kilograms
- `:SEX`: subject sex, either `"F"` or `"M"`
- `:CRCL`: subject creatinine clearance
- `:GROUP`: subject dosing group, either `"500 mg"`, `"750 mg"`, or `"1000 mg"`

If your audience is data-centric and time allowing,
you can spend some time doing some data exploratory analysis.
If you do, don't forget to load the `DataFrames`/`DataFramesMeta` package(s).
The first step in our covariate model building workflow is to **parse data into a `Population`**.
This is accomplished with the `read_pumas` function.
Here we are to use the `covariates` keyword argument to pass a vector of column names to be parsed as covariates.
The second step of our covariate model building workflow is to develop a **base model**, i.e., a model without any covariate effects on its parameters.
This represents the _null_ model against which covariate models can be tested after checking if covariate inclusion is helpful in our model.
The third step of our covariate model building workflow is to actually develop one or more **covariate models**.
Let's develop two covariate models:

1. allometric scaling based on weight
1. clearance effect based on creatinine clearance

To include covariates in a Pumas model we need to first include them in the `@covariates` block.
Then, we are free to use them inside the `@pre` block
As you showcase the base and covariates models highlight the differences amongst them.
Take note that the second covariate model needs a different set of initial parameters estimates due to having extra parameters.
For the first covariate model, the one that does allometric scaling based on weight,
once we included the `WT` covariate in the `@covariates` block we can use the `WT` values inside the `@pre` block.
For both clearance (`CL`) and volume of the central compartment (`Vc`),
we are allometric scaling by the `WT` value by the mean weight `70` and,
in the case of `CL` using an allometric exponent with value `0.75`.
For the second covariate model, the `covariate_model_wt_crcl` model, we are keeping our allometric scaling on `WT` from before.
But we are also adding a new covariate creatinine clearance (`CRCL`),
dividing clearance (`CL`) into hepatic (`hepCL`) and renal clearance (`renCL`),
along with a new parameter `dCRCL`.
`dCRCL` is the exponent of the power function for the effect of creatinine clearance on renal clearance.
In some models this parameter is fixed, however we'll allow the model to estimate it.
This is a good example on how to add covariate coefficients such as `dCRCL` in any Pumas covariate model.
Note that we need a new initial parameters values' list since the previous one we used doesn't include `dCRCL`, `tvcl_hep` or `tvcl_ren`.
Now that we've fitted all of our models we need to compare them and **choose one for our final model**.
We begin by analyzing the model metrics.
Highlight the AIC values between the models, prefer the lowest value.
Additionally, we should inspect the goodness of fit of the model.
This is done with the plotting function `goodness_of_fit`,
which should be given a result from a `inspect` function.
Go over the plots comparing the three models.
Finally, we also perform VPCs to help the model comparisson task.

Now, proceed to the dose control parameters (DCP) workflow with the `02-dose_control.jl`.
Here the idea is to showcase the new `@dosecontrol` block.
Explain that this block allows for four special variables:

- `lags`: the lag of the dose
- `bioav`: the bioavailability of the dose
- `duration`: the duration of the dose
- `rate`: the rate of the dose

These are specified with the syntax `dcp = (; Cmt=value)` where:

- `dcp`: the dose control parameter (`lags`, `bioav`, `duration` or `rate`)
- `Cmt`: the compartment where the DCP will be applied
- `value`: value to use the for the DCP

Here you will have three models to show learners.
First, the `lags` model will have the `lags` as a DCP in the `@dosecontrol` block.
Here you will explain how the learners can add compartments to which the `lags` will have an effect,
and which value it will take.
This is done with a `NamedTuple`.
Second, the `bioav` model has a different DCP, `bioav`, but the logic is the same.
Finally, the `lags_bioav` has two DCPs, `lags` and `bioav`.
Here the idea is to showcase that you can not only have multiple compartments but also multiple DCPs.
Be careful with random-effects (η) on the DCPs since those can include discontinuities in the objective function,
and may give unstable estimates during the fitting procedure.

## Get in touch

If you have any suggestions or want to get in touch with our education team,
please send an email to <training@pumas.ai>.

## License

This content is licensed under [Creative Commons Attribution-ShareAlike 4.0 International](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
