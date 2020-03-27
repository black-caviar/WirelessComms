load('Rcvd_Teplitskiy.mat');
PN = [8 7 6 1 0];
B_RCOS = [0.0038 0.0052 -0.0044 -0.0121 -0.0023 0.0143 0.0044 -0.0385 ...
    -0.0563 0.0363 0.2554 0.4968 0.6025 0.4968 0.2554 0.0363 -0.0563 ...
    -0.0385 0.0044 0.0143 -0.0023 -0.0121 -0.0044 0.0052 0.0038];


%PN = 'x^8 + x^7 + x^6 + 1'
PNGEN = comm.PNSequence('Polynomial', PN, 'InitialConditions', 1, ...
    'SamplesPerFrame', 2^8-1, 'Mask', de2bi(1,8));
PNSEQ = PNGEN();

oPN = rectpulse(PNSEQ, 4);

rx = filter(B_RCOS, 1, Rcvd);

pcorr = correlate(oPN, rx');

plot([1:1020], pcorr);

[max,ind] = max(pcorr)

hadamard(8)

function rate = correlate(ref, test)
    
    rate = zeros(size(ref));
    for i = 1:length(ref)
        shift = circshift(ref,i);
        rate(i,:) = sum(shift.*test(1:length(ref),:));
    end

end