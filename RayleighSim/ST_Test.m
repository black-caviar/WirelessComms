%% Test Space Time Encoder and Decoder 

nSym = 2^24;

data = randi([0,1], 1, nSym);
tran = pskmod(data, 2);

tx = spaceTimeEnc(tran);

noise1 = rectpulse(genRayChan(nSym/2, 120, 2.4e9), 2);
noise2 = rectpulse(genRayChan(nSym/2, 120, 2.4e9), 2);

rx = tx(1,:) .* noise1 + tx(2,:) .* noise2;
rx_noise = awgn(rx * modnorm(rx, 'avpow', 1), sqrt(2)*50);
rx_derail = rx_noise ./ (noise1 .* noise2);

rx_dec = spaceTimeDec(rx_derail);

rec_data = pskdemod(rx_dec, 2);

sum(data ~= rec_data)/nSym % this is my BER
isequal(data, rec_data)