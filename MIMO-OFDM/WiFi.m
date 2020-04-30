% Simulate 802.11a OFDM symbols
%%

PN = [7, 4, 0];
PNGEN = comm.PNSequence('Polynomial', PN, 'InitialConditions', [1,1,1,1,1,1,1], ...
    'SamplesPerFrame', 2^7-1, 'Mask', de2bi(64,7));
PNSEQ = fliplr(PNGEN()');
% The data scrambler sequence defined in 17.3.5.4 of the 802.11a standard
pilot = pskmod(PNSEQ, 2);

%%

data = randi([0 3], 1, 48*1);
enc = pskmod(data, 4, pi/4);
dataframe = fmapt(enc, pilot(1));

tran = ifft(dataframe);



function frame = fmapt(data, pilot)
    data0 = data(1:5);
    data1 = data(6:18);
    data2 = data(19:24);
    data3 = data(25:30);
    data4 = data(31:43);
    data5 = data(44:48);
    
    h1 = [0, data3, pilot, data4, -pilot, data5, [0 0 0 0 0 0]];
    h2 = [[0 0 0 0 0], fliplr([data0, pilot, data1, pilot, data3])];
    
    td = ifft([h1,h2]);
    frame = [td(end-15:end), td];
    %frame = [h1, h2];
    %frame = [[0 0 0 0 0 0], data0, pilot, data1, pilot, data2, 0, data3, ...
    %    pilot, data4, -pilot, data5, [0 0 0 0 0 0]];
    %unclear why pilot 4 is negative. To avoid symmetry confusion?
end