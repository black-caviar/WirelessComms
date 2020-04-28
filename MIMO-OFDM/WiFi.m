% Simulate 802.11a OFDM symbols

data = randi([0 3], 1, 48*1);
enc = pskmod(data, 4, pi/4);
fmapt(enc, 0)

function fmapt(data, pilots)
    data0 = data(1:5)
    data1 = data(6:18)
    data2 = data(19:30)
    data3 = data(31:43)
    data4 = data(44:48)
end