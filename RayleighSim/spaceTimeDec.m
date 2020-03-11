function signal = spaceTimeDec(rx)
    r0 = rx(1:2:end);
    r1 = rx(2:2:end);
    
    ds0 = r0 + conj(r1);
    ds1 = r0 - conj(r1);   
    
    m = 2;
    s = pskmod([0:m-1], m);
    
    D = @(x,y) (x - y) .* (conj(x) - conj(y)); 

    [d0, ps0] = min(D(ds0, s'));
    [d1, ps1] = min(D(ds1, s'));
    
    rs0 = s(ps0);
    rs1 = s(ps1);

    signal = zeros(size(rx));
    signal(1:2:end) = rs0;
    signal(2:2:end) = rs1; 
end