
function computetables(exponents::Matrix{T}) where {T<:Integer}
    m, n = size(exponents)
    lookuptable = permutedims(exponents, (2, 1))

    for j=1:m
        sort!(@view lookuptable[:, j])
    end

    j = 1
    maxk = 0
    for j=1:m
        k = 1
        for i=2:n
            if lookuptable[i, j] > lookuptable[k, j]
                k += 1
                lookuptable[k, j] = lookuptable[i, j]
            end
            if k < i
                lookuptable[i, j] = 0
            end
        end
        maxk = max(maxk, k)
    end
    # now we copy the relevant subsection
    # we do not compute the differences now since we need to compute the lookuptable first
    differences = Matrix{UInt8}(undef, m, maxk)
    for i=1:m, j=1:maxk
        differences[i, j] = lookuptable[j, i]
    end

    lookuptable = permutedims(lookuptable, (2, 1))
    for j=1:n, i=1:m
        for k = 1:maxk
            if differences[i, k] == exponents[i, j]
                lookuptable[i, j] = k
                break
            end
        end
    end

    # now we can compute the differences
    for i=1:m
        lastval = differences[i, 1]
        for j=2:maxk
            val = differences[i, j]
            if val > 0
                differences[i, j] = val - lastval
                lastval = val
            end
        end
    end
    differences, lookuptable
end

function computetables(exponents_vec::Vector{Matrix{T}}) where {T<:Integer}
    widths = size.(exponents_vec, 2)
    # we fake our exponents_vec as a single big matrix, compute the differences and a
    # big lookuptable and then split it again
    allexponents = hcat(exponents_vec...)
    differences, biglookuptable = computetables(allexponents)

    m = size(biglookuptable, 1)

    total = 1
    lookuptables = Vector{Matrix{T}}()
    for n in widths
        push!(lookuptables, biglookuptable[:, total : total + n - 1])
        total += n
    end
    differences, lookuptables
end
