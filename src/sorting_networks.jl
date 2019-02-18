using SIMD

function nested_calls(name, n, input)
    if n == 0
        input
    else
        Expr(:call, Symbol(name, n) , nested_calls(name, n-1, input))
    end
end

# Networks found by Bose-Nelson algorithm, except for N=16
# http://pages.ripco.net/~jgamble/nw.html
# http://www.cs.brandeis.edu/~hugues/sorting_networks.html
# https://github.com/JeffreySarnoff/SortingNetworks.jl
nets = (
    (4, (((1,2), (3,4)), ((1,3), (2,4)), ((2,3),))),
    (8, (
        ((1, 2), (3, 4), (5, 6), (7, 8)), ((1, 3), (2, 4), (5, 7), (6, 8)),
        ((2, 3), (6, 7), (1, 5), (4, 8)), ((2, 6), (3, 7)),
        ((2, 5), (4, 7)), ((3, 5), (4, 6)), ((4, 5),)
    )),
    (16, (
        ((4, 11), (12, 15), (5, 14), (3, 13), (1, 7), (9, 10), (2,8), (6, 16)),
        ((1, 2), (3, 5), (7, 8), (13, 14), (4, 6), (9, 12), (11, 16), (10, 15)),
        ((1, 4), (7, 11), (14, 15), (2, 6), (8, 16), (3, 9), (10, 13), (5, 12)),
        ((1, 3), (8, 14), (15, 16), (2, 5), (6, 12), (4, 9), (11, 13), (7, 10)),
        ((2, 3), (4, 7), (8, 9), (12, 14), (6, 10), (13, 15), (5, 11)),
        ((3, 7), (12, 13), (2, 4), (6, 8), (9, 10), (14, 15)),
        ((3, 4), (5, 7), (11, 12), (13, 14)),
        ((9, 11), (5, 6), (7, 8), (10, 12)),
        ((4, 5), (6, 7), (8, 9), (10, 11), (12, 13)),
        ((7, 8), (9, 10))
    )),
    (32, (
        ((1, 2), (3, 4), (5, 6), (7, 8), (9, 10), (11, 12), (13, 14), (15, 16), (17, 18), (19, 20), (21, 22), (23, 24),
         (25, 26), (27, 28), (29, 30), (31, 32)),
        ((1, 3), (2, 4), (5, 7), (6, 8), (9, 11), (10, 12), (13, 15), (14, 16), (17, 19), (18, 20), (21, 23), (22, 24),
         (25, 27), (26, 28), (29, 31), (30, 32)),
        ((2, 3), (6, 7), (1, 5), (4, 8), (10, 11), (14, 15), (9, 13), (12, 16), (18, 19), (22, 23), (17, 21), (20, 24),
         (26, 27), (30, 31), (25, 29), (28, 32)),
        ((2, 6), (3, 7), (10, 14), (11, 15), (1, 9), (8, 16), (18, 22), (19, 23), (26, 30), (27, 31), (17, 25),
         (24, 32)),
        ((2, 5), (4, 7), (10, 13), (12, 15), (18, 21), (20, 23), (26, 29), (28, 31), (1, 17), (16, 32)),
        ((3, 5), (4, 6), (11, 13), (12, 14), (2, 10), (7, 15), (19, 21), (20, 22), (27, 29), (28, 30), (18, 26), (23, 31)),
        ((4, 5), (12, 13), (2, 9), (3, 11), (6, 14), (8, 15), (20, 21), (28, 29), (18, 25), (19, 27), (22, 30), (24, 31)),
        ((4, 12), (3, 9), (5, 13), (8, 14), (20, 28), (19, 25), (21, 29), (24, 30), (2, 18), (15, 31)),
        ((4, 11), (6, 13), (20, 27), (22, 29), (2, 17), (3, 19), (14, 30), (16, 31)),
        ((4, 10), (7, 13), (20, 26), (23, 29), (3, 17), (16, 30)),
        ((4, 9), (8, 13), (6, 10), (7, 11), (20, 25), (24, 29), (22, 26), (23, 27)),
        ((5, 9), (8, 12), (21, 25), (24, 28), (4, 20), (13, 29)),
        ((6, 9), (8, 11), (22, 25), (24, 27), (4, 19), (5, 21), (12, 28), (14, 29)),
        ((7, 9), (8, 10), (23, 25), (24, 26), (4, 18), (6, 22), (11, 27), (15, 29)),
        ((8, 9), (24, 25), (4, 17), (6, 21), (7, 23), (10, 26), (12, 27), (16, 29)),
        ((8, 24), (7, 21), (5, 17), (6, 18), (9, 25), (12, 26), (15, 27), (16, 28)),
        ((8, 23), (6, 17), (7, 19), (10, 25), (14, 26), (16, 27)), ((8, 22), (7, 17), (11, 25), (16, 26)),
        ((8, 21), (12, 25)), ((8, 20), (13, 25)), ((8, 19), (14, 25), (12, 20), (13, 21)),
        ((8, 18), (15, 25), (11, 19), (14, 22)), ((8, 17), (16, 25), (10, 18), (12, 19), (14, 21), (15, 23)),
        ((9, 17), (12, 18), (16, 24), (15, 21)), ((10, 17), (16, 23), (14, 18), (15, 19)), ((11, 17), (16, 22)),
        ((12, 17), (16, 21)), ((13, 17), (16, 20)), ((14, 17), (16, 19)), ((15, 17), (16, 18)), ((16, 17),)
    ))
)

for nn in 1:length(nets)
    inlen, net_params = nets[nn]
    nsteps = length(net_params)

    for st in 1:nsteps
        aa = [:(@inbounds input[$n]) for n in 1:inlen]
        for t in net_params[st]
            aa[t[1]] = :(@inbounds min(input[$(t[1])],input[$(t[2])]))
            aa[t[2]] = :(@inbounds max(input[$(t[1])],input[$(t[2])]))
        end
        eval(Expr(:(=),
                  Expr(:call, Symbol("sort_", inlen, "_step_", st), :input),
                  Expr(:call, :tuple, aa...)))
        function_declaration = Expr(
            :(=),
            Expr(:call, Symbol("sort_", inlen), :input),
            Expr(:block, LineNumberNode(123), nested_calls("sort_$(inlen)_step_", nsteps, :input))
        )

        # eval(function_declaration)
        eval(
            Expr(:macrocall, Symbol("@inline"), LineNumberNode(101), function_declaration)
        )
    end
end


function gen_net_code(inlen, net_params)
    nsteps = length(net_params)


    aa = Expr(:block)

    for t in 1:inlen
        a1 = Symbol("input_", 0, "_", t)
        push!(aa.args, :($a1 = input[$t]))
    end

    for st in 1:nsteps

        touched = [x for t in net_params[st] for x in t]
        untouched = setdiff(1:inlen, touched)

        for t in untouched
            a1 = Symbol("input_", st-1, "_", t)
            b1 = Symbol("input_", st, "_", t)
            push!(aa.args, :($b1 = $a1))
        end

        for t in net_params[st]
            a1 = Symbol("input_", st-1, "_", t[1])
            a2 = Symbol("input_", st-1, "_", t[2])
            b1 = Symbol("input_", st, "_", t[1])
            b2 = Symbol("input_", st, "_", t[2])
            push!(aa.args, :($b1 = min($a1, $a2)))
            push!(aa.args, :($b2 = max($a1, $a2)))
        end
    end

    push!(aa.args,
          Expr(:tuple, ntuple(t->Symbol("input_", nsteps, "_", t), inlen)...))
    println(aa)

    function_declaration = Expr(
        :(=),
        Expr(:call, Symbol("sort_", inlen), :input), aa
#        Expr(:block, LineNumberNode(123), nested_calls("sort_$(inlen)_step_", nsteps, :input))
    )

        # eval(function_declaration)
        eval(
            Expr(:macrocall, Symbol("@inline"), LineNumberNode(101), function_declaration)
        )


end

gen_net_code(nets[3]...)

function run_test()
    for p in 2:5
        n = 2^p
        ee = Expr(:call, Symbol("sort_", n), :(rand($n)))
        println(ee)
        for x in 1:100000
            aa = eval(ee)
            @assert all(aa[2:end] .> aa[1:end-1])
        end
    end
end


# aa = rand(Int64, 16)
# @code_native sort_16(aa)

# T = UInt32
T = Int16
N = 16
a_in = rand(T, N*N)
display(a_in')
aa = ntuple(i->vload(Vec{N, T}, a_in, i*N-(N-1)), N)
qq = sort_16(aa)
# @code_native sort_16(aa)


# [0,1,2,3]
# [4,5,6,7]

# [0,1,4,5]
# [2,3,6,7]
