module ChipSort
import Base.pop!

export
    sort_net,
    transpose_vecs, transpose_vecs_tall, transpose_vecs_wide,
    bitonic_merge, merge_vecs, build_multi_merger, bitonic_merge_interleaved,
    DataBuffer, MergeNode, pop!,
    chipsort, chipsort_medium!, sort_chunks, sort_vecs!, merge_vecs_tree, sort_small_array, combsort!, insertion_sort!


include("utils.jl")
include("sorting-networks.jl")
include("transpose-vecs.jl")
include("bitonic-merge-network.jl")
include("data-buffers.jl")
include("sort-array.jl")
include("comb-sort.jl")
include("sort-array-medium.jl")

end # module
