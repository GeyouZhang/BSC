% This function conducts stereo matching based on the wrapped phase maps. This is a simplified version for improving speed. 
% More robust stereo matching results can be obtained by employing phase-guided SAD (Phase Guided Light Field for Spatial-Depth High Resolution 3D Imaging, arXiv:2311.10568). 
%
% Input parameters:
% mPhaseLeft           -- wrapped phase map of left camera
% mPhaseRight          -- wrapped phase map of right camera
% mDispMin, mDispMax   -- disparity range in auxiliary camera corresponding to each main camera pixel (x^m, y^m)
% iRadius              -- the radius of sum of absolute difference window   
% 
% Output:
% mMatch               -- the corresponding point of each main camera pixel in the auxiliary camera
function[ mMatch ] = Func_PhaseMatchSAD( mPhaseLeft, mPhaseRight, mDispMin, mDispMax, iRadius )
[iCameraHeight, iCameraWidth] = size(mPhaseLeft);
mMatch = nan( iCameraHeight, iCameraWidth );
iDiameter = 2*iRadius + 1;
mPhaseLeft(isnan(mPhaseLeft)) = 0;
mPhaseRight(isnan(mPhaseRight)) = 0;
iNum = iDiameter^2;
parfor i = 1 + iRadius:iCameraHeight - iRadius
    vMatch = nan( 1, iCameraWidth );
    for j = 1 + iRadius:iCameraWidth - iRadius    
        if( mPhaseLeft( i, j ) == 0 )
            continue;
        end
        mPhiTemplate = mPhaseLeft( i - iRadius:i + iRadius, j - iRadius: j + iRadius);
        iDispRange = mDispMax(i, j) - mDispMin(i, j);
        vCost = nan(iDispRange, 1);
        xFrom = j + mDispMin(i, j);
        xTo = j + mDispMax(i, j);
        iCount = 0;
        vXCandidate  = xFrom:xTo;
        
        vXBlock = - iRadius: iRadius;
        vYBlock = - iRadius: iRadius;
        for idx = xFrom: xTo
            iCount = iCount + 1;
            if( xFrom - iRadius < 1 || xTo + iRadius >= iCameraWidth )
                continue;
            end
            mPhiTarget = mPhaseRight( i - iRadius:i + iRadius, idx - iRadius: idx + iRadius);
            mCost = min( abs( mPhiTarget - mPhiTemplate ), 2.*pi - abs( mPhiTarget - mPhiTemplate ) );
            vCost(iCount) = sum(mCost(:)) ./ iNum;
        end
        iValid = sum(~isnan(vCost));
        if(iValid < 0.4*iDispRange)
            continue;
        end
        [ ~, iIdxMin ] = min( vCost );
        if( iIdxMin == 1 || iIdxMin == iDispRange + 1 )
            vMatch(j) = xFrom + iIdxMin - 1;
        else
            vVariable = vXCandidate( iIdxMin - 1:iIdxMin + 1 )';
            Temp = vVariable(1);
            vVariable = vVariable - Temp;
            vValue = vCost( iIdxMin - 1:iIdxMin + 1 );
            mA = [ vVariable.^2, vVariable, ones( 3, 1 ) ];
            vABC = mA \ vValue;
            dXMatch = - vABC( 2 ) / vABC( 1 ) / 2 + Temp;
            vMatch(j) = dXMatch;
        end
    end
    mMatch(i,:) = vMatch;
end
end
