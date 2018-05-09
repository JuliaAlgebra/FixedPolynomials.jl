In order to achieve a fast evaluation we need to precompute some things and also preallocate
intermediate storage. For this we have
```@docs
config
```

## Evaluation
```@docs
evaluate
evaluate!
```

##  Derivatives
```@docs
FixedPolynomials.gradient
gradient!
jacobian
jacobian!
```

## Systems
```@docs
System
```
Systems have the additional functions
```@docs
evaluate_and_jacobian!
evaluate_and_jacobian
```


## DiffResults
```@docs
GradientDiffResult
JacobianDiffResult
value
```
