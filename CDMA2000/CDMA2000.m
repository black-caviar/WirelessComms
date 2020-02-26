%% CDMA2000 X1 Voice Channel Simulation
clear all; close all; clc
%% Generate augmented short PN sequence 
% Short PN sequence polynomials 
PNI = 'x^15 + x^13 + x^9 + x^8 + x^7 + x^5 + 1';
PNQ = 'x^15 + x^12 + x^11 + x^10 + x^6 + x^5 + x^4 + x^3 + 1';

% Generate short PN sequence with offset 1
PNIGEN = comm.PNSequence('Polynomial', PNI, 'InitialConditions', 1, ...
    'SamplesPerFrame', 2^15-1, 'Mask', de2bi(1,15));
PNQGEN = comm.PNSequence('Polynomial', PNQ, 'InitialConditions', 1, ...
    'SamplesPerFrame', 2^15-1, 'Mask', de2bi(1,15));

% Augment PN sequence 
% Won't make use of masks here since it is inconventient to keep 
% regenerating the augmented PN sequence
% 
PNSEQ = [augmentPN(PNIGEN()), augmentPN(PNQGEN())];

%% Long PN Sequence 
PNL = [42, 35, 33, 31, 27, 26, 25, 22, 21, 19, 18, 17, 16, 10, 7, 6, 5, 3, 2, 1, 0];
PNLGEN = comm.PNSequence('Polynomial', PNL, 'InitialConditions', 1, ...
'VariableSizeOutput', true, 'MaskSource', 'Input Port', 'MaximumOutputSize', [2^31-1,1]);
% Electronic Serial Number 
ESN = de2bi(0,32);

%% Generate Walsh code 
H = hadamard(64);
W = abs((H-1)./2);
% Stretch Walsh matrix to length of PN sequence 
%longW = repmat(W, [1,length(PNSEQ)/length(W)]);

%% Convert audio to binary data 
% The audio file 'testfile' is a 64kbps audio file provided by Matlab 
% as a sample file. This is much greater than the data rate through 
% each CDMA2000 forward traffic channel, so the audio data will be 
% transmitted over 8 different audio channels both to demonstrate 
% the function of the orthogonal codes and to provide near-realtime 
% audio transmission 

testfile = 'testfile.wav';
% Convert 16-bit file provided by Matlab to 8 bits
%audio = audioread('speech_dft_8kHz.wav');
%audiowrite(testfile, audio, 2^13, 'BitsPerSample', 8);
  
intAudio = audioread(testfile, 'native');
audioFrame = audio2frame(intAudio);

%% Perform convolutional encoding on the audio frames 
% 3.1.3.1.5.1.4 Rate 1/2 Convolutional Code
trellis = poly2trellis(9, [753, 561]);

% reset the endcoder to 0 at every new frame,
% 3.1.3.15.3 Forward Fundamental Channel Convolutional Encoding
convFrame = zeros(384,length(audioFrame));
for i = 1:length(audioFrame)
    convFrame(:,i) = convenc(audioFrame(:,i)', trellis)';
end

%% Interleaving
% Table 3.1.3.1.8-1. Interleaver Parameters
m = 6;
J = 6;

% 3.1.3.1.8.1.1 Bit-Reversal Order Interleaver 
A = @(i) 2^m * mod(i,J) + bi2de(flip(de2bi(floor(i/J),m)));

interleavedFrame = zeros(size(convFrame));
interleaveMap = zeros(length(convFrame), 1);

for i = 1:384
    interleavedFrame(A(i-1)+1,:) = convFrame(i,:); 
    interleaveMap(A(i-1)+1) = i-1;
end

%% Modulate with long PN code 
% Split voice channel into 8 channel streams
% PN chips are same of the same rate as the data 
reset(PNLGEN);
voiceChans = zeros(384 * length(interleavedFrame)/8, 8);
scrambleChans = zeros(size(voiceChans));
bitsLPN = PNLGEN(maskPNLC(ESN), 64*length(scrambleChans));
deciLPN = bitsLPN(1:64:end)';
    
for i = 1:8
    voiceChans(:,i) = reshape(interleavedFrame(:,i:8:end), [], 1);
end
scrambleChans = cast(xor(deciLPN', voiceChans), 'double');

%% Encode with Walsh Code 
% Increase code rate to 1.2288 MCPS 
% 1228800/19200 = 64
% 64 Chips per bit are used to spread this particular transmission 
expandedChans = rectpulse(scrambleChans, 64);
spreadCodeW = zeros(size(expandedChans));
for i = 0:length(scrambleChans)-1
    varRange = 64*i+1:64*i+64;
    % perfectly acceptable if random selection of Walsh code
    spreadCodeW(varRange,:) = xor(W([10:17],:)', expandedChans(varRange,:));
end

%% Modulate to baseband
% Map bits to symbols 
mappedSignal = qammod(spreadCodeW, 2);
unifiedSignal = sum(mappedSignal,2);

BS_OFFSET = 300;
SSEQ1 = circshift(PNSEQ, BS_OFFSET * 64);

longshortPN = repmat(SSEQ1, [length(unifiedSignal)/length(PNSEQ),1]);
extendPNSEQ = qammod(longshortPN,2);
basebandSignal = unifiedSignal .* extendPNSEQ;
complexSignal = basebandSignal(:,1) + 1i*basebandSignal(:,2);

%% Add pilot channel
% Chose some offset for the station sequence 


% The Walsh encoding for the pilot channel is all 0 so I won't apply it
pilotTran = bi2de(longshortPN);
pilotChan = pskmod(pilotTran, 4, pi/4, 'gray');

% Generate some other pilot channel at a lower power
SSEQ2 = circshift(longshortPN, 100*64);
pilotTran2 = bi2de(SSEQ2);
pilotChan2 = 0.8*pskmod(pilotTran2, 4, pi/4, 'gray');

% And another one
SSEQ3 = circshift(longshortPN, 400*64);
pilotTran3 = bi2de(SSEQ3);
pilotChan3 = 0.5*pskmod(pilotTran3, 4, pi/4, 'gray');

combSignal = complexSignal + pilotChan + pilotChan2 + pilotChan3;
%% Transmit the baseband 
% Raw constellations
scatterplot(combSignal, 1, 0, 'b*');
title("Constellation at Transmitter Output");

chan = [.8,.4,.2];
channelSignal = filter(chan, 1, combSignal);
%channelSignal = combSignal;
noisySignal = awgn(channelSignal, 1);
%noisySignal = combSignal;

scatterplot(noisySignal, 1, 0, 'b*');
title("Constellation at Receiver Input");
%% Extract Pilot 
pilotRX = pskdemod(noisySignal, 4, pi/4, 'gray');
pnRX = de2bi(pilotRX);
pCorr = correlate(PNSEQ, pnRX);
figure;
plot(pCorr);
title("Base Station Pilot Channel Power");
legend('I Code', 'Q Code');

[~,peak] = max(pCorr);
StationOffset = mean(peak)/64

%% Decode spreading codes
test = [real(complexSignal), imag(complexSignal)];
iqRX = [real(noisySignal), imag(noisySignal)];
rawSignal = mean(iqRX .* extendPNSEQ, 2);
recoveredRX = qamdemod(codeCC(rawSignal, H(10:17,:)')/64,2);
descrambledRX = xor(recoveredRX, deciLPN');
interleaveRX = zeros(size(interleavedFrame));
for i = 1:8 
    interleaveRX(:,i:8:end) = reshape(descrambledRX(:,i), 384, []);
end

% interpolate codes into interleaved data
% interleaving is performed on a frame-by-frame basis
deinterleavedRX = zeros(size(interleaveRX));
for i = [1:384]
    h = interleaveMap(i);
    deinterleavedRX(h+1,:) = interleaveRX(i,:); 
end

% good up to convolutional encoder

%% Undo convolutional coding

frameRX = zeros(192, length(deinterleavedRX));
for i = 1:length(frameRX)
    % frames of data have been recovered
    frameRX(:,i) = vitdec(deinterleavedRX(:,i)', trellis, 10, 'trunc', 'hard')';
end

%% Transform frames to audio 

[decodeFrame, errors] = frame2bin(frameRX);
newAudio = frame2audio(decodeFrame);

figure;
plot(errors);
title("Transmission errors encountered");








