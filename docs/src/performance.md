In order to achieve a fast evaluation we need to precompute some things and also preallocate
intermediate storage. For this we have `GradientConfig` and `JacobianConfig`:
```@docs
GradientConfig
JacobianConfig
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


## DiffResults
```@docs
GradientDiffResult
JacobianDiffResult
value
```
