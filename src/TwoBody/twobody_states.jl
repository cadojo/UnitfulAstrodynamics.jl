#
#   TwoBodyStates.jl
#
#   Describes Two Body Orbits through Cartesian coordinates and Orbital Elements.
# 

"""
Abstract type for all four conic sections.
"""
abstract type AbstractConic end


"""
Abstract type for all two-body orbital representations.
"""
abstract type TwoBodySystem{C<:AbstractConic} <: OrbitalSystem end


"""
Type for orbits in the circular conic section.
"""
struct Circular <: AbstractConic end

"""
Type for orbits in the elliptical conic section.
"""
struct Elliptical <: AbstractConic end

"""
Type for orbits in the parabolic conic section.
"""
struct Parabolic <: AbstractConic end

"""
Type for orbits in the hyperbolic conic section.
"""
struct Hyperbolic <: AbstractConic end

"""
Type for invalid orbits (orbits with NaN fields)
"""
struct Invalid <: AbstractConic end

"""
Type representing large bodies in space. Currently, the following
solar system bodies are supported:

Sun, Mercury, Venus, Earth, Moon (Luna), Mars, Jupiter, 
Saturn, Uranus, Neptune, Pluto.
"""
struct CelestialBody{F<:AbstractFloat}

    R::Length{F}
    μ::MassParameter{F}

    CelestialBody(m::Mass{T}, R::Length{T}) where T<:AbstractFloat = new{T}(R, T(G * m))
    CelestialBody(R::Length{T}, μ::MassParameter{T}) where T<:AbstractFloat = new{T}(R, μ)

    CelestialBody(m::Mass, R::Length) = new{Float64}(Float64(m), Float64(R), Float64(G * m))
    CelestialBody(R::Length, μ::MassParameter) = new{Float64}(Float64(R), Float64(μ))

end
Base.convert(::Type{T}, b::CelestialBody) where {
        T<:AbstractFloat} = CelestialBody(T(b.R), T(b.μ))
Base.promote(::Type{CelestialBody{A}}, ::Type{CelestialBody{B}}) where {
        A<:AbstractFloat, B<:AbstractFloat} = CelestialBody{promote_type(A,B)}

"""
Custom display for `CelestialBody` instances.
"""
function Base.show(io::IO, body::CelestialBody)

    println(io, crayon"blue", "CelestialBody:")
    println(io, crayon"default", 
                "    Mass:           ", ustrip(u"kg", body.μ / G), " ", u"kg")
    println(io, "    Radius:         ", ustrip(u"km", body.R), " ", u"km")
    println(io, "    Mass Parameter: ", ustrip(u"km^3/s^2", body.μ), " ", u"km^3/s^2")

end

"""
Struct for storing TwoBody orbital states for all conics.
"""
struct Orbit{
            C  <: AbstractConic,
            F  <: AbstractFloat
        } <: TwoBodySystem{C}

    # Cartesian representation
    rᵢ::SVector{3, Length{F}}
    vᵢ::SVector{3, Velocity{F}}

    # Perifocal (in-orbital-plane) representation
    rₚ::SVector{3, Length{F}}
    vₚ::SVector{3, Velocity{F}}

    # Keplerian representation
    e::F
    a::Length{F}
    i::DimensionlessQuantity{F}
    Ω::DimensionlessQuantity{F}
    ω::DimensionlessQuantity{F}
    ν::DimensionlessQuantity{F}

    # Body
    body::CelestialBody

end
Base.convert(::Type{T}, o::Orbit) where {
        T<:AbstractFloat} = Orbit(T.(o.rᵢ), T.(o.vᵢ), T(o.body))
Base.promote(::Type{Orbit{E,A}}, ::Type{Orbit{E,B}}) where {
        E, A<:AbstractFloat, B<:AbstractFloat} = Orbit{E, promote_type(A,B)}

"""
Custom display for Orbit instances.
"""
function Base.show(io::IO, orbit::Orbit)

    println(io, crayon"green", conic(orbit), " Two Body Orbit:")
    println(io, crayon"default", "")

    println(io, "    Position (inertial):    [", 
                ustrip(u"km", orbit.rᵢ[1]), ", ", 
                ustrip(u"km", orbit.rᵢ[2]), ", ", 
                ustrip(u"km", orbit.rᵢ[3]), "] ", u"km")
    println(io, "    Velocity (inertial):    [", 
                ustrip(u"km/s", orbit.vᵢ[1]), ", ", 
                ustrip(u"km/s", orbit.vᵢ[2]), ", ", 
                ustrip(u"km/s", orbit.vᵢ[3]), "] ", u"km/s")

    println(io, "")
    println(io, "    Position (perifocal):   [", 
                round(ustrip(u"km", orbit.rₚ[1]), digits=6), ", ", 
                round(ustrip(u"km", orbit.rₚ[2]), digits=6), ", ", 
                round(ustrip(u"km", orbit.rₚ[3]), digits=6), "] ", u"km/s")
    println(io, "    Velocity (perifocal):   [", 
                round(ustrip(u"km/s", orbit.vₚ[1]), digits=6), ", ", 
                round(ustrip(u"km/s", orbit.vₚ[2]), digits=6), ", ", 
                round(ustrip(u"km/s", orbit.vₚ[3]), digits=6), "] ", u"km/s") 
    
    println(io, "")
    println(io, "    Eccentricity:           ", 
                orbit.e)    
    println(io, "    Semimajor Axis:         ", 
                ustrip(u"km", orbit.a), " ", u"km")
    println(io, "    Inclination:            ", 
                ustrip(u"°", orbit.i), u"°")
    println(io, "    RAAN:                   ", 
                ustrip(u"°", orbit.Ω), u"°")
    println(io, "    Arg. Periapsis:         ", 
                ustrip(u"°", orbit.ω), u"°")
    println(io, "    True Anomoly:           ", 
                ustrip(u"°", orbit.ν), u"°")

    println(io, "")
    println(io, "    Body (μ):               ",
                ustrip(u"km^3 / s^2", orbit.body.μ), " ", u"km^3/s^2")
end

"""
Returns a `Orbit` with `NaN` state values. Used by 
`propagate_twobody` and `kepler` to indicate failed convergance.
"""
InvalidOrbit(body::CelestialBody) = Orbit(
    SVector{3}(NaN * u"km", NaN * u"km", NaN * u"km"),
    SVector{3}(NaN * u"km/s", NaN * u"km/s", NaN * u"km/s"),
    NaN * u"km", NaN * u"km/s", body)

"""
Checks for `NaN` valued orbital states, which are used to
indicate an invalid `Orbit`.
"""
isinvalid(orbit::Orbit) = all(map(x->!isnan(getfield(orbit, x)), [:rᵢ, :vᵢ, :e, :a, :i, :Ω, :ω, :ν])) 

# Constants

# All data pulled from the following references:
# [1] https://en.wikipedia.org/wiki/List_of_Solar_System_objects_by_size
# [2] https://docs.astropy.org/en/stable/constants/#module-astropy.constants

"""
Constant `CelestialBody` for our sun!
"""
const Sun = CelestialBody(1.98840987e30u"kg", 696342.0u"km")

"""
Constant `CelestialBody` for Mercury.
"""
const Mercury = CelestialBody(330.1e21u"kg", 2439.7u"km")

"""
Constant `CelestialBody` for Venus.
"""
const Venus = CelestialBody(4867.5e21u"kg", 6051.8u"km")

"""
Constant `CelestialBody` for your home planet!
"""
const Earth = CelestialBody(5.97216787e24u"kg", 6371.0u"km")

"""
Constant `CelestialBody` for our moon.
"""
const Moon = CelestialBody(73.42e21u"kg", 1737.4u"km")

"""
Constant `CelestialBody` (alias for our mooon).
"""
const Luna = Moon

"""
Constant `CelestialBody` for Mars.
"""
const Mars = CelestialBody(641.7e21u"kg", 3389.5u"km")

"""
Constant `CelestialBody` for Jupiter.
"""
const Jupiter = CelestialBody(1.8981246e27u"kg", 69911.0u"km")

"""
Constant `CelestialBody` for Saturn.
"""
const Saturn = CelestialBody(568340e21u"kg", 58232.0u"km")

"""
Constant `CelestialBody` for Uranus.
"""
const Uranus = CelestialBody(86813e21u"kg", 25362.0u"km")

"""
Constant `CelestialBody` for Neptune.
"""
const Neptune = CelestialBody(102413e21u"kg", 24622.0u"km")

"""
Constant `CelestialBody` for Pluto. We couldn't leave you out again!
"""
const Pluto = CelestialBody(13.03e21u"kg", 1188.3u"km")
    