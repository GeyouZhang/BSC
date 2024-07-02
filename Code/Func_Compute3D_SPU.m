% This function computes the 3D point clouds from the wrapped phase map of both left and right cameras.
%
% Input parameters:
% mPhaseWrapLeft       -- wrapped phase map of left camera
% mPhaseWrapRight      -- wrapped phase map of right camera
% mDispMin, mDispMax   -- disparity range in auxiliary camera corresponding to each main camera pixel (x^m, y^m)
% mCamera1Rectified    -- perspective projection matrix of the main camera
% mCamera2Rectified    -- perspective projection matrix of the auxiliary camera
% mProjector           -- perspective projection matrix of the projector
% FSet                 -- frequency of fringe pattern  
% bBlockMatchingFlag   -- equals to 1 indicates using block matching algorithm (slower but less outliers)
%                         equals to 0 indicates using single-pixel matching algorithm (faster but more outliers)
%
% Output:
% mX,mY,mZ             -- reconstructed point cloud
% mPhase               -- unwrapped phase map of left camera
function[ mX, mY, mZ, mPhase ] = Func_Compute3D_SPU( mPhaseWrapLeft, mPhaseWrapRight, mDispMin, mDispMax, mCamera1Rectified, mCamera2Rectified, mProjector, FSet, bBlockMatchingFlag )
[ mPhase ] = Func_StereoPhaseUnwrapping( mPhaseWrapLeft, mPhaseWrapRight, mDispMin, mDispMax, mCamera1Rectified, mCamera2Rectified, mProjector, FSet, bBlockMatchingFlag );
mXpUnwrap = mPhase ./ (2*pi) .* 1280;
[ mX, mY, mZ ] = Func_Compute3DXp( mCamera1Rectified, mProjector, mXpUnwrap, 0, 0 );
end

function[ mPhase ] = Func_StereoPhaseUnwrapping( mPhaseWrapLeft, mPhaseWrapRight, mDispMin, mDispMax, mCamera1Rectified, mCamera2Rectified, mProjector, FSet, bBlockMatchingFlag )
if( bBlockMatchingFlag )
    [ mXTarget ] = Func_PhaseMatchSAD( mPhaseWrapLeft, mPhaseWrapRight, mDispMin, mDispMax,3);
else
    [ mXTarget ] = Func_PhaseMatchPoint( mPhaseWrapLeft, mPhaseWrapRight, mDispMin, mDispMax);
end
[ mXMatch, mYMatch, mZMatch ] = Func_Compute3DXp( mCamera1Rectified, mCamera2Rectified, mXTarget, 0, 0 );
vP = mProjector * [ mXMatch(:), mYMatch(:), mZMatch(:), ones( numel( mZMatch(:) ), 1 ) ]';

vP = vP ./ vP( 3, : );
vxp = vP( 1, : );
mXp = reshape( vxp, size(mPhaseWrapLeft) );
mPhiReference = mXp ./ 1280 .*(2*pi);
mPhaseOrder = round( ( FSet(end) .* mPhiReference - mPhaseWrapLeft ) ./ (2*pi) );
mPhase = ( mPhaseOrder .* (2*pi) + mPhaseWrapLeft ) ./ FSet(end);
end