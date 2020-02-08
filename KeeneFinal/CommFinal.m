clear all;
close all;
clc;

numIter = 12; %   
nSym = 1000;
SNR_Vec = 0:2:16;
lenSNR = length(SNR_Vec);

M = 16; 
bpSym = log2(M); %bits per symbol

nTrain = 100;

chan = 1;          % No channel
chan = [1 .2 .4]; % Somewhat invertible channel impulse response, Moderate ISI
%chan = [0.227 0.460 0.688 0.460 0.227]';   % Not so invertible, severe ISI

berVec = zeros(numIter, lenSNR);

parfor i = 1:numIter
    
    eqlms = dfe(7, 3, rls(0.99, 1));
    eqlms.SigConst = qammod(0:M-1,M,'UnitAveragePower',true);
    eqlms.ResetBeforeFiltering = 0;
    
    msg = randi([0 1], 1, nSym * M);
    rdata = reshape(msg, bpSym, []);
    sym = bi2de(rdata', 2); % make symbols
    
    for j = 1:lenSNR 
        
        tx = qammod(sym, M, 'UnitAveragePower',true);
        if isequal(chan, 1)
            txChan = tx;
        else
            txChan = filter(chan, 1, tx);
        end
        
        %txNoisy = awgn(txChan, SNR_Vec(j), 'measured');
        txNoisy = awgn(txChan, SNR_Vec(j) + 10*log10(bpSym)); % Add AWGN
        
        txEQ = equalize(eqlms, txNoisy, tx(1:nTrain));
        
        rx = qamdemod(txEQ, M, 'UnitAveragePower', true);
        rxMSG = de2bi(rx); 
        bits_rec = reshape(rxMSG', [], 1); %return bit stream
        
        
        [~, berVec(i,j)] = biterr(msg, bits_rec');
    end
end

ber = mean(berVec, 1);
semilogy(SNR_Vec, ber);

hold on;
berTheory = berawgn(SNR_Vec, 'qam', M, 'nondiff');
semilogy(SNR_Vec, berTheory);