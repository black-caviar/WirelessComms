function msg = decode(data, h)
    frames = reshape(data, 255, []);
    cutframe = frames(1:192,:);
    charsegs = reshape(cutframe, 64, []);    
    lcode = rectpulse(h, 8);
    
    decode = lcode' .* charsegs;
    %qam demod should not be there
    bits = qamdemod(intdump(decode, 8),2);
    
    msg = char(bi2de(bits'));
end

