using Pumas
using PumasUtilities
using PharmaDatasets

# This dataset has two DVs: `:dv` and `:resp`
# also one covariate `:BSL`
pkdata = dataset("inf_sd_5_idr")

# Since we have one PK and one PD observation
# we need to pass it accordingly to the `read_pumas` function
# by using two column names in the `observations` keyword argument
pop = read_pumas(
    pkdata;
    observations=[:dv, :resp],
    covariates=[:BSL]
)

# This is a joint PKPD model
# we have:
# - PK parameters
# - PD parameters
# - PK Ω/η
# - PD Ω/η
# - PK compartments
# - PD compartments
# - PK observations
# - PD observations
model = @model begin
    @param begin
        # PK parameters
        tvcl ∈ RealDomain(; lower=0)
        tvvc ∈ RealDomain(; lower=0)
        tvq ∈ RealDomain(; lower=0)
        tvvp ∈ RealDomain(; lower=0)
        Ω_pk ∈ PDiagDomain(4)
        σ_prop_pk ∈ RealDomain(; lower=0)

        # PD parameters
        tvturn ∈ RealDomain(; lower=0)
        tvebase ∈ RealDomain(; lower=0)
        tvec50 ∈ RealDomain(; lower=0)
        Ω_pd ∈ PDiagDomain(1)
        σ_add_pd ∈ RealDomain(; lower=0)
    end

    @random begin
        ηpk ~ MvNormal(Ω_pk)
        ηpd ~ MvNormal(Ω_pd)
    end

    @covariates BSL

    @pre begin
        # PK part
        CL = tvcl * exp(ηpk[1])
        Vc = tvvc * exp(ηpk[2])
        Q = tvq * exp(ηpk[3])
        Vp = tvvp * exp(ηpk[4])

        # PD part
        ebase = tvebase * exp(ηpd[1])
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
        dv ~ @. Normal(conc, sqrt(conc^2 * σ_prop_pk))
        resp ~ @. Normal(Resp, sqrt(σ_add_pd))
    end
end

# Both PK and PD initial parameter values
iparams = (
    tvcl=1.5,
    tvvc=25.0,
    tvq=5.0,
    tvvp=150.0,
    tvturn=10,
    tvebase=10,
    tvec50=0.3,
    Ω_pk=Diagonal([0.05, 0.05, 0.05, 0.05]),
    Ω_pd=Diagonal([0.05]),
    σ_prop_pk=0.02,
    σ_add_pd=0.2,
)

pkpd_fit = fit(model, pop, iparams, FOCE())

pkpd_inspect = inspect(pkpd_fit)

# Plotting a GoF for each type of observation separately
goodness_of_fit(pkpd_inspect; ols=false, observations=[:dv])
goodness_of_fit(pkpd_inspect; ols=false, observations=[:resp])