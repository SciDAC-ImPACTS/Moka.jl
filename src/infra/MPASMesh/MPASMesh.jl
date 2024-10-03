module MPASMesh

# MPASMesh
export Mesh
# VertMesh.jl
export VerticalMesh
# HorzMesh.jl
export Cell, Edge, Vertex, ReadHorzMesh, HorzMesh

using Accessors
using NCDatasets
using StructArrays
using KernelAbstractions 

import Adapt

const KA = KernelAbstractions

struct Mesh{HM,VM}
    HorzMesh::HM
    VertMesh::VM

    function Mesh(HorzMesh::HM, VertMesh::VM) where {HM,VM}

        # set the horizontal boundary masks
        setBoundaryMask!(HorzMesh.Edges,        VertMesh)
        #setBoundaryMask!(HorzMesh.DualCells,    VertMesh)
        #setBoundaryMask!(HorzMesh.PrimaryCells, VertMesh)

        new{HM, VM}(HorzMesh, VertMesh)
    end
end

function Adapt.adapt_structure(backend, x::Mesh)
    return Mesh(Adapt.adapt(backend, x.HorzMesh),
                Adapt.adapt(backend, x.VertMesh))
end

include("HorzMesh.jl")
include("VertMesh.jl")

end 
