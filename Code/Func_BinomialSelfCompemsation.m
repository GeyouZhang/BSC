% This function computes the 3D point clouds from the wrapped phase map of both left and right cameras.
%
% Input parameters:
% vmI    -- captured image sequence, format: H×W×(K+4), where H×W is the image resolution, K is the binomial order
%
% Output:
% mPhi   -- motion-error-free obtained through our BSC
% mBc    -- modulation
function[ mPhi, mBc ] = Func_BinomialSelfCompemsation( vmI )
[iCameraHeight, iCameraWidth, iFrameNum] = size(vmI);
vmPhi = zeros(iCameraHeight, iCameraWidth, iFrameNum - 3);
vmBc = zeros(iCameraHeight, iCameraWidth, iFrameNum - 3);
iBinomialOrder = iFrameNum - 4;

%% Compute motion-affected phase frames and correct the inherent phase shifting
for i = 1:iBinomialOrder + 1
    [vmPhi(:, :, i), vmBc(:, :, i)] = Func_FourStepPhaseShifting( vmI(:, :, i), vmI(:, :, i + 1), vmI(:, :, i + 2), vmI(:, :, i + 3) );
    vmPhi(:, :, i) = mod(vmPhi(:, :, i) + pi/2*( i - 1 ),2*pi);
end

%% Binomial self-compensation implented by pairwise summation layer by layer 
for k = 1:iBinomialOrder
    for s = 1:iBinomialOrder - k + 1
        vmPhi(:, :, s) = Func_AddTwoPhase( vmPhi(:, :, s), vmPhi(:, :, s + 1) );
    end
end

%% Compute modulation and eliminate the areas that are too dark
mBc = 0;
for i = 1:iBinomialOrder + 1
    mBc = nchoosek(iBinomialOrder, iBinomialOrder - ( i - 1 ) ) .* vmBc(:, :, i) + mBc;
end
mBc = mBc ./ (2^iBinomialOrder);
BcThresh = 15;
vDark = find(mBc<BcThresh);
mPhi = mod( vmPhi(:, :, 1), 2*pi);
mPhi(vDark) = nan;
end

function[ mPhi ] = Func_AddTwoPhase( mPhi0, mPhi1 )
    mLeap0 = abs(mPhi1 - mPhi0)>pi;
    mPhi = ( mPhi0 + mPhi1 + 2*pi.*mLeap0 ) ./ 2;
end