function PLCM_42 = maskPNLC(ENS)
    head = [1,1,0,0,0,1,1,0,0,0];
    % ESN - Electronic serial number [31:0]
    pVec = [0, 31, 22, 13, 4, 26, 17, 8, 30, 21, 12, 3, 25, 16, 7, 29, ... 
            20, 11, 2, 24, 15, 6, 28, 19, 10, 1, 23, 14, 5, 27, 18, 9];
    
    pENS = zeros([1,32]);
    pENS(1:32) = ENS(pVec+1);
    
    PLCM_42 = [head, pENS]; 
    % most significant bits at left \
    % 2.3.6.1.1 
    % C.S0005-D_v1.0__L3_031504
    % https://www.3gpp2.org/Public_html/Specs/C.S0005-D_v1.0__L3_031504.pdf
end


