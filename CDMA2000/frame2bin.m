function [rawFrame, errorFrames] = frame2bin(frame)
    %remove padding from end 
    frame(185:192,:) = [];
    
    % Figure 3.1.3.1.4.1.2-1
    poly = [1,1,1,1,1,0,0,0,1,0,0,1,1];
    crcdetect = crc.detector(poly);
    
    [rawFrame, errorFrames] = detect(crcdetect, frame);
    %rawFrame(1,:) = [];
end