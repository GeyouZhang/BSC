function [ mCameraM, mProjectorM ] = Func_TransformCalibMat( mCameraMTemp, mProjectorMTemp )
[ mAc, mRwc, vtwc ] = Func_ART( mCameraMTemp );
[ mAp, mRwp, vtwp ] = Func_ART( mProjectorMTemp );

mRTwc = [ mRwc, vtwc; zeros( 1, 3 ), 1 ];
mRTwp = [ mRwp, vtwp; zeros( 1, 3 ), 1 ];
mRTcp = mRTwp * inv( mRTwc );

mCameraM = [ mAc, zeros( 3, 1 ) ];
mProjectorM = mAp * mRTcp( 1:3,: );
end
