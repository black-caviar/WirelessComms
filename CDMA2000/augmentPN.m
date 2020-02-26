function augmentedPN = augmentPN(PN) 
    zcount = 0;
    for i = 1:length(PN)
        if (PN(i) == 0)
            zcount = zcount + 1;
        else 
            zcount = 0;
        end
        
        if (zcount == 14)
            disp 'augmented sequence at '
            disp(i)
            PN = [PN(1:i-1); 0; PN(i:end)];
            augmentedPN = circshift(PN, length(PN)-i-1);
            return;
        end
    end
end