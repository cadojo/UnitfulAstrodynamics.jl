#
# Provides default transforms, and the means for users to create their own.
#

"""
$(TYPEDEF)

A `supertype` for all astrodynamics coordinate frame transformations.
"""
abstract type AstrodynamicsTransform end # should this be a subtype of CoordinateTransformations.Transformation?

"""
$(TYPEDEF)

A generic frame transformation between two `AstrodynamicsFrame` types.
Converts `F1` to`F2`.

$(TYPEDFIELDS)
"""
struct Transform{F1<:AstrodynamicsFrame, F2<:AstrodynamicsFrame, T1<:CoordinateTransformations.Transformation, T2<:CoordinateTransformations.Transformation} <: AstrodynamicsTransform
    transform_position::T1
    transform_velocity::T2
end

"""
$(SIGNATURES)

An outer constructor for `Transform` instances. 
Provide position and velocity transformations,
and the initial and final reference frames via 
function arguments. This is an alternate syntax
for `Transform{InitialFrame, FinalFrame}(position_transform, velocity_transform)`.
"""
function Transform(position_transform::CoordinateTransformations.Transformation, velocity_transform::CoordinateTransformations.Transformation, from::F1, to::F2) where {F1 <: AstrodynamicsTransform, F2 <: AstrodynamicsTransform}
    return Transform{F1, F2}(position_transform, velocity_transform)
end
