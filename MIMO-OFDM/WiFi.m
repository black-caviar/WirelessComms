%% Simulate 802.11a OFDM symbols
clear
close all
clc
%% 
DLEN = 1e3;
%DLEN = 1;

%% Generate Pilot Sequence 
PN = [7, 4, 0];
PNGEN = comm.PNSequence('Polynomial', PN, 'InitialConditions', [1,1,1,1,1,1,1], ...
    'VariableSizeOutput', true, 'Mask', de2bi(64,7), 'MaximumOutputSize', [1e6,1]);
    %'SamplesPerFrame', 2^7-1, 'Mask', de2bi(64,7));
PNSEQ = flipud(PNGEN(DLEN));
% The data scrambler sequence defined in 17.3.5.4 of the 802.11a standard
pilot = pskmod(PNSEQ, 2);

%% Generate bit data
M = 4;
bits = randi([0 1], log2(M), 48*DLEN);
data = reshape(bi2de(bits'), [], 48);
NBITS = prod(size(bits));
%% Generate OFDM Bursts 
enc = pskmod(data, M, pi/4, 'gray');
[dataframe, refdata] = fmapt(enc, pilot);
datasig = reshape(dataframe, [], 1);

%% Transmit Data

filt1 = [1,.2,.4];
%filt1 = 1;
tran = filter(filt1,1,datasig);
rx = tran + wgn(length(tran), 1,-45, 'complex');
framerx = reshape(rx, [], 80);
recsym = unmap(framerx);
recdata = pskdemod(recsym,M, pi/4, 'gray');
scatterplot(recsym(:,1))
recbits = de2bi(reshape(recdata, 1, []))';
sum(sum(recbits ~= bits))/NBITS
%% Other Transmit Data 

fsamp = 20e6;
fsamp = 1e3;

channel = comm.RayleighChannel(...
    'SampleRate',fsamp, ...
    'MaximumDopplerShift',20, ...
    'PathGainsOutputPort', true);

[rxSig, pathgain] = channel(datasig);
framerx = reshape(rxSig, [], 80);
recsym = unmap(framerx);
recdata = pskdemod(recsym,M, pi/4, 'gray');
scatterplot(recsym(:,1))
recbits = de2bi(reshape(recdata, 1, []))';
sum(sum(recbits ~= bits))/NBITS

%% Recovery
datarec = reshape(datasig, [], 80);
% save me...
function data = unmap(rx) 
    body = rx(:,17:80);
    mixeddata = fft(body);
    
    h1 = mixeddata(:,1:33);
    
    data3 = h1(:,2:7);
    data4 = h1(:,9:21);
    data5 = h1(:,23:27);
    
    X = mixeddata(:,34:end);
    h2 = X(:,6:end);
    h2 = fliplr(h2);
    data0 = h2(:,1:5);
    data1 = h2(:,7:19);
    data2 = h2(:,21:end);
    
    data = [data0,data1,data2,data3,data4,data5];
    %A = qamdemod(data, 4);
    %B = qamdemod(raw, 4);
end

function [frame,refdata] = fmapt(data, pilot)
    data0 = data(:,1:5);
    data1 = data(:,6:18);
    data2 = data(:,19:24);
    data3 = data(:,25:30);
    data4 = data(:,31:43);
    data5 = data(:,44:48);
    
    l = length(pilot);
    
    h1 = [zeros(l,1), data3, pilot, data4, -pilot, data5, zeros(l,6)];
    h2 = [zeros(l,5), fliplr([data0, pilot, data1, pilot, data2])];
    %size(h1)
    %size(h2)
    plot(fftshift(mean(abs([h1,h2]))));
    title("OFDM Symbol Before Cyclic Prefix");
    refdata = [h1,h2];
    td = ifft(refdata);
    frame = [td(:,end-15:end), td];
    %frame = [h1, h2];
    %frame = [[0 0 0 0 0 0], data0, pilot, data1, pilot, data2, 0, data3, ...
    %    pilot, data4, -pilot, data5, [0 0 0 0 0 0]];
    %unclear why pilot 4 is negative. To avoid symmetry confusion?
end