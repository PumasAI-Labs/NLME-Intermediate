using Pumas
using PumasUtilities
using PharmaDatasets

# As you can see, the `nlme_sample` dataset has the standard PK dataset columns such as
# `:ID`, `:TIME`, `:DV`, `:AMT`, `:EVID` and `:CMT`.
pkdata = dataset("nlme_sample")
# We have some interesting covariates in this dataset:
# - `:WT`: subject weight in kilograms
# - `:SEX`: subject sex, either `"F"` or `"M"`
# - `:CRCL`: subject creatinine clearance
# - `:GROUP`: subject dosing group, either `"500 mg"`, `"750 mg"`, or `"1000 mg"`

# You can add covariates to a `Population` with the `covariates` keyword argument in `read_pumas`
pop = read_pumas(
  pkdata;
  id = :ID,
  time = :TIME,
  amt = :AMT,
  covariates = [:WT, :AGE, :SEX, :CRCL, :GROUP],
  observations = [:DV],
  cmt = :CMT,
  evid = :EVID,
  rate = :RATE,
)

# First model is the base model, i.e. no covariates
base_model = @model begin
  @param begin
    tvcl ∈ RealDomain(; lower = 0)
    tvvc ∈ RealDomain(; lower = 0)
    tvq ∈ RealDomain(; lower = 0)
    tvvp ∈ RealDomain(; lower = 0)
    Ω ∈ PDiagDomain(2)
    σ_add ∈ RealDomain(; lower = 0)
    σ_prop ∈ RealDomain(; lower = 0)
  end

  @random begin
    η ~ MvNormal(Ω)
  end

  @covariates WT AGE SEX CRCL GROUP

  @pre begin
    CL = tvcl * exp(η[1])
    Vc = tvvc * exp(η[2])
    Q = tvq
    Vp = tvvp
  end

  @dynamics Central1Periph1

  @derived begin
    cp := @. Central / Vc
    DV ~ @. Normal(cp, sqrt(cp^2 * σ_prop + σ_add^2)) # combined error
  end
end

# Define the initial parameter estimates
iparams_base_model = (;
  tvvc = 5,
  tvcl = 0.02,
  tvq = 0.01,
  tvvp = 10,
  Ω = Diagonal([0.01, 0.01]),
  σ_add = 0.1,
  σ_prop = 0.1,
)

# Fit the base model
fit_base_model = fit(base_model, pop, iparams_base_model, FOCE())

# Now we define our first covariate model using `WT`
# with the purpose of allometric scaling based on weight
covariate_model_wt = @model begin
  @param begin
    tvcl ∈ RealDomain(; lower = 0)
    tvvc ∈ RealDomain(; lower = 0)
    tvq ∈ RealDomain(; lower = 0)
    tvvp ∈ RealDomain(; lower = 0)
    Ω ∈ PDiagDomain(2)
    σ_add ∈ RealDomain(; lower = 0)
    σ_prop ∈ RealDomain(; lower = 0)
  end

  @random begin
    η ~ MvNormal(Ω)
  end

  @covariates begin
    WT
  end

  @pre begin
    # here is the allometric scaling on `CL` and `Vc`
    CL = tvcl * (WT / 70)^0.75 * exp(η[1])
    Vc = tvvc * (WT / 70) * exp(η[2])

    Q = tvq
    Vp = tvvp
  end

  @dynamics Central1Periph1

  @derived begin
    cp := @. Central / Vc
    DV ~ @. Normal(cp, sqrt(cp^2 * σ_prop^2 + σ_add^2))
  end
end

# Since we haven't added parameters we can fit the covariate model
# with the same initial parameters estimates used in the base model
fit_covariate_model_wt = fit(covariate_model_wt, pop, iparams_base_model, FOCE())

# Now let's build a new covariate model using `CRCL`
# Here we'll distinguish the creatinine clearance effects
# into hepatic and renal clearance
covariate_model_wt_crcl = @model begin
  @param begin
    tvvc ∈ RealDomain(; lower = 0)
    tvq ∈ RealDomain(; lower = 0)
    tvvp ∈ RealDomain(; lower = 0)
    tvcl_hep ∈ RealDomain(; lower = 0) # hepatic clearance
    tvcl_ren ∈ RealDomain(; lower = 0) # renal clearance
    Ω ∈ PDiagDomain(2)
    σ_add ∈ RealDomain(; lower = 0)
    σ_prop ∈ RealDomain(; lower = 0)
    dCRCL ∈ RealDomain() # exponent of the power function
  end

  @random begin
    η ~ MvNormal(Ω)
  end

  @covariates begin
    WT
    CRCL
  end

  @pre begin
    hepCL = tvcl_hep * (WT / 70)^0.75 # hepatic clearance
    renCL = tvcl_ren * (CRCL / 100)^dCRCL # renal clearance
    CL = (hepCL + renCL) * exp(η[1]) # total clearance
    Vc = tvvc * (WT / 70) * exp(η[2])
    Q = tvq
    Vp = tvvp
  end

  @dynamics Central1Periph1

  @derived begin
    cp := @. Central / Vc
    DV ~ @. Normal(cp, sqrt(cp^2 * σ_prop^2 + σ_add^2))
  end
end

# Since we added new parameters, we need a new
# set of initial parameters estimates
iparams_covariate_model_wt_crcl = (;
  tvvc = 5,
  tvcl_hep = 0.01,
  tvcl_ren = 0.01,
  tvq = 0.01,
  tvvp = 10,
  Ω = Diagonal([0.01, 0.01]),
  σ_add = 0.1,
  σ_prop = 0.1,
  dCRCL = 0.9,
)

fit_covariate_model_wt_crcl =
  fit(covariate_model_wt_crcl, pop, iparams_covariate_model_wt_crcl, FOCE())

# We can check their AICs
aic(fit_base_model)
aic(fit_covariate_model_wt)
aic(fit_covariate_model_wt_crcl)

# And also plot goodness of fit
goodness_of_fit(inspect(fit_base_model))
goodness_of_fit(inspect(fit_covariate_model_wt))
goodness_of_fit(inspect(fit_covariate_model_wt_crcl))

# Finally we can do VPCs
vpc_plot(vpc(fit_base_model))
vpc_plot(vpc(fit_covariate_model_wt))
vpc_plot(vpc(fit_covariate_model_wt_crcl))
