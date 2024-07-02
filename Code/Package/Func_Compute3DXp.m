function [ X, Y, Z ] = Func_Compute3DXp( PPM_Camera, PPM_Projector, Phase, ROI_X, ROI_Y )

[ Height, Width ] = size( Phase );

XXX = nan( Height, Width );
YYY = nan( Height, Width );
ZZZ = nan( Height, Width );
C = zeros( 3, 3 );
D = zeros( 3, 1 );

for i = 1 : Height

    yc = i + ROI_Y;

    for j = 1 : Width
        
        xp = Phase( i, j );

        if( 0 == xp || isnan(xp) )
            continue;
        end
        
        xc = j + ROI_X;

        C( 1, 1 ) = PPM_Camera( 1, 1 ) - PPM_Camera( 3, 1 ) * xc;
        C( 1, 2 ) = PPM_Camera( 1, 2 ) - PPM_Camera( 3, 2 ) * xc;
        C( 1, 3 ) = PPM_Camera( 1, 3 ) - PPM_Camera( 3, 3 ) * xc;

        C( 2, 1 ) = PPM_Camera( 2, 1 ) - PPM_Camera( 3, 1 ) * yc;
        C( 2, 2 ) = PPM_Camera( 2, 2 ) - PPM_Camera( 3, 2 ) * yc;
        C( 2, 3 ) = PPM_Camera( 2, 3 ) - PPM_Camera( 3, 3 ) * yc;

        C( 3, 1 ) = PPM_Projector( 1, 1 ) - PPM_Projector( 3, 1 ) * xp;
        C( 3, 2 ) = PPM_Projector( 1, 2 ) - PPM_Projector( 3, 2 ) * xp;
        C( 3, 3 ) = PPM_Projector( 1, 3 ) - PPM_Projector( 3, 3 ) * xp;

        D( 1, 1 ) = PPM_Camera( 3, 4 ) * xc - PPM_Camera( 1, 4 );
        D( 2, 1 ) = PPM_Camera( 3, 4 ) * yc - PPM_Camera( 2, 4 );
        D( 3, 1 ) = PPM_Projector( 3, 4 ) * xp - PPM_Projector( 1, 4 );
        
        World3D = Func_Inverse3( C ) * D;
        XXX( i, j ) = World3D( 1 );
        YYY( i, j ) = World3D( 2 );
        ZZZ( i, j ) = World3D( 3 );
        
    end
end

X = XXX;
Y = YYY;
Z = ZZZ;