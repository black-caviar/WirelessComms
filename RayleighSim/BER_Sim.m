 %% BER Performance Comparison of Space-Time Block Codes 
clear all; close all; clc;

SNR_Vec = 0:5:50;
BER_Vec = zeros(3, length(SNR_Vec));
set(gca,'FontSize',14)

N = 2^22;
v = 120;
fc = 2.4e9;

data = randi([0,1], 1, N);
tran = pskmod(data, 2);

RayleighNoise0 = genRayChan(N/2, v, fc);
RayleighNoise1 = genRayChan(N/2, v, fc);
RayleighNoise2 = genRayChan(N/2, v, fc);
RayleighNoise3 = genRayChan(N/2, v, fc);

lRN0 = rectpulse(RayleighNoise0, 2);
lRN1 = rectpulse(RayleighNoise1, 2);
lRN2 = rectpulse(RayleighNoise2, 2);
lRN3 = rectpulse(RayleighNoise3, 2);

ex_range = [1:70];
figure; plot(abs(RayleighNoise0(ex_range)), 'LineWidth', 3);
title("Rayleigh Fading Signal Portion");
xlim([1,70]);
ylabel('Power');
xlabel('Sample Number');


for i = 1:length(SNR_Vec)     
    rx = awgn(tran .* lRN0, SNR_Vec(i));
    rx_deray = rx ./ lRN0;
    rx_data = pskdemod(rx_deray, 2);
    BER_Vec(1,i) = sum(rx_data ~= data)/N;
end
disp('Sim complete for no-coding case')

stdata = spaceTimeEnc(tran);
ray0 = stdata(1,:) .* lRN0 + stdata(2,:) .* lRN1;

for i = 1:length(SNR_Vec)  
    rx = awgn(ray0, SNR_Vec(i));
    rx_data = spaceTimeDec(rx, [RayleighNoise0; RayleighNoise1]);
    %rx_data = pskdemod(rx_dec, 2);
    BER_Vec(2,i) = sum(rx_data ~= data)/N;
end
disp('Sim complete for 2x1 case')

ray1 = stdata(1,:) .* lRN2 + stdata(2,:) .* lRN3;

for i = 1:length(SNR_Vec)  
    rx0 = awgn(ray0, SNR_Vec(i));
    rx1 = awgn(ray1, SNR_Vec(i));
    %rx_deray = rx ./ (lRN0 .* lRN1);    
    rx_deray = rx;
    rx_data = spaceTimeDec([rx0;rx1], ...
        [RayleighNoise0; RayleighNoise1;RayleighNoise2;RayleighNoise3]);
    %rx_data = pskdemod(rx_dec, 2);
    BER_Vec(3,i) = sum(rx_data ~= data)/N;
end
disp('Sim complete for 2x2 case')

figure;
semilogy(SNR_Vec, BER_Vec(1,:), '-o', 'LineWidth', 2, 'MarkerSize', 10);
hold on;
semilogy(SNR_Vec, BER_Vec(2,:), '-d', 'LineWidth', 2, 'MarkerSize', 10);
semilogy(SNR_Vec, BER_Vec(3,:), '-^', 'LineWidth', 2, 'MarkerSize', 10);
legend({'No diversity', 'Alamouti 2x1', 'Alamouti 2x2'}, 'FontSize',14);
xlim([0, 50]);
xlabel('E_b/N_0');
ylabel('BER');
title('BER Performance Comparison');
ylim([1e-6, 1]);