function[ mMatch ] = Func_PhaseMatchPoint( mPhaseLeft, mPhaseRight, mDispMin, mDispMax )
[iCameraHeight, iCameraWidth] = size(mPhaseLeft);
mMatch = nan( iCameraHeight, iCameraWidth );
parfor i = 1:iCameraHeight
    vMatch = nan( 1, iCameraWidth );
    for j = 1:iCameraWidth
        dPhiTemplate = mPhaseLeft( i, j );
        if( isnan( dPhiTemplate ) )
            continue;
        end
        vPhiCandidate = mPhaseRight( i, : );
        xFrom = max( 1, j + mDispMin(i, j) );
        xTo = min( iCameraWidth, j + mDispMax(i, j) );
        iDispRange = xTo - xFrom;
        iMaxRange = mDispMax(i, j) - mDispMin(i, j);
        vCost = nan(iDispRange, 1);
        vXCandidate  = xFrom:xTo;
        vCost = min( abs( vPhiCandidate(xFrom:xTo) - dPhiTemplate ), 2.*pi - abs( vPhiCandidate(xFrom:xTo) - dPhiTemplate ) )';
        if( isempty(vCost) )
            continue;
        end

        iValid = sum(~isnan(vCost));
        if(iValid < 0.4*iDispRange)
            continue;
        end

        [ dCost, iIdxMin ] = min( vCost );      
        if( iIdxMin == 1 || iIdxMin == iDispRange + 1 )
            continue;
        else
            vVariable = vXCandidate( iIdxMin - 1:iIdxMin + 1 )';
            Temp = vVariable(1);
            vVariable = vVariable - Temp;
            vValue = vCost( iIdxMin - 1:iIdxMin + 1 );
            mA = [ vVariable.^2, vVariable, ones( 3, 1 ) ];
            vABC = Func_Inverse3(mA) * vValue;
            dXMatch = - vABC( 2 ) / vABC( 1 ) / 2 + Temp;
            vMatch(j) = dXMatch;
        end
    end
    mMatch(i,:) = vMatch;
end
end