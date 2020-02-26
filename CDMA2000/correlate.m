function rate = correlate(ref, test)
    
    rate = zeros(size(ref));
    for i = 1:length(ref)
        shift = circshift(ref,i);
        rate(i,:) = sum(shift.*test(1:length(ref),:));
    end

end