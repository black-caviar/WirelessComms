%% BER Performance Comparison of Space-Time Block Codes 
clear all; close all; clc;

SNR_Vec = 0:5:50;
BER_Vec = zeros(2, length(SNR_Vec));

N = 2^20;
data = randi([0,1], 1, N);
tran = pskmod(data, 2);

RayleighNoise0 = rectpulse(genRayChan(N/2, 120, 2.4e9), 2);
RayleighNoise1 = rectpulse(genRayChan(N/2, 120, 2.4e9), 2);
% Assure that Rayleigh channel conditions do not change in between symbol
% pairs 

figure; plot(abs(RayleighNoise0(1500:1600)));
title("Rayleigh Fading Signal Portion");

RayleighNoise = genRayChan(N, 100, 1e9);

for i = 1:length(SNR_Vec)     
    rx = awgn(tran .* RayleighNoise, SNR_Vec(i)/sqrt(2));
    rx_deray = rx ./ RayleighNoise;
    rx_data = pskdemod(rx_deray, 2);
    BER_Vec(1,i) = sum(rx_data ~= data)/N;
end

stdata = spaceTimeEnc(tran);
ray = (stdata(1,:) .* RayleighNoise0 + stdata(2,:) .* RayleighNoise1) * 2;

for i = 1:length(SNR_Vec)  
    rx = awgn(ray, 2*SNR_Vec(i));
    rx_deray = rx ./ (RayleighNoise0 .* RayleighNoise1);
    rx_dec = spaceTimeDec(rx_deray);
    rx_data = pskdemod(rx_dec, 2);
    BER_Vec(2,i) = sum(rx_data ~= data)/N;
end

semilogy(SNR_Vec, BER_Vec(1,:), '-o');
hold on;
semilogy(SNR_Vec, BER_Vec(2,:), '-d');
legend('No diversity', 'Alamouti 2x1');
xlim([0, 50]);
ylim([1e-6, 1]);