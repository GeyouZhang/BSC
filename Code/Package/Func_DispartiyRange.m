% This function computes the disparity range in auxiliary camera corresponding to each main camera pixel (x^m, y^m).
%
% Input parameters:
% dZwmin       -- wrapped phase map of left camera
% dZwmax       -- wrapped phase map of right camera
% mCamera1Rectified    -- perspective projection matrix of the main camera
% mCamera2Rectified    -- perspective projection matrix of the auxiliary camera
% iH, iW           -- image resolution
%
% Output:
% mDispMin, mDispMax   -- disparity range in auxiliary camera corresponding to each main camera pixel (x^m, y^m)
function[ mDispMin, mDispMax ] = Func_DispartiyRange( dZwmin,dZwmax, mCamera1Rectified, mCamera2Rectified, iH, iW )
m = mCamera1Rectified;
[ mAm, mRwm, vtwm ] = Func_ART( mCamera1Rectified );
[ mAa, ~, ~ ] = Func_ART( mCamera2Rectified );
[ ~, mCamera2 ] = Func_TransformCalibMat( mCamera1Rectified, mCamera2Rectified );
dBaseline = norm( inv( mCamera2( :, 1:3 ) ) * mCamera2( :, 4 ) );

mDispMin = nan(iH, iW);
mDispMax = nan(iH, iW);
mRmw = inv(mRwm);
fmx = mAm( 1, 1 ); fmy = mAm( 2, 2 );
um0 = mAm( 1, 3 ); vm0 = mAm( 2, 3 );
fax = mAa( 1, 1 ); fay = mAa( 2, 2 );
ua0 = mAa( 1, 3 ); va0 = mAa( 2, 3 );
for ym = 1:iH
    for xm = 1:iW
        mSolvemin = [xm*m(3,1)-m(1,1), xm*m(3,2)-m(1,2); ym*m(3,1)-m(2,1), ym*m(3,2)-m(2,2)];
        vSolvemin = [(m(1,3)-xm*m(3,3))*dZwmin + m(1,4)-xm*m(3,4); (m(2,3)-ym*m(3,3))*dZwmin + m(2,4)-ym*m(3,4)];
        vxmin = mSolvemin\vSolvemin;
        vxmin = [vxmin; dZwmin; 1];
        vCmin = mCamera2Rectified * vxmin;
        vCmin = vCmin ./ vCmin(end);
        a = vCmin(1) - xm;
        
        mSolvemax = [xm*m(3,1)-m(1,1), xm*m(3,2)-m(1,2); ym*m(3,1)-m(2,1), ym*m(3,2)-m(2,2)];
        vSolvemax = [(m(1,3)-xm*m(3,3))*dZwmax + m(1,4)-xm*m(3,4); (m(2,3)-ym*m(3,3))*dZwmax + m(2,4)-ym*m(3,4)];
        vxmax = mSolvemax\vSolvemax;
        vxmax = [vxmax; dZwmax; 1];
        vCmax = mCamera2Rectified * vxmax;
        vCmax = vCmax ./ vCmax(end);
        b = vCmax(1) - xm;

        mDispMax(ym, xm) = round(max(a,b)) + 1;
        mDispMin(ym, xm) = round(min(a,b)) - 1;
    end
end
end

function[ mAc, mRwc, vtwc ] = Func_ART( mCameraMTemp )
[ mRwc, mAc ] = qr( inv( mCameraMTemp( :, 1:3 ) ) );
mRwc = mRwc'; mAc = inv( mAc ); 
vtwc = inv(mAc) * mCameraMTemp( :, 4 );

for i = 1:2
    [~,idx] = max(abs( mAc( :, i ) ));
    if( mAc( idx, i ) < 0 )
        mAc(:,i) = - mAc(:,i);
        mRwc(i,:) = - mRwc(i,:);        
        vtwc(i) = -vtwc(i);
    end
end

if( mAc(3,3) < 0 )
    mAc(:,3) = - mAc(:,3);
    mRwc(3,:) = - mRwc(3,:);
    vtwc(3) = -vtwc(3);
end
mAc = mAc ./ abs(mAc( end ));
end

