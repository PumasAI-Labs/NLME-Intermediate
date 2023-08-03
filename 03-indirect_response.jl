using Pumas
using PumasUtilities
using PharmaDatasets
using DataFramesMeta

# This dataset has two DVs: `:dv` and `:resp`
# also one covariate `:BSL`
pkdata = dataset("inf_sd_5_idr")

# Since we have one PK and one PD observation
# and we want to do a sequential PD model,
# we need to have two `Populations` using
# the `read_pumas` function twice:
# one for eacn observation using the
# `observations` keyword argument
# PD pop is a little bit further below
pop_pk = read_pumas(
    pkdata;
    observations=[:dv],
)

# This is a PK model
pk_model = @model begin
    @param begin
        tvcl ∈ RealDomain(; lower=0)
        tvvc ∈ RealDomain(; lower=0)
        tvq ∈ RealDomain(; lower=0)
        tvvp ∈ RealDomain(; lower=0)
        Ω ∈ PDiagDomain(4)
        σ_prop ∈ RealDomain(; lower=0)
    end

    @random begin
        η ~ MvNormal(Ω)
    end

    @pre begin
        CL = tvcl * exp(η[1])
        Vc = tvvc * exp(η[2])
        Q = tvq * exp(η[3])
        Vp = tvvp * exp(η[4])
    end

    @dynamics begin
        Central' = -(CL / Vc) * Central + (Q / Vp) * Peripheral - (Q / Vc) * Central
        Peripheral' = (Q / Vc) * Central - (Q / Vp) * Peripheral
    end

    # Both PK and PD observations
    @derived begin
        conc := @. Central / Vc
        dv ~ @. Normal(conc, conc * σ_prop)
    end
end

# PK initial parameter values
iparams_pk = (
    tvcl=1.5,
    tvvc=25.0,
    tvq=5.0,
    tvvp=150.0,
    Ω=Diagonal([0.05, 0.05, 0.05, 0.05]),
    σ_prop=0.15,
)

# Now we fit the PK model
pk_fit = fit(pk_model, pop_pk, iparams_pk, FOCE())

# We need to extract the PK individual parameters
indpars = DataFrame(icoef(pk_fit))
# We don't need the column :time
@select! indpars $(Not(:time))
# A little bit of parsing for the :id column
@rtransform! indpars :id = parse(Int64, :id)
# Merge the PK individual parameters with the original dataset
leftjoin!(pkdata, indpars; on=:id)
# Some more data wrangling: renaming the PK columns
rename!(
  pkdata,
  :CL => :iCL,
  :Vc => :iVc,
  :Q => :iQ,
  :Vp => :iVp
)

# Now we can read the data into a
# PD Population with the
# PK individual parameters as covariates
pop_pd = read_pumas(
    pkdata;
    observations=[:resp],
    covariates=[:iCL, :iVc, :iQ, :iVp, :BSL]
)

# This is a sequential PD model
# We are using the PK individual parameters
# as covariates
pd_model = @model begin
    @param begin
        tvturn ∈ RealDomain(; lower=0)
        tvebase ∈ RealDomain(; lower=0)
        tvec50 ∈ RealDomain(; lower=0)
        Ω ∈ PDiagDomain(1)
        σ_add ∈ RealDomain(; lower=0)
    end

    @random begin
        η ~ MvNormal(Ω)
    end

    @covariates iCL iVc iQ iVp BSL

    @pre begin
        # PK individual parameters
        CL = iCL
        Vc = iVc
        Q  = iQ
        Vp = iVp

        # PD individual parameters
        ebase = tvebase * exp(η[1])
        ec50 = tvec50
        emax = 1
        turn = tvturn
        kout = 1 / turn
        kin0 = ebase * kout
    end

    # This is a new block
    # It has the purpose to define, for each subject,
    # the compartments initial values
    # These can be either a fixed value or a parameter-based value
    @init begin
        Resp = ebase
    end

    # This is a new block
    # It is used to define aliases for any operation based on parameters or values
    # to be used in the `@dynamics` and `@derived` blocks in order to avoid too much cluttering
    @vars begin
        conc := Central / Vc
        edrug := emax * conc / (ec50 + conc)
        kin := kin0 * (1 - edrug)
    end

    # Both PK and PD ODEs
    @dynamics begin
        Central' = -(CL / Vc) * Central + (Q / Vp) * Peripheral - (Q / Vc) * Central
        Peripheral' = (Q / Vc) * Central - (Q / Vp) * Peripheral
        Resp' = kin - kout * Resp
    end

    # Both PK and PD observations
    @derived begin
        resp ~ @. Normal(Resp, σ_add)
    end
end

# PD initial parameter values
iparams_pd = (
    tvturn=10,
    tvebase=10,
    tvec50=0.3,
    Ω=Diagonal([0.05]),
    σ_add=0.5,
)

pd_fit = fit(pd_model, pop_pd, iparams_pd, FOCE())

pkpd_inspect = inspect(pkpd_fit)

# Plotting a GoF for each type of observation separately
goodness_of_fit(pkpd_inspect; ols=false, observations=[:dv])
goodness_of_fit(pkpd_inspect; ols=false, observations=[:resp])
