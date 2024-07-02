function [ Ac, Bc, Phase ] = Func_GetPhaseHigh( Folder, NSet, fSet, Order )
fSet = fSet./fSet( 1 );
FreqLevel = length( fSet );
Count = 0;
Ac = 0;
Bc = 0;
for i = 1 : FreqLevel
    f = fSet( i );
    N = NSet( i );
    PSin = 0;
    PCos = 0;
    for j = 1 : N
        n = j - 1;
        Im = double( imread( sprintf( '%s%04d.bmp', Folder, Count ) ) );
        Count = Count + 1;
        if( 1 == f )
            Ac = Ac + Im;
        end
        PSin = PSin + Im * sin( Order * 2 * pi * n / N );
        PCos = PCos + Im * cos( Order * 2 * pi * n / N );
        
        clear Im;
    end
    
    Phase = pi + atan2( - PSin, - PCos );
    Bc = 2 / N * sqrt( PSin .* PSin + PCos .* PCos );
    Ac = Ac / N;
end

