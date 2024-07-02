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
% for i = 1:3
%     [~,idx] = max(abs( mRwc( i, : ) ));
%     if( mRwc( i, idx ) < 0 )
%         mRwc(i,:) = - mRwc(i,:);
%         mAc(:,i) = - mAc(:,i);
%         vtwc(i) = -vtwc(i);
%     end
% end

mAc = mAc ./ abs(mAc( end ));
end

