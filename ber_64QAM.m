
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title     : Bit Error Rate for 64-QAM modulation using Gray modulation mapping
% Author    : balarcode
% Version   : 1.0
% Date      : 29th September 2024
% File Type : Matlab Script
% File Test : Verified on Matlab R2024b
% Comments  : For M = 64 QAM modulation scheme, the bit error rate increases 
%             since the number of signal constellation points get increased when 
%             compared to M = 4 or M = 16 scenario. 
%             It can also be noted that there is an approximate 4 dB change when the 
%             constellation size gets quadrupled from M = 4 to 16 to 64.
%
% All Rights Reserved.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

clear

% Simulation Parameter Initialization
% -----------------------------------
N = 10^5; % Number of symbols
M = 64;   % Constellation size 
% NOTE: i.e. the 'k' information bits in the information bit sequence is mapped onto 'M' different amplitude levels.
%       And each of 10^5 symbols take one of the different amplitude levels 'M' as defined in the constellation diagram.
k = log2(M); % Bits per symbol

% Define the real and imaginary PAM constellation for 64-QAM
real_value = [-(2*sqrt(M)/2-1):2:-1 1:2:2*sqrt(M)/2-1];
imag_value = [-(2*sqrt(M)/2-1):2:-1 1:2:2*sqrt(M)/2-1];
k_64QAM = 1 / sqrt(2*(M-1)/3);
% NOTE: Eavg = 2*(M-1)/3 for an M-QAM Signal AND k_MQAM = 1 / sqrt(Eavg);

Eb_N0_dB = [0:25]; % multiple Es/N0 values. The range for Eb_N0_dB is increased up to 25 dB.
Es_N0_dB = Eb_N0_dB + 10*log10(k); 
% NOTE: Es_N0 = (Eb_N0 * k) where k = log2(M). By taking log to base-10 on both
%       sides and multiplying by 10, we get the expression in decibels.

% Mapping for Binary <--> Gray code conversion
ref = [0 : sqrt(M)-1];
map = bitxor(ref, floor(ref/2)); % NOTE: 'map' array consists of gray code values for the values present in 'ref' array.
[index, gray_code_value] = sort(map); % NOTE: sort() function arranges the elements of 'map' array in an ascending order.                            

for idx = 1:length(Eb_N0_dB)
    % Transmit Symbol Generation
    % --------------------------
    bits = rand(1, N*k, 1) > 0.5; % NOTE: Random 1's and 0's. Since 'N' symbols are present, 'N*k' would give the entire bit-stream.
    bitsReshape = reshape(bits, k, N).';
    bin2DecMatrix = ones(N,1)*(2.^[(k/2-1):-1:0]) ; % Conversion from binary to decimal

    % Process real part
    bitsReal = bitsReshape(:, [1:k/2]);
    decimalReal = sum(bitsReal.*bin2DecMatrix, 2);
    grayDecimalReal = bitxor(decimalReal, floor(decimalReal/2));
    % Process imaginary part
    bitsImag = bitsReshape(:, [k/2+1:k]);
    decimalImag = sum(bitsImag.*bin2DecMatrix,2);
    grayDecimalImag = bitxor(decimalImag, floor(decimalImag/2));

    % Mapping the Gray coded symbols into constellation
    modReal = real_value(grayDecimalReal+1);
    modImag = imag_value(grayDecimalImag+1);

    % Complex Constellation of Transmit Symbol
    mod = modReal + (1i * modImag);
    x = k_64QAM * mod; % Normalization of transmit power to one 
    
    % Noise
    % -----
    n = 1/sqrt(2) * [randn(1, N) + 1i*randn(1, N)]; % White Gaussian noise, 0dB variance 
    
    % Received Signal
    % ---------------
    y = x + (10^(-Es_N0_dB(idx)/20) * n); % Transmit symbol sent over an AWGN channel

    % Demodulation
    % ------------
    yReal = real(y) / k_64QAM; % Real part
    yImag = imag(y) / k_64QAM; % Imaginary part
    % NOTE: Real and Imaginary parts are extracted from the received signal 'y'.

    % Rounding to the nearest alphabet
    yEstReal = 2*floor(yReal/2)+1;
    yEstReal(find(yEstReal > max(real_value))) = max(real_value);
    % NOTE: Here, find(yEstReal > max(real_value)) returns linear indices
    %       corresponding to non zero elements in 'yEstReal' that are greater than
    %       max(real_value) which is '7' in this case. Note that all elements in
    %       'yEstReal' are non-zero elements.
    %       Similar comments for min(real_value), max(imag_value) and min(imag_value).
    yEstReal(find(yEstReal < min(real_value))) = min(real_value);
    
    yEstImag = 2*floor(yImag/2)+1;
    yEstImag(find(yEstImag > max(imag_value))) = max(imag_value);
    yEstImag(find(yEstImag < min(imag_value))) = min(imag_value);

    % Constellation to Decimal conversion. Constellation is in Gray Code.
    decimalEstReal = gray_code_value(floor((yEstReal+sqrt(M))/2+1))-1;
    decimalEstImag = gray_code_value(floor((yEstImag+sqrt(M))/2+1))-1;
    % NOTE: Here linear indexing is using for a 2-D array.
    
    % Converting to binary string
    bitsEstReal = dec2bin(decimalEstReal, k/2);
    bitsEstImag = dec2bin(decimalEstImag, k/2);
    % NOTE: dec2bin converts the decimal number to a binary number having atleast k/2 bits.

    % Converting binary string to a number
    bitsEstReal = bitsEstReal.';
    bitsEstReal = bitsEstReal(1:end).';
    bitsEstReal = reshape(str2num(bitsEstReal).', k/2, N).' ;
    
    bitsEstImag = bitsEstImag.';
    bitsEstImag = bitsEstImag(1:end).';
    bitsEstImag = reshape(str2num(bitsEstImag).', k/2, N).' ;

    % Counting bit errors for real and imaginary parts
    nBitErr(idx) = size(find([bitsReal - bitsEstReal]), 1) + size(find([bitsImag - bitsEstImag]), 1);
end 

% Figure(s)
% ---------
simBer = nBitErr / (N*k);
theoryBer = 4 * (1-1/sqrt(M)) / 2 * erfc(sqrt(k*k_64QAM^2*(10.^(Eb_N0_dB/10)))) / k;

close all; 
figure(1)
semilogy(Eb_N0_dB,theoryBer,'bs-','LineWidth',2);
hold on
semilogy(Eb_N0_dB,simBer,'mx-','LineWidth',2);
axis([0 25 10^-5 1])
grid on
legend('Theory', 'Simulation');
xlabel('Eb/No, dB')
ylabel('Bit Error Rate')
title('Bit Error Probability for 64-QAM Modulation')

figure(2)
plot(real(x),imag(x),'b*')
axis ([-1.5 1.5 -1.5 1.5])
grid on
xlabel("Real (Transmit Symbol Vector)")
ylabel("Imaginary (Transmit Symbol Vector)")
title('Constellation for 64-QAM Modulation')