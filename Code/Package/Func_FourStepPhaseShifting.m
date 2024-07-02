function[ mPhi, mBc ] = Func_FourStepPhaseShifting( mI0, mI1, mI2, mI3 )
mSin = mI1 - mI3;
mCos = mI0 - mI2;
mPhi = pi + atan2( - mSin, - mCos );
mBc = 2.*sqrt(mSin.^2 + mCos.^2)./4;
end