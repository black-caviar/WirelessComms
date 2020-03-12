function signal = spaceTimeDec(rx, order)
    s = pskmod([0:m-1], m);
    if order == 2
        r0 = rx(1:2:end);
        r1 = rx(2:2:end);
    
        ds0 = r0 + conj(r1);
        ds1 = r0 - conj(r1);   
        
        D = @(x,y) (x - y) .* (conj(xz) - conj(y)); 

        [d0, ps0] = min(D(ds0, s'));
        [d1, ps1] = min(D(ds1, s'));
    
        rs0 = s(ps0);
        rs1 = s(ps1);

        signal = zeros(size(rx));
        signal(1:2:end) = rs0;
        signal(2:2:end) = rs1; 
    end
    
    if order == 4
        
        r0 = rx(1,1:2:end);
        r1 = rx(1,2:2:end);
        r2 = rx(2,1:2:end);
        r3 = rx(2,2:2:end);
        
        ds0 =  
        
    end
end