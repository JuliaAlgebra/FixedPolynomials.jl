"""
    unique_exponents(exponents::Vector{Matrix{Int}})

For all exponent matrixes `exponents` find for each variable, i.e. each row, all occuring (unique)
exponents and sort them in ascending order.
Let ``k_i`` be the number of occuring exponents for variable ``i``. Then this returns a
`Matrix` with ``\max_i(k_i)`` columns and number of variables columns.
Each row is filled with the unique occuring exponents ``e_1,…,e_{k_i}`` if ``k_i < \max_i(k_i)``
the rest is filled with zeros.
"""
function unique_exponents(exponents::Vector{Matrix{Int}})
    m = size(first(exponents), 1)
    sets = map(1:m) do i
        # collect all exponents of the i-th variable
        set = Set{Int}()
        for k = 1:length(exponents), j = 1:size(exponents[k], 2)
             push!(set, exponents[k][i, j])
        end
        set
    end
    width = maximum(length.(sets))
    exps = zeros(Int, m, width)
    for i=1:m
        set = sets[i]
        vals = sort!(collect(set))
        for j=1:length(vals)
            exps[i,j] = vals[j]
        end
    end
    exps
end
unique_exponents(exponents::Matrix{Int}) = unique_exponents([exponents])

"""
    lookuptable(exponents::Matrix{Int}, unique_exponents::Matrix{Int})

Compute the lookuptable mapping `exponents` to the correct indices in `unique_exponents`.
"""
function lookuptable(exponents::Matrix{Int}, unique_exponents::Matrix{Int})
    m, n = size(exponents)
    table = similar(exponents)
    for j=1:n, i=1:m
        table[i, j] = findfirst(x -> x == exponents[i, j], unique_exponents[i,:])
    end
    table
end

"""
    differences!(unique_exponents::Matrix{Int})

For each row, subtract the value in column `j` from the value in column `j-1`. If a negative
value would occur set it to zero instead.
We assume that `unique_exponents` was computed with [unique_exponents](@ref).
"""
function differences!(unique_exponents::Matrix{Int})
    m, n = size(unique_exponents)
    if n == 0
        return unique_exponents
    end

    for i=1:m
        lastexp = unique_exponents[i, 1]
        for j=2:n
            newlastexp = unique_exponents[i, j]
            unique_exponents[i, j] = max(newlastexp - lastexp, 0)
            lastexp = newlastexp
        end
    end

    unique_exponents
end

@inline pow(x::AbstractFloat, k::Integer) = k == 1 ? x : Base.FastMath.pow_fast(x, k)
@inline pow(x::Complex, k::Integer) = k == 1 ? x : x^k

"""
    fillvalues!(values::Matrix{T}, diffs::Matrix{Int}, x::AbstractVector{T}) where T

Fill `values` using the `diffs` `Matrix` as computed by [differences!](@ref) and `x`.
"""
@inline function fillvalues!(values::Matrix{T}, diffs::Matrix{Int}, x::AbstractVector{T}) where T
    m, n = size(values)
    if n == 0
        return values
    end
    for i=1:m
        @inbounds l = diffs[i,1]
        @inbounds xi = x[i]
        @inbounds v = l == 0 ? one(T) : pow(x[i], l)
        @inbounds values[i, 1] = v
        for k=2:n
            @inbounds l = diffs[i,k]
            @inbounds v = l == 0 ? v : v * pow(x[i], l)
            @inbounds values[i,k] = v
        end
    end
    values
end

"""
    evaluate_lookuptable(table::Matrix{Int}, values::Matrix{T}, coefficients::Vector{T})

Evalute a polynomial with the given lookuptable `table`, precomputed `values` (as computed
by [fillvalues!](@ref)) and coefficients `coefficients`.
"""
@inline function evaluate_lookuptable(table::Matrix{Int}, values::Matrix{T}, coefficients::Vector{T}) where T
    res = zero(T)
    m, n = size(table)
    for k = 1:n
        @inbounds term = coefficients[k]
        for i = 1:m
            @inbounds term *= values[i, table[i,k]]
        end
        res += term
    end
    res
end
