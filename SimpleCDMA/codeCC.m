function data = codeCC(signal, codes)
    correlationMatrix = signal .* repmat(codes, [length(signal)/length(codes) ,1]);
    dataLen = length(signal)/8;
    data = zeros([dataLen, min(size(codes))]);
    for i = 1:dataLen
        ran = (i-1)*8+1:(i-1)*8+8;
        data(i,:) = sum(correlationMatrix(ran,:),1);
    end

end