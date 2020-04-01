clear all; close all; clc

load('Rcvd_Teplitskiy.mat');
PN = [8 7 6 1 0];
B_RCOS = [0.0038 0.0052 -0.0044 -0.0121 -0.0023 0.0143 0.0044 -0.0385 ...
    -0.0563 0.0363 0.2554 0.4968 0.6025 0.4968 0.2554 0.0363 -0.0563 ...
    -0.0385 0.0044 0.0143 -0.0023 -0.0121 -0.0044 0.0052 0.0038];


%PN = 'x^8 + x^7 + x^6 + 1'
PNGEN = comm.PNSequence('Polynomial', PN, 'InitialConditions', 1, ...
    'SamplesPerFrame', 2^8-1, 'Mask', de2bi(1,8));
PNSEQ = PNGEN();
bpPN = rectpulse(pskmod(PNSEQ, 2), 4);

oPN = rectpulse(PNSEQ, 4);

rx = filter(B_RCOS, 1, Rcvd);

pcorr = correlate(oPN, real(rx'));
%pcorr = correlate(rectpulse(bpPN,4), rx');
figure; plot([1:1020], pcorr);
figure; plot(real(xcorr(oPN, rx')));
[max,ind] = max(pcorr)

%%

%plot(abs(fftshift(fft(rx))));


%%



rxPN = circshift(oPN, ind);

pcorr = correlate(rxPN, rx');
%pcorr = correlate(rectpulse(bpPN,4), rx');

figure; plot([1:1020], real(pcorr));
figure; plot(real(xcorr(rxPN, rx')));

figure;
scatterplot(rx);

hadamard(8)

rxDEPN = repmat(circshift(bpPN, ind), length(rx)/length(bpPN), 1)' .* rx;

%%
close all;
f = 31 * 2 * pi;
t = linspace(0, length(Rcvd)/1e6, length(Rcvd));
s = sin(f * t + 1.25*pi);

figure; plot(real(xcorr(rxPN, rx')));
hold on;
plot(s*420);
hold off;

new = filter(B_RCOS, 1, Rcvd .* s);
figure; plot(real(xcorr(rxPN, new')));
scatterplot(new);

function rate = correlate(ref, test)
    
    rate = zeros(size(ref));
    for i = 1:length(ref)
        shift = circshift(ref,i);
        rate(i,:) = sum(shift.*test(1:length(ref),:));
    end

end