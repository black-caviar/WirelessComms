function data = spaceTimeDec(rx, h)
    s = pskmod([0:1], 2);
    D = @(x,y) (x - y) .* (conj(x) - conj(y)); 
    ds0 = 0;
    ds1 = 0;
    
    if isequal(min(size(rx)), 1)
        r0 = rx(1:2:end);
        r1 = rx(2:2:end);
    
        ds0 = conj(h(1,:)) .* r0 + h(2,:) .* conj(r1);
        ds1 = conj(h(2,:)) .* r0 - h(1,:) .* conj(r1); 
        
    elseif isequal(min(size(rx)), 2)
        r0 = rx(1,1:2:end);
        r1 = rx(1,2:2:end);
        r2 = rx(2,1:2:end);
        r3 = rx(2,2:2:end);
        
        ds0 = conj(h(1,:)) .* r0 + h(2,:) .* conj(r1) + ...
              conj(h(3,:)) .* r2 + h(4,:) .* conj(r3);
        ds1 = conj(h(2,:)) .* r0 - h(1,:) .* conj(r1) + ...
              conj(h(4,:)) .* r2 - h(3,:) .* conj(r3);
          
    end
    
    [d0, ps0] = min(D(ds0, s'));
    [d1, ps1] = min(D(ds1, s'));
    
    rs0 = s(ps0);
    rs1 = s(ps1);

    signal = zeros(1,length(rx));
    signal(1:2:end) = rs0;
    signal(2:2:end) = rs1;
    
    data = signal;
end