%% CDMA2000 X1 Voice Channel Simulation

PN_Offset = 1;

%Short PN sequence polynomials 
PNI = 'x^15 + x^13 + x^9 + x^8 + x^7 + x^5 + 1';
PNQ = 'x^15 + x^12 + x^11 + x^10 + x^6 + x^5 + x^4 + x^3 + 1';

%Generate short PN sequence with offset PN_Offset
PNIGEN = comm.PNSequence('Polynomial', PNI, 'InitialConditions', PN_Offset, 'SamplesPerFrame', 2^15-1, 'MaskSource', 'Input Port');
PNQGEN = comm.PNSequence('Polynomial', PNQ, 'InitialConditions', PN_Offset, 'SamplesPerFrame', 2^15-1, 'MaskSource', 'Input Port');

PNISEQ = PNIGEN(de2bi(1,15));
PNQSEQ = PNQGEN(de2bi(1,15)); 

SPNSEQ = [PNISEQ, PNQSEQ];


%%
zCount = 0;
zCountQ = 0;
for i = 1:length(SPNSEQ) 
    if (PNISEQ(i) == 0)
        zCountI = zCountI + 1;
    else 
        zCountI = 0;
    end
    
    if (PNQSEQ(i) == 0)
        zCountQ = zCountQ + 1;
    else 
        zCountQ = 0;
    end
    
    if (zCountI == 14)
        disp 'found it 1'
        disp(i)
        PNISEQ = [PNISEQ(1:i-1); 0; PNISEQ(i:end)];
    end
    
    if (zCountQ == 14)
        disp 'found it 2'
        disp(i)
        PNQSEQ = [PNQSEQ(1:i-1); 0; PNQSEQ(i:end)];
    end
end


%% Long PN Sequence 
PNL = [42, 35, 33, 31, 27, 26, 25, 22, 21, 19, 18, 17, 16, 10, 7, 6, 5, 3, 2, 1, 0];


%%

%Walsh = comm.WalshCode('Length', 64, 'Index', 1, 'SamplesPerFrame', 64);
%useless 

W = hadamard(64);

W(1,:)

%% Generate and encode the pilot channel sequence go

pilotTran = PNISEQ + 2*PNQSEQ;
pilotChan = pskmod(pilotTran, 4, pi/4, 'gray');

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

trellis = poly2trellis(9, [753, 561])
% split the streams 

vChan = cell(8,1);
for i = 1:8
    dataStream = audioFrame(:,i:8:end);
    bitStream = reshape(dataStream, 1, []);
    encStream = convenc(bitStream, trellis);
    vChan{i} = reshape(encStream, 384, []);
end


%% Generate and encode voice channel 
    
%% FFF
X = dct(audio2);
[XX,ind] = sort(abs(X),'descend');

need = 1;
while norm(X(ind(1:need)))/norm(X)<0.99
   need = need+1;
end

xpc = need/length(X)*100;
X(ind(need+1:end)) = 0;
xx = idct(X);
soundsc(xx, 2^13)

function frame = audio2frame(audio)
    % Convert integer audio matrix to valid 192 bit frames
    binAudio = de2bi(audio)';
    vecAudio = reshape(binAudio(:), 1, []);
    
    trimLen = floor(length(vecAudio)/171);
    trimAudio = vecAudio(1:trimLen*171);
    rawFrame = reshape(trimAudio, 171, []);
    padFrame = [zeros([1,length(rawFrame)]); rawFrame];
    
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
    frame = [crcFrame; zeros([8,length(crcFrame)])];
    frame = cast(frame, 'double');
end

function [rawFrame, errorFrames] = frame2bin(frame)
    %remove padding from end 
    frame(185:192,:) = [];
    
    poly = [1,1,1,1,1,0,0,0,1,0,0,1,1];
    crcdetect = crc.detector(poly)
    
    [rawFrame, errorFrames] = detect(crcdetect, frame);
    rawFrame(1,:) = [];
end

function intAudio = frame2audio(frame)
    vecAudio = reshape(frame(:), 1, []);
    padLen = ceil(length(vecAudio)/8)*8 - length(vecAudio)
    padAudio = [vecAudio, zeros([1,padLen])];
    
    binAudio = reshape(padAudio, 8, []);
    intAudio = bi2de(binAudio');
end