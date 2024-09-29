
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title     : Power Spectral Density for 4-QAM modulation that uses Gray encoding
% Author	: balarcode
% Version	: 1.0
% Date		: 28th September 2024
% File Type : Matlab Script
% File Test : Verified on Matlab R2024b
% Comments  : From the power spectral density spectrum, it can be noticed that the 
%             zero crossings occur at 0.5, 1, 1.5, 2, 2.5 and so on.
%             The main lobe (from 0 till 0.5) in the power spectral density plot on a
%             logarithmic scale is slightly bigger than the side lobes and 
%             this confirms that more energy is prevalent in the main lobe. 
%             In fact, it is quite evident from the power spectral density plot
%             on a linear scale.
%             The Power spectral density for 4-QAM is given by the expression: 
%             S(f) = (2/3)*(M-1)*log2(M)*Eb*{sinc((log2(M)*Tb*f)}^2
%
% All Rights Reserved.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

clear

% Simulation Parameter Initialization
% -----------------------------------
N = 10^5; % Number of symbols
M = 4;    % Constellation size 
% NOTE: i.e. the 'k' information bits in the information bit sequence is mapped onto 'M' different amplitude levels.
%       And each of 10^5 symbols take one of the different amplitude levels 'M' as defined in the constellation diagram.
k = log2(M); % Bits per symbol
width = 20; % Width of a pulse shaping function
Pulse_Shaping_Func = window(@rectwin, width); 
% NOTE: Generates a rectangular window function of width = 20.
%       The Pulse Shaping Function obtained would be a column vector of size = 20x1.
%       Pulse_Shaping_Func defined above is equivalent to defining an other function: ones(width,1).
Tsym = 2; % Tsym is chosen to be 2 seconds.

% Define the real and imaginary PAM constellation for 4-QAM
real_value = [-(2*sqrt(M)/2-1):2:-1 1:2:2*sqrt(M)/2-1];
imag_value = [-(2*sqrt(M)/2-1):2:-1 1:2:2*sqrt(M)/2-1];
k_4QAM =  1 / sqrt(2 * (M-1) / 3);
% NOTE: Eavg = 2*(M-1)/3 for an M-QAM Signal AND k_MQAM = 1 / sqrt(Eavg); For 4-QAM, Eavg = 2.

% Symbol Generation
% -----------------------
ipBit = rand(1,N*k,1)>0.5; % Random 1's and 0's
ipBitReshape = reshape(ipBit,k,N).';
bin2DecMatrix = ones(N,1)*(2.^((k/2-1):-1:0)) ; % Conversion from binary to decimal
% real
ipBitRe =  ipBitReshape(:,(1:k/2));
ipDecRe = sum(ipBitRe.*bin2DecMatrix,2);
ipGrayDecRe = bitxor(ipDecRe,floor(ipDecRe/2));
% imaginary
ipBitIm =  ipBitReshape(:,(k/2+1:k));
ipDecIm = sum(ipBitIm.*bin2DecMatrix,2);
ipGrayDecIm = bitxor(ipDecIm,floor(ipDecIm/2)); 
% mapping the Gray coded symbols into constellation
modRe = real_value(ipGrayDecRe+1);
modIm = imag_value(ipGrayDecIm+1);

% Complex Constellation
mod = modRe + (1i * modIm);
mod1 = k_4QAM * mod; % Normalization of transmit power to one 
mod2 = mod1' * Pulse_Shaping_Func'; % Each symbol is multiplied by pulse shaping function which is a rectangular function.
mod_reshaped = reshape(mod2',1,size(mod2,1)*size(mod2,2));

length_mod_reshaped = length(mod_reshaped);

% Power Spectrum Calculation
% --------------------------
psd1 = abs(fft(mod_reshaped)) / length_mod_reshaped / 2;
psd = psd1(1:(length_mod_reshaped/2)).^2;

freq = [0:length_mod_reshaped/2-1] / Tsym;

% Figure(s) plotting
% --------------------------
close all; 
figure
subplot(2,1,1);
semilogy(freq, psd); % Plot on a semilog scale
title('Power Spectral Density plot on a logarithmic scale for 4-QAM');
grid on;
xlabel('Normalized Frequency');
ylabel('Power Spectral Density');

subplot(2,1,2);
plot(freq,psd); 
title('Power Spectral Density plot on a linear scale for 4-QAM');
grid on;
xlabel('Normalized Frequency');
ylabel('Power Spectral Density');