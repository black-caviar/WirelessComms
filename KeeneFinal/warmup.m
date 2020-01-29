%% Comms Final Project Warmup
clear all;close all;clc

numIter = 1000;  % Num sim iterations 
nSym = 1000;    % The number of symbols per packet
SNR_Vec = 0:2:16;
lenSNR = length(SNR_Vec);
nTrain = 100; % Number of training bits for equalizer 

M = 16;        % The M-ary number
bpSym = log2(M); % Bits per symbol

chan = 1;      % No channel
chan = [1 .2 .4]; % Somewhat invertible channel impulse response, Moderate ISI
%chan = [0.227 0.460 0.688 0.460 0.227]';   % Not so invertible, severe ISI

%% Transmission With and Without Equalization

% Preallocated error vector
berVec = zeros(numIter, lenSNR);
berVecNoEQ = berVec;

parfor i = 1:numIter
    % equalizer declaration here for parallelization
    %eqlms = dfe(10,5,lms(0.005));
    % value chosen to minimize training bits
    eqlms = dfe(7, 3, rls(0.99, 1));
    eqlms.SigConst = qammod(0:M-1,M,'UnitAveragePower',true);
    eqlms.ResetBeforeFiltering = 0;
    
    bits = randi([0 1], nSym*M, 1); % generate data
    for j = 1:lenSNR
        % encode, transmit, and receive data               
        rdata = reshape(bits, bpSym, []);
        sym = bi2de(rdata', 2); % make symbols
    
        % encode symbols
        tx = qammod(sym, M, 'InputType', 'integer', 'UnitAveragePower',true);
        
        if isequal(chan,1)
            txChan = tx; % makes things faster if no channel
        else
            txChan = filter(chan,1,tx);  % Apply the channel.
        end    
    
        txNoisy = awgn(txChan, SNR_Vec(j) + 10*log10(bpSym)); % Add AWGN
        txEQ = equalize(eqlms, txNoisy, tx(1:nTrain)); % Equalize the channel
        rx = qamdemod(txEQ, M, 'UnitAveragePower', true); % Decode symbols
        rxMSG = de2bi(rx); 
        dataEQ = reshape(rxMSG', [], 1); %return bit stream
        [~, berVec(i,j)] = biterr(dataEQ, bits);
        
        rxNoEQ = qamdemod(txNoisy, M, 'UnitAveragePower', true); % Decode symbols
        rxMSGNoEQ = de2bi(rxNoEQ); 
        data = reshape(rxMSGNoEQ', [], 1);
        [~, berVecNoEQ(i,j)] = biterr(data, bits);
    end
end

ber = mean(berVec,1); % Average out 
berNoEQ = mean(berVecNoEQ, 1);
semilogy(SNR_Vec, ber)
hold on;
semilogy(SNR_Vec, berNoEQ)
%value of ber at SNR of 12
fprintf('Value of ber at SNR = 12: %d', ber(7))
% Compute the theoretical BER for this scenario
berTheory = berawgn(SNR_Vec,'qam',M,'nondiff');
semilogy(SNR_Vec,berTheory,'r')
title('Unencoded Transmision');
xlabel('SNR');
ylabel('BER');
legend('BER With Equalization', 'BER Without Equalization', ...
    'Theoretical BER', 'Location', 'southwest');

%% Transmission With Encoding

berVecE = zeros(numIter, lenSNR);

%enc157 = comm.BCHEncoder(15,7);
%dec157 = comm.BCHDecoder(15,7);
 
trellis12 = poly2trellis(5,[37 33], 37);
trellis23 = poly2trellis([5 4],[23 35 0; 0 5 13]); %very very close
% this 2/3 code is a better fit than the 1/2 code

parfor i = 1:numIter
    bits = randi([0 1], 666*M, 1); 
    code = convenc(bits, trellis23);
    %code = enc157(bits);
    %equalizer declaration here for parallelization
    %eqlms = dfe(10,5,lms(0.01));
    eqlms = dfe(7, 3, rls(0.99, 1));
    eqlms.SigConst = qammod(0:M-1,M,'UnitAveragePower',true);
    eqlms.ResetBeforeFiltering = 0;
    
    for j = 1:lenSNR
        
        % encode, transmit, and receive data               
        rdata = reshape(code, bpSym, []);
        sym = bi2de(rdata', 2); % make symbols
    
        % encode symbols
        tx = qammod(sym, M, 'InputType', 'integer', 'UnitAveragePower',true);
        
        if isequal(chan,1)
            txChan = tx; % makes things faster if no channel
        else
            txChan = filter(chan,1,tx);  % Apply the channel.
        end    
    
        txNoisy = awgn(txChan, SNR_Vec(j) + 10*log10(bpSym)); % Add AWGN
        txEQ = equalize(eqlms, txNoisy, tx(1:nTrain)); % Equalize the channel
        rx = qamdemod(txEQ, M, 'UnitAveragePower', true); % Decode symbols
        rxMSG = de2bi(rx); 
        dataEQ = reshape(rxMSG', [], 1); %return bit stream
        
        decode = vitdec(dataEQ, trellis23, 34, 'trunc', 'hard');
        %decode = dec157(rcv);
        [~, berVecE(i,j)] = biterr(decode, bits);
    end
end

% Bitrate Calculation
% In order to keep the number of symbols below 1000, the number of bits
% sent was adjusted to 2/3rds of 1000*M Only 999 symbols are sent.
% 
% Given 999 packets, 100 are lost to the channel equalizer
% The remaining 899 symbols are encoded with a rate 2/3 convolutional code
% which means that 1/3 of the bits contained by those symbols are parity
% bits. Those remaining 899 symbols must therefore contain 4,795 parity
% bits and 9,589 data bits. Out of a total 15,984 bits sent, 9,589 are 
% usable data. Taking the time to transmit 1 symbol to be the unit of time,
% the bit rate is 9,589/999 = 9.5986 bit/symbol time.

berEnc = mean(berVecE,1);
fprintf('Value of ber at SNR = 12: %d', berEnc(7))
figure;
semilogy(SNR_Vec, berEnc);
hold on
semilogy(SNR_Vec,berTheory,'r');
legend('BER With Encoding', 'Theoretical BER', 'Location', 'southwest')