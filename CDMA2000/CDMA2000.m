%% CDMA2000 X1 Voice Channel Simulation
clear all; close all; clc
%% Generate augmented short PN sequence 
% Short PN sequence polynomials 
PNI = 'x^15 + x^13 + x^9 + x^8 + x^7 + x^5 + 1';
PNQ = 'x^15 + x^12 + x^11 + x^10 + x^6 + x^5 + x^4 + x^3 + 1';

% Generate short PN sequence with offset 1
PNIGEN = comm.PNSequence('Polynomial', PNI, 'InitialConditions', 1, 'SamplesPerFrame', 2^15-1, 'MaskSource', 'Input Port');
PNQGEN = comm.PNSequence('Polynomial', PNQ, 'InitialConditions', 1, 'SamplesPerFrame', 2^15-1, 'MaskSource', 'Input Port');

PNISEQ = PNIGEN(de2bi(1,15));
PNQSEQ = PNQGEN(de2bi(1,15)); 

% Augment PN sequence 
zCount = [0,0];
for i = 1:2^15-1 
    if (PNISEQ(i) == 0)
        zCount(1) = zCount(1) + 1;
    else 
        zCount(1) = 0;
    end
    
    if (PNQSEQ(i) == 0)
        zCount(2) = zCount(2) + 1;
    else 
        zCount(2) = 0;
    end
    
    if (zCount(1) == 14)
        disp 'augmented I sequence at '
        disp(i)
        PNISEQ = [PNISEQ(1:i-1); 0; PNISEQ(i:end)];
    end
    
    if (zCount(2) == 14)
        disp 'augmented Q sequence at '
        disp(i)
        PNQSEQ = [PNQSEQ(1:i-1); 0; PNQSEQ(i:end)];
    end
    % too lazy to short circuit evaluation, runs fast anyway 
end

PNSEQ = [PNISEQ,PNQSEQ];
%% Long PN Sequence 
PNL = [42, 35, 33, 31, 27, 26, 25, 22, 21, 19, 18, 17, 16, 10, 7, 6, 5, 3, 2, 1, 0];


%% Generate Walsh code 

W = hadamard(64);
% Stretch Walsh matrix to length of PN sequence 
longW = repmat(W, [1,length(PNSEQ)/length(W)]);

%% Generate and encode the pilot channel sequence
% Chose some offset for the station sequence 
stationN = 200;
SSEQ1 = circshift(PNSEQ, stationN * 64);
% The Walsh encoding for the pilot channel can be ignored if desired
%pilotTran = SSEQ1(:,1)' .* longW(1,:) + 2*SSEQ1(:,2)' .* longW(1,:);
pilotTran = bi2de(SSEQ1);
pilotChan = pskmod(pilotTran, 4, pi/4, 'gray');

SSEQ2 = circshift(PNSEQ, 70 * 64);
pilotTran2 = bi2de(SSEQ2);
pilotChan2 = 0.8*pskmod(pilotTran2, 4, pi/4, 'gray');

%% Encode Voice Audio 
% This is a crude method of compressing audio that is not representative
% of the vocoders used in 

testfile = 'testfile.wav';

%audio = audioread('speech_dft_8kHz.wav');
audio1 = audioread('SpeechDFT-16-8-mono-5secs.wav');
audiowrite('testfile.wav', audio1, 2^13, 'BitsPerSample', 8);
audio2 = audioread(testfile);
%play sound
  
intAudio = audioread(testfile, 'native');
audioFrame = audio2frame(intAudio);

[decodeFrame, errors] = frame2bin(audioFrame);
newAudio = frame2audio(decodeFrame);

%% Perform convolutional encoding on the audio frames 

% 3.1.3.1.5.1.4Rate 1/2 Convolutional Code
trellis = poly2trellis(9, [753, 561])
% split the streams 

% reset the endcoder to 0 at every new frame,
% reshaping can be done later? Or is it inconvenient 
% 3.1.3.15.3Forward Fundamental Channel Convolutional Encoding
vChan = cell(8,1);
for i = 1:8
    dataStream = audioFrame(:,i:8:end);
    bitStream = reshape(dataStream, 1, []);
    encStream = convenc(bitStream, trellis);
    vChan{i} = reshape(encStream, 384, []);
end

bitStream = reshape(audioFrame, 1, []);
encStream = convenc(bitStream, trellis);
convFrame = reshape(encStream, 384, []);

%% Interleaving
% Table 3.1.3.1.8-1. Interleaver Parameters

m = 6;
J = 6;

A = @(i) 2^m * mod(i,J) + bi2de(flip(de2bi(floor(i/J),m)));

%convFrame = [0:47]';
interleavedFrame = zeros(size(convFrame));
deinterleavedFrame = zeros(size(convFrame));
interleaveMap = zeros(length(convFrame), 1);

for i = [1:384]
    interleavedFrame(A(i-1)+1,:) = convFrame(i,:); 
    interleaveMap(A(i-1)+1) = i-1;
end

% Deinterleaving has been a success here
for i = [1:384]
    h = interleaveMap(i);
    deinterleavedFrame(h+1,:) = interleavedFrame(i,:); 
end

%% Generate and encode voice channel 
    
%% Transmit 

%out = awgn(pilotChan, 10);
out = awgn(pilotChan + pilotChan2, 10);
%figure;
scatterplot(out, 1, 0, 'b*');

%% Receive 

%refSEQ = pskmod(bi2de(PNSEQ), 4, pi/4, 'gray');

rx = pskdemod(out, 4, pi/4, 'gray');
rxPN = de2bi(rx);
%iCorr = xcorr(PNISEQ, rxPN(:,1));
%qCorr = xcorr(PNQSEQ, rxPN(:,2));
%iCorr = cconv(PNISEQ, rxPN(:,1));

%iCorr = correlate(PNSEQ, rxPN);
iCorr = correlate(PNSEQ, rxPN);
figure;
plot(iCorr);
legend;
figure;
plot(correlate(PNSEQ, SSEQ2));

function frame = audio2frame(audio)
    % Convert integer audio matrix to valid 192 bit frames
    binAudio = de2bi(audio)';
    vecAudio = reshape(binAudio(:), 1, []);
    
    trimLen = floor(length(vecAudio)/172);
    trimAudio = vecAudio(1:trimLen*172);
    rawFrame = reshape(trimAudio, 172, []);
    %padFrame = [zeros([1,length(rawFrame)]); rawFrame];
    padFrame = rawFrame;
    
    %trimLen = floor(length(audio)*8/168)*21;
    %trimAudio = audio(1:trimLen);
    %binAudio = de2bi(trimA udio)';
    
    % I could fit 171 bits worth of audio into every frame, but that 
    % is a strange and unweildy value. Use 168 bits instead and pad 
    %rawFrame = cast(reshape(binAudio(:),168,[]), 'double');
    %padFrame = [zeros([1,length(rawF = audio2frame(intAudio);
%nrame)]); rawFrame; zeros([3,length(rawFrame)])];
    
    poly = [1,1,1,1,1,0,0,0,1,0,0,1,1];
    crcgenerator = crc.generator(poly)
    
    crcFrame = generate(crcgenerator, padFrame);
    % 3.1.3.15.2.2 Forward Fundamental Channel Encoder Tail Bits
    frame = [crcFrame; zeros([8,length(crcFrame)])];
    frame = cast(frame, 'double');
end

function [rawFrame, errorFrames] = frame2bin(frame)
    %remove padding from end 
    frame(185:192,:) = [];
    
    % Figure 3.1.3.1.4.1.2-1
    poly = [1,1,1,1,1,0,0,0,1,0,0,1,1];
    crcdetect = crc.detector(poly)
    
    [rawFrame, errorFrames] = detect(crcdetect, frame);
    %rawFrame(1,:) = [];
end

function intAudio = frame2audio(frame)
    vecAudio = reshape(frame(:), 1, []);
    padLen = ceil(length(vecAudio)/8)*8 - length(vecAudio)
    padAudio = [vecAudio, zeros([1,padLen])];
    
    binAudio = reshape(padAudio, 8, []);
    intAudio = bi2de(binAudio');
end

function rate = correlate(ref, test)
    if (size(ref) ~= size(test))
        error("Input arguments must have same dimensions");
    end
    rate = zeros(size(test));
    for i = 1:length(test)
        shift = circshift(ref,i);
        rate(i,:) = sum(shift.*test);
    end

end