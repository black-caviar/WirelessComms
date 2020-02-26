function frame = audio2frame(audio)
    % Convert integer audio matrix to valid 192 bit frames
    binAudio = de2bi(audio)';
    vecAudio = reshape(binAudio(:), 1, []);
    
    % Table 3.1.3.15.2-1 Forward Fundamental Channel Frame Structure 
    % Summary for Non-flexible Data Rates
    trimLen = floor(length(vecAudio)/172);
    trimAudio = vecAudio(1:trimLen*172);
    rawFrame = reshape(trimAudio, 172, []);
    padFrame = rawFrame;
    
    % 2.1.3.1.4.1.2 Frame Quality Indicator of Length 12
    poly = [1,1,1,1,1,0,0,0,1,0,0,1,1];
    
    crcgenerator = crc.generator(poly);
    crcFrame = generate(crcgenerator, padFrame);
    
    % 3.1.3.15.2.2 Forward Fundamental Channel Encoder Tail Bits
    frame = [crcFrame; zeros([8,length(crcFrame)])];
    frame = cast(frame, 'double');
end