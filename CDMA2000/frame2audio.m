function intAudio = frame2audio(frame)
    vecAudio = reshape(frame(:), 1, []);
    padLen = ceil(length(vecAudio)/8)*8 - length(vecAudio)
    padAudio = [vecAudio, zeros([1,padLen])];
    
    binAudio = reshape(padAudio, 8, []);
    intAudio = bi2de(binAudio');
end