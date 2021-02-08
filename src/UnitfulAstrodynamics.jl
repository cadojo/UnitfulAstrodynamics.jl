"""
Julia package developed alongside ENAE601 at the University of Maryland.
Includes structures and functions to handle common Astrodynamics problems.
"""
module UnitfulAstrodynamics

# References:
# 
# I troubleshooted Julia's module scope/export rules for a while.
# Ultimately, I referenced [1] as an example for how to structure 
# submodules, and how to using `Reexport.jl` to export required
# package dependencies.
#
# [1] https://github.com/JuliaAstro/AstroBase.jl/blob/master/src/AstroBase.jl

using Reexport

include("CommonTypes/CommonTypes.jl")
include("TwoBody/TwoBody.jl")
include("ThreeBody/ThreeBody.jl")
include("NBody/NBody.jl")
include("Propagators/Propagators.jl")
include("Maneuvers/Maneuvers.jl")
include("AstroPlots/AstroPlots.jl")

@reexport using .CommonTypes
@reexport using .TwoBody
@reexport using .ThreeBody
@reexport using .NBody
@reexport using .Propagators
@reexport using .Maneuvers
@reexport using .AstroPlots

include("Misc/DocStringExtensions.jl")
include("Misc/UnitfulAliases.jl")

# For some reason, this ~adds~ a LOT
# to the precompilation time, and 
# there doesn't seem to be a lot of 
# difference between package load 
# times with or without the 
# precompilation_includer call
# - Joe 02/03/2021
# include("precompile_includer.jl")

end # module