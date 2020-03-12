%% Test Space Time Encoder and Decoder 

clear; clc;

nSym = 2^20;

data = randi([0,1], 1, nSym);
tran = pskmod(data, 2);

tx = spaceTimeEnc(tran);

noise0 = genRayChan(nSym/2, 120, 2.4e9);
noise1 = genRayChan(nSym/2, 120, 2.4e9);

% Try out single antenna decoding 
rx0 = rectpulse(noise0,2) .* tx(1,:) + rectpulse(noise1, 2) .* tx(2,:);
rec_data = spaceTimeDec(rx0, [noise0;noise1]);
isequal(data, rec_data)

% Dual antenna decoding 

noise2 = genRayChan(nSym/2, 120, 2.4e9);
noise3 = genRayChan(nSym/2, 120, 2.4e9);

rx1 = rectpulse(noise2,2) .* tx(1,:) + rectpulse(noise3, 2) .* tx(2,:);
rec_data = spaceTimeDec([rx0;rx1], [noise0;noise1;noise2;noise3]);
isequal(data, rec_data)