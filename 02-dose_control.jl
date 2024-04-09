using Pumas
using PharmaDatasets

pkdata = dataset("po_sd_1")

pop = read_pumas(pkdata)

# Oral model with lags
lags = @model begin
    @param begin
        tvka ∈ RealDomain(; lower = 0)
        tvcl ∈ RealDomain(; lower = 0)
        tvvc ∈ RealDomain(; lower = 0)
        tvlag ∈ RealDomain(; lower = 0)
        Ω ∈ PDiagDomain(3)
        σ_prop ∈ RealDomain(; lower = 0)
    end

    @random begin
        η ~ MvNormal(Ω)
    end

    @pre begin
        Ka = tvka * exp(η[1])
        CL = tvcl * exp(η[2])
        Vc = tvvc * exp(η[3])
    end

    # This is a new model block
    # You can use any variables defined in:
    # @param, @covariate, or @pre 
    @dosecontrol begin
        # here are four specials variables (lags, bioav, duration, rate)
        # that can be used as DCPs
        # The syntax is `dcp = (; Cmt=value)`
        # Where `Cmt` is the compartment and the `value` is any calculation/value
        # that can use variables
        lags = (; Depot = tvlag)
    end

    @dynamics Depots1Central1

    @derived begin
        cp = @. Central / Vc
        dv ~ @. Normal(cp, cp * σ_prop)
    end
end

param_lags = (;
    tvka = 0.14,
    tvcl = 1,
    tvvc = 70,
    tvlag = 0.1,
    Ω = Diagonal([0.05, 0.05, 0.05]),
    σ_prop = 0.015,
)

fit_lags = fit(lags, pop, param_lags, FOCE())

# Bioavailability dosecontrol model
bioav = @model begin
    @param begin
        tvka ∈ RealDomain(lower = 0)
        tvcl ∈ RealDomain(lower = 0)
        tvvc ∈ RealDomain(lower = 0)
        tvbio ∈ RealDomain(lower = 0, upper = 1)
        Ω ∈ PDiagDomain(3)
        σ_prop ∈ RealDomain(lower = 0)
    end

    @random begin
        η ~ MvNormal(Ω)
    end

    @pre begin
        Ka = tvka * exp(η[1])
        CL = tvcl * exp(η[2])
        Vc = tvvc * exp(η[3])
    end

    @dosecontrol begin
        bioav = (; Depot = tvbio)
    end

    @dynamics Depots1Central1

    @derived begin
        cp = @. Central / Vc
        dv ~ @. Normal(cp, cp * σ_prop)
    end
end

param_bioav = (;
    tvka = 0.14,
    tvcl = 1,
    tvvc = 70,
    tvbio = 0.8,
    Ω = Diagonal([0.05, 0.05, 0.05]),
    σ_prop = 0.015,
)

fit_bioav = fit(bioav, pop, param_bioav, FOCE())

# Lags + Bioavailability dosecontrol model
lags_bioav = @model begin
    @param begin
        tvka ∈ RealDomain(lower = 0)
        tvcl ∈ RealDomain(lower = 0)
        tvvc ∈ RealDomain(lower = 0)
        tvlag ∈ RealDomain(; lower = 0)
        tvbio ∈ RealDomain(lower = 0, upper = 1)
        Ω ∈ PDiagDomain(3)
        σ_prop ∈ RealDomain(lower = 0)
    end

    @random begin
        η ~ MvNormal(Ω)
    end

    @pre begin
        Ka = tvka * exp(η[1])
        CL = tvcl * exp(η[2])
        Vc = tvvc * exp(η[3])
    end

    @dosecontrol begin
        # You can have more than one compartment and more than one DCP
        lags = (; Depot = tvlag)
        bioav = (; Depot = tvbio)
    end

    @dynamics Depots1Central1

    @derived begin
        cp = @. Central / Vc
        dv ~ @. Normal(cp, cp * σ_prop)
    end
end

param_lags_bioav = (;
    tvka = 0.14,
    tvcl = 1,
    tvvc = 70,
    tvlag = 0.1,
    tvbio = 0.8,
    Ω = Diagonal([0.05, 0.05, 0.05]),
    σ_prop = 0.015,
)

fit_lags_bioav = fit(lags_bioav, pop, param_lags_bioav, FOCE())
