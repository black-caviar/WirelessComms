%% Test Space Time Encoder and Decoder 

nSym = 2^12;

data = randi([0,1], 1, nSym);
tran = pskmod(data, m);

tx = spaceTimeEnc(tran);

rx = tx(1,:) + tx(2,:);

rx_dec = spaceTimeDec(rx);

rec_data = pskdemod(rx_dec, m);

isequal(data, rec_data)