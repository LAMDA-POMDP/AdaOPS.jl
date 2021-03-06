struct TextTree
    children::Vector{Vector{Int}}
    text::Vector{String}
end

function TextTree(D::AdaOPSTree)
    lenb = D.b
    lenba = D.ba
    len = lenb + lenba
    children = Vector{Vector{Int}}(undef, len)
    text = Vector{String}(undef, len)
    for b in 1:lenb
        children[b] = D.children[b] .+ lenb
        text[b] = @sprintf("o:%-5s prob:%6.2f u:%6.2f, l:%6.2f",
                           b==1 ? "<root>" : string(D.obs[b]),
                           D.obs_prob[b],
                           D.u[b],
                           D.l[b],
                            )
    end
    for ba in 1:lenba
        children[ba+lenb] = D.ba_children[ba]
        text[ba+lenb] = @sprintf("a:%-5s |ϕ|:%2d l:%6.2f u:%6.2f, r:%6.2f", D.ba_action[ba], length(D.ba_particles[ba]), D.ba_l[ba], D.ba_u[ba], D.ba_r[ba])
    end
    return TextTree(children, text)
end

struct TreeView
    t::TextTree
    root::Int
    depth::Int
end

TreeView(D::AdaOPSTree, b::Int, depth::Int) = TreeView(TextTree(D), b, depth)

Base.show(io::IO, tv::TreeView) = shownode(io, tv.t, tv.root, tv.depth, "", "")

function shownode(io::IO, t::TextTree, n::Int, depth::Int, item_prefix::String, prefix::String)
    print(io, item_prefix)
    print(io, @sprintf("[%-4d]", n))
    print(io, " $(t.text[n])")
    if depth <= 0
        println(io, " ($(length(t.children[n])) children)")
    else
        println(io)
        if !isempty(t.children[n])
            for c in t.children[n][1:end-1]
                shownode(io, t, c, depth-1, prefix*"├──", prefix*"│  ")
            end
            shownode(io, t, t.children[n][end], depth-1, prefix*"└──", prefix*"   ")
        end
    end
end
