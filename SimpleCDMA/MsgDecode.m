clear all; close all; clc

set(0, 'defaultAxesFontSize', 15);
load('Rcvd_Teplitskiy.mat');
PN = [8 7 6 1 0];
B_RCOS = [0.0038 0.0052 -0.0044 -0.0121 -0.0023 0.0143 0.0044 -0.0385 ...
    -0.0563 0.0363 0.2554 0.4968 0.6025 0.4968 0.2554 0.0363 -0.0563 ...
    -0.0385 0.0044 0.0143 -0.0023 -0.0121 -0.0044 0.0052 0.0038];
H = hadamard(8);

% Known good PN implementation 
PNGEN = comm.PNSequence('Polynomial', PN, 'InitialConditions', 1, ...
    'SamplesPerFrame', 2^8-1, 'Mask', de2bi(1,8));
PNSEQ = PNGEN();

% Oversample PN sequence 
oPN = zeros(1, 4*length(PNSEQ));
oPN(1:4:end) = pskmod(PNSEQ,2);

% Complete raised cosine filter
rx = filter(B_RCOS, 1, Rcvd);

% Plot cross correlation
%mycorr = abs(xcorr(oPN, rx'));
initcorr = abs(filter(fliplr(oPN), 1, rx));
plot(20*log10(initcorr), 'Linewidth', 3)
title("Cross Correlation of Received and Known m sequence");
ylabel("Degree of Correlation (dB)");
xlabel("m Sequence Offset");
ylim([0,50]);

% Locate PN offset
[~,ind] = max(initcorr);
pnShift = round(mod(ind, 1020)/4);
%pnShift = -144;

% Downsample received signal, determined by best cross correlation results
rxds = rx(1:4:end);

% Shift and encode PN sequence 
rxPN = pskmod(circshift(PNSEQ, pnShift),2);
ncorr = abs(xcorr(rxPN, rxds));
figure;
plot(20*log10(ncorr), 'Linewidth', 3)
title("Cross Correlation of Received and Shifted m sequence");
ylabel("Degree of Correlation (dB)");
xlabel("m Sequence Offset");
ylim([0,50]);

scatterplot(rx);
title("Constellation Before Despreading");

rxdec = rxds .* repmat(rxPN', 1, length(rxds)/length(rxPN));
scatterplot(rxdec);
title("Constellation After Despreading");

% Manipulate data into frames
rxframe = reshape(rxdec, 255, []);
rxtrim = rxframe(7:192+6,:);
pilot = intdump(rxtrim, 8);
UPC = scatterplot(reshape(pilot,1,[]),1,0, 'g.');
hold on
scatterplot(mean(pilot),1,0,'r.',UPC);
set(findobj(UPC.Children(1).Children, 'type', 'line'), 'MarkerSize', 20);
legend('Raw Pilot', 'Mean Pilot');
title("Uncompensated Pilot Channel");

% Compute frequency adjustment from pilot
adj = 1./mean(pilot);
unphased = rxtrim .* adj;

charsegs = reshape(unphased, 64, {});
% Remove pilot from data, undo Walsh code
walshchars = repmat(H(6,:)',8,1) .* (charsegs-1);
chars = intdump(walshchars, 8);
% Remove areas of junk data from result
blanks = mean(abs(chars)) < .5; 
chars(:,blanks) = 0;
char(bi2de(pskdemod(chars, 2)'))'


%% Finding the Frequency and Phase Offset

f = 31 * 2 * pi;
t = linspace(0, length(Rcvd)/1e6, length(Rcvd));
s = sin(f * t + 10*(2*pi)/99);

figure;
plot(real(xcorr(oPN, rx')));
hold on;
plot(s*255);
hold off;
xlim([0,length(rx)]);
title("Fitting Frequency and Phase Offsets");
xlabel("m Sequence Offset");
ylabel("Degree of Correlation (dB)");