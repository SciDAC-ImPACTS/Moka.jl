include("../mode_init/MPAS_Ocean.jl")

### CPU tendency calculation

function calculate_normal_velocity_tendency!(mpasOcean::MPAS_Ocean)
    mpasOcean.normalVelocityTendency .= 0.0
    @fastmath for iEdge in 1:mpasOcean.nEdges

        if mpasOcean.boundaryEdge[iEdge] == 0
            cell1Index = mpasOcean.cellsOnEdge[1,iEdge]
            cell2Index = mpasOcean.cellsOnEdge[2,iEdge]

#             if cell1Index != 0 && cell2Index != 0
            @fastmath for k in 1:mpasOcean.maxLevelEdgeTop[iEdge]
                mpasOcean.normalVelocityTendency[k,iEdge] = mpasOcean.gravity * ( mpasOcean.sshCurrent[cell1Index] - mpasOcean.sshCurrent[cell2Index] ) / mpasOcean.dcEdge[iEdge]
            end
#             end

            # coriolis term
            @fastmath for i in 1:mpasOcean.nEdgesOnEdge[iEdge]
                eoe = mpasOcean.edgesOnEdge[i,iEdge]

                if eoe != 0
                    @fastmath for k in 1:mpasOcean.maxLevelEdgeTop[iEdge]
                        mpasOcean.normalVelocityTendency[k,iEdge] += mpasOcean.weightsOnEdge[i,iEdge] * mpasOcean.normalVelocityCurrent[k,eoe] * mpasOcean.fEdge[eoe]
#                         mpasOcean.normalVelocityTendency[k,iEdge] *= mpasOcean.edgeMask[iEdge,k]
                    end
                end
            end
        end
    end
end

function update_normal_velocity_by_tendency!(mpasOcean::MPAS_Ocean)
    mpasOcean.normalVelocityCurrent .+= mpasOcean.dt .* mpasOcean.normalVelocityTendency
end


function calculate_thickness_tendency!(mpasOcean::MPAS_Ocean)
    mpasOcean.layerThicknessTendency .= 0.0
    @fastmath for iCell in 1:mpasOcean.nCells # Threads.@threads
            @fastmath for k in 1:mpasOcean.maxLevelCell[iCell]
                mpasOcean.layerThicknessTendency[k,iCell] += -mpasOcean.div_hu[k,iCell] - mpasOcean.vertAleTransportTop[k,iCell] + mpasOcean.vertAleTransportTop[k+1,iCell]
            end
    end
end



function update_thickness_by_tendency!(mpasOcean::MPAS_Ocean)
    mpasOcean.layerThickness .+= mpasOcean.dt .* mpasOcean.layerThicknessTendency
end

function calculate_vertical_mixing!(mpasOcean::MPAS_Ocean)
    @fastmath for iEdge in 1:mpasOcean.nEdges
        cell1 = mpasOcean.cellsOnEdge[1,iEdge]
        cell2 = mpasOcean.cellsOnEdge[2,iEdge]

       @fastmath for k in 1:mpasOcean.maxLevelEdgeTop[iEdge]
           mpasOcean.layerThicknessEdge[k,iEdge] = 0.5 * (mpasOcean.layerThickness[k,iCell] + mpasOcean.layerThickness[k,iCell2])
       end

    
 
    end
end
