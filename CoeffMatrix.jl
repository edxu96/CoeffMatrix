# Julia Module Manipulate the Coefficient Matrix in Standard LP or MILP Problem
# Version: 1.0
# Auther: Edward J. Xu
# Date: Aprial 6th, 2019
module CoeffMatrix
# function to initiate the coefficient matrix, update the last row, or add a row in the last.
function updateRow(; mat_coeff = 0, add = 0, num_m, num_n, mat_a,
    vec_i_x, vec_j_x, vec_i_a = vec_i_x, vec_j_a = vec_j_x)
    num_x = num_m * num_n
    # 1. Check if num_m, num_n and mat_coeff are coherent.
    if mat_coeff != 0
        (num_row_coeff, num_col_coeff) = size(mat_coeff)
        if num_x != num_col_coeff
            print("Wrong num_m or num_n, of which the product should be same with col number of mat_coeff!")
        end
    end
    # 2. Generate mat_a_cal with same row and col numbers with mat_x, if mat_a is not a matrix
    if isa(mat_a, Number)  # If mat_a is a number or a vector, generate a m*n matrix for later use
        mat_a_cal = mat_a * ones(num_m, num_n)
    end
    # If row vector, check if col number equals that of mat_x.
    # If col vector, check if row number equals that of mat_x.
    (num_row_a, num_col_a) = size(mat_a)
    if ((num_row_a != 1) && (num_row_a != num_m)) || ((num_col_a != 1) && (num_col_a != num_n))
        print("Wrong mat_a, which should be vector or a matix in same size with mat_x!")
        return (mat_coeff, mat_a)
    elseif num_row_a < num_m  # if mat_a is a row vector, duplicate it to m-row matrix
        mat_a_cal = ones(num_m, num_n)
        for i = 1: num_m
            mat_a_cal[i, :] = mat_a[1, :]
        end
        mat_a = mat_a_new
    elseif num_col_a < num_n  # if mat_a is a strict column vector, duplicate it to n-column matrix
        mat_a_cal = ones(num_m, num_n)
        for j = 1: num_n
            mat_a_cal[:, j] = mat_a[:, 1]
        end
    else
        mat_a_cal = mat_a
    end
    # 3. Calculate the new row vector for coefficient matrix
    vecRow_coeff_new = zeros(1, num_x)
    for i = 1: length(vec_i_x)
        for j = 1: length(vec_j_x)
            vecRow_coeff_new[(vec_i_x[i] - 1) * num_n + vec_j_x[j]] = mat_a_cal[vec_i_a[i], vec_j_a[j]]
        end
    end
    # 4. Update the last row of coefficient matrix or add a row in the last, if "add = 1".
    if mat_coeff == 0  # Initiate the coefficient matrix, if no coefficient matrix input.
        mat_coeff = vecRow_coeff_new
    elseif add == 1  # Add a row in the last
        mat_coeff = vcat(mat_coeff, vecRow_coeff_new)
    else  # Update the last row
        mat_coeff[num_row_coeff, :] = mat_coeff[num_row_coeff, :] + transpose(vecRow_coeff_new)
    end
    return (mat_coeff, mat_a_cal)
end
# Example:
# mat_a = [99.74  99.21  100.21  99.76  100.48  100.7  99.42  99.11  97.69  98.94  97.22  98.99;
#          1.89   2.02   1.95    2.16   2.16    2.08   2.08   2.09   1.97   1.99   1.89   1.95;
#          15.58  15.11  14.93   14.86  15.06   15.51  14.41  14.96  15.62  14.4   15.64  14.52]
# (mat_coeff, mat_a_cal) = updateRow(num_m = 3, num_n = 12, mat_a = - hcat(mat_a[:,1]), vec_i_x = [1 2 3], vec_j_x = [1])
# (mat_coeff, mat_a_cal) = updateRow(add = 1, mat_coeff = mat_coeff, num_m = 3, num_n = 12,
#     mat_a = - mat_a, vec_i_x = [1 2 3], vec_j_x = collect(2: 1: 12))
# (mat_coeff, mat_a_cal) = updateRow(add = 1,mat_coeff = mat_coeff, num_m = 3, num_n = 12,
#     mat_a = mat_a, vec_i_x = [1 2 3], vec_j_x = collect(1: 1: 11), vec_j_a = collect(1: 1: 11) .+ 1)
end  # module CoeffMatrix