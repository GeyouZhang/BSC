clc; clear all; close all;
%% Parameters Setting
addpath('./Package')
load('../Data/mCamera1Rectified.mat');
load('../Data/mCamera2Rectified.mat');
load('../Data/mProjector.mat');
% Select data
% sFolderL = '../Data/Statue/1_Rectified/';
% sFolderR = '../Data/Statue/2_Rectified/';
sFolderL = '../Data/Hand/1_Rectified/';
sFolderR = '../Data/Hand/2_Rectified/';
NSet = 4; FSet = 28.5;
iCameraWidth = 640; iCameraHeight = 480;
iFrameTotal = 100;
% Set Depth Range:
Zmin = -110; Zmax = 20;
% Set binomial order of motion error compensation,
% binomial order = 0 represents no compensation.
iBinomialOrder = 4;
iImageNum = iBinomialOrder + 4;
% Compute Disparity Range
[ mDispMin, mDispMax ] = Func_DispartiyRange( Zmin, Zmax, mCamera1Rectified, mCamera2Rectified, iCameraHeight, iCameraWidth );

%% Image Sequence Loading
vmIL = nan( iCameraHeight, iCameraWidth, iFrameTotal );
vmIR = nan( iCameraHeight, iCameraWidth, iFrameTotal );
for i = 1:iFrameTotal  
    vmIL(:,:,i) = double( imread( sprintf( '%s%04d.bmp', sFolderL, i - 1 ) ) );
    vmIR(:,:,i) = double( imread( sprintf( '%s%04d.bmp', sFolderR, i - 1 ) ) );
end
%% Binomial Self-Compensation VS Traditional Four-step phase shifting for Dynamic 3D Scanning
% The computation speed can be accelerated by setting a larger number of workers in the MATLAB parallel pool
figure;
set(gcf, 'Position', [0 0 2000 800]);
for i = 1:iFrameTotal - iImageNum + 1
    %% 3D reconstruction with our BSC
    % Binomial Self-Compemsation for High Frequency Wrapped Phase
    tic
    [ mPhaseWrapLeft, mBcLeft ] = Func_BinomialSelfCompemsation( vmIL(:, :, i:i+ iImageNum - 1) );
    [ mPhaseWrapRight, mBcRight ] = Func_BinomialSelfCompemsation( vmIR(:, :, i:i+ iImageNum - 1) );
    dT1 = toc;
    % Correct Inherent Phase Shift
    dOffset = pi/2*mod(i - 1,4);
    mPhaseWrapLeft = mod(mPhaseWrapLeft + dOffset,2*pi);
    mPhaseWrapRight = mod(mPhaseWrapRight + dOffset,2*pi);
    
    % Stereo Phase Unwarpping and 3D Reconstruction
    tic
    [ mX, mY, mZ, mPhase] = Func_Compute3D_SPU( mPhaseWrapLeft, mPhaseWrapRight, mDispMin, mDispMax, mCamera1Rectified, mCamera2Rectified, mProjector, FSet, 1 );
    dT2 = toc;
    
    % Remove the Outliers
    mInvalid = isnan( mZ ); mZ( mInvalid ) = 0; mZFilted = medfilt2( mZ, [25,25]); mOutlier = abs(mZ - mZFilted) > 2; mZ( mOutlier|mInvalid ) = nan;
    %% 3D reconstruction with traditional four-step phase shifting
    tic
    [ mPhaseWrapLeftFourStep, mBcLeftFourStep ] = Func_BinomialSelfCompemsation( vmIL(:, :, i:i+ 3) );
    [ mPhaseWrapRightFourStep, mBcRightFourStep ] = Func_BinomialSelfCompemsation( vmIR(:, :, i:i+ 3) );
    dT3 = toc;
    
    % Correct Inherent Phase Shift
    dOffset = pi/2*mod(i - 1,4);
    mPhaseWrapLeftFourStep = mod(mPhaseWrapLeftFourStep + dOffset,2*pi);
    mPhaseWrapRightFourStep = mod(mPhaseWrapRightFourStep + dOffset,2*pi);
    
    % Stereo Phase Unwarpping and 3D Reconstruction
    tic
    [ mXFourStep, mYFourStep, mZFourStep, mPhaseFourStep] = Func_Compute3D_SPU( mPhaseWrapLeftFourStep, mPhaseWrapRightFourStep, mDispMin, mDispMax, mCamera1Rectified, mCamera2Rectified, mProjector, FSet, 1 );
    dT4 = toc;
    disp(['Frame no.',num2str(i), '-----------------------------------------------------------------------------------------------------------']);
    disp(['BSC takes ', num2str(dT1), 's', ', SPU and 3D reconstruction take ', num2str(dT2), 's']);
    disp(['Traditional four-step takes ', num2str(dT3), 's', ', SPU and 3D reconstruction take ', num2str(dT4), 's']);
    
    % Remove the Outliers
    mInvalid = isnan( mZFourStep ); mZFourStep( mInvalid ) = 0; mZFilted = medfilt2( mZFourStep, [25,25]); mOutlier = abs(mZFourStep - mZFilted) > 2; mZFourStep( mOutlier|mInvalid ) = nan;
    
    %% Draw the point clouds
    subplot(121);
    pcshow( [mX(:),mY(:),mZ(:)] ); axis image; zlim([Zmin, Zmax]); xlim([-100, 40]); ylim([-120, 20]); 
    view([0 -90]);caxis([Zmin, Zmax]); colormap(jet); title('Our BSC', 'FontSize', 20);
    cb = colorbar; set(cb, 'TickLabelInterpreter', 'latex', 'FontSize', 20, 'Color', 'white'); 
    subplot(122);
    pcshow( [mXFourStep(:),mYFourStep(:),mZFourStep(:)] ); axis image; zlim([Zmin, Zmax]); xlim([-100, 40]); ylim([-120, 20]); 
    view([0 -90]);caxis([Zmin, Zmax]); colormap(jet);title('Traditional four-step', 'FontSize', 20);
    cb = colorbar; set(cb, 'TickLabelInterpreter', 'latex', 'FontSize', 20, 'Color', 'white'); 
    drawnow;
end