function [ mPhaseX, mPhaseY ] = Func_PhaseGradient( mPhase )
    [iH, iW] = size( mPhase );
    mPhaseX = nan(iH, iW);
    mPhaseY = nan(iH, iW);
    for i = 2:iH - 1
        for j = 2:iW - 1
            mPhaseX( i, j ) = Func_PhaseCorrect( mPhase( i, j + 1 ) - mPhase( i, j - 1 ) ) / 2;
            mPhaseY( i, j ) = Func_PhaseCorrect( mPhase( i + 1, j ) - mPhase( i - 1, j ) ) / 2;
        end
    end

    iLow = 1; iHigh = iH;
    for j = 2:iW - 1
        mPhaseX( iLow, j ) = Func_PhaseCorrect( mPhase( iLow, j + 1 ) - mPhase( iLow, j - 1 ) ) / 2;              
        mPhaseY( iLow, j ) = Func_PhaseCorrect( mPhase( iLow, j ) - mPhase( iLow + 1, j ) );        
        mPhaseX( iHigh, j ) = Func_PhaseCorrect( mPhase( iHigh, j + 1 ) - mPhase( iHigh, j - 1 ) ) / 2;
        mPhaseY( iHigh, j ) = Func_PhaseCorrect( mPhase( iHigh - 1, j ) - mPhase( iHigh, j ) );
    end
    
    jLow = 1; jHigh = iW;
    for i = 2:iH - 1
        mPhaseX( i, jLow ) = Func_PhaseCorrect( mPhase( i, jLow ) - mPhase( i, jLow + 1 ) );              
        mPhaseY( i, jLow ) = Func_PhaseCorrect( mPhase( i - 1, jLow ) - mPhase( i + 1, jLow ) ) / 2;        
        mPhaseX( i, jHigh ) = Func_PhaseCorrect( mPhase( i, jHigh - 1 ) - mPhase( i, jHigh ) );  
        mPhaseY( i, jHigh ) = Func_PhaseCorrect( mPhase( i - 1, jLow ) - mPhase( i + 1, jLow ) ) / 2;      
    end
    
    mPhaseX( 1, 1 ) = mPhase( 1, 2 ) - mPhase( 1, 1 );
    mPhaseX( 1, iW ) = mPhase( 1, iW ) - mPhase( 1, iW - 1 );
    mPhaseX( iH, 1 ) = mPhase( iH, 2 ) - mPhase( iH, 1 );
    mPhaseX( iH, iW ) = mPhase( iH, iW ) - mPhase( iH, iW - 1 );
    
    mPhaseY( 1, 1 ) = mPhase( 2, 1 ) - mPhase( 1, 1 );
    mPhaseY( 1, iW ) = mPhase( 2, iW ) - mPhase( 1, iW );
    mPhaseY( iH, 1 ) = mPhase( iH, 1 ) - mPhase( iH - 1, 1 );
    mPhaseY( iH, iW ) = mPhase( iH, iW ) - mPhase( iH - 1, iW );
end

function [ dPhase ] = Func_PhaseCorrect( dPhase )
    if( dPhase > pi )
        dPhase = dPhase - 2 * pi; 
    elseif( dPhase < -pi )
        dPhase = dPhase + 2 * pi;
    else
    end
end