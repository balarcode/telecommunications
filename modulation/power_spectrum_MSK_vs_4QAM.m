
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Title     : Comparative Study of Power Spectral Density for 
%             Minimum Shift Keying (MSK) and 4-QAM Modulation
% Author    : balarcode
% Version   : 1.0
% Date      : 30th September 2024
% File Type : Matlab Script
% File Test : Verified on Matlab R2024b
% Comments  : MSK has a wider main lobe when compared to 4-QAM modulation.
%             Since MSK contains more energy when compared to 4-QAM modulation, 
%             it is spectrally more efficient. Due to this reason, MSK is 
%             widely used in space communication, military tactical radio and 
%             under water communication.
%
% All Rights Reserved.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

clear

% Common Simulation Parameters for Minimum Shift Keying and 4-QAM Modulation
% --------------------------------------------------------------------------
N = 10^5; % Number of symbols
Tsym = 2; % Tsym is chosen to be 2 seconds


% Simulation Parameter Initialization for PSD for Minimum Shift Keying
% --------------------------------------------------------------------
cos_t = cos( pi*[-Tsym : N*Tsym-1] / (2*Tsym) ); % Using the formula Cos((PI*t)/(2*Tsym))
sin_t = sin( pi*[-Tsym : N*Tsym-1] / (2*Tsym) ); % Using the formula Sin((PI*t)/(2*Tsym))
% NOTE: PI is an irrational number approximately equal to 3.14159

% Symbol Generation for Minimum Shift Keying
% ------------------------------------------
bits = rand(1, N) > 0.5; % Random 1's and 0's
modulated_bits = 2*bits - 1; % 0 -> -1, 1 -> 1

Even = kron(modulated_bits(1:2:end), ones(1, 2*Tsym)); % Even bits
Odd = kron(modulated_bits(2:2:end), ones(1, 2*Tsym)); % Odd bits
Even = [ Even zeros(1,Tsym) ]; % Padding zeros to make 'Even' & 'cos_t' matrix dimensions equal
Odd = [ zeros(1,Tsym) Odd ]; % Padding zeros ahead of the bits to make 'Odd' & 'sin_t' matrix 
%                              dimensions equal and to introduce a delay
% NOTE: kron(A, B) returns the Kronecker tensor product of matrices A and B.

% MSK Transmit Waveform
mod = (1 / sqrt(Tsym)) * (Even.*cos_t + 1i*Odd.*sin_t);
length_mod = length(mod);

% Power Spectrum Calculation for Minimum Shift Keying
% ---------------------------------------------------
psd1_msk = abs(fft(mod)) / length_mod / 2;
psd_msk = psd1_msk(1:(length_mod/2)).^2;

freq_msk = [0:length_mod/2-1] / Tsym;


% Simulation Parameter Initialization for PSD for 4-QAM Modulation
% ----------------------------------------------------------------
M = 4;    % Constellation size 
% NOTE: i.e. the 'k' information bits in the information bit sequence is mapped onto 'M' different amplitude levels.
%       And each of 10^5 symbols take one of the different amplitude levels 'M' as defined in the constellation diagram.
k = log2(M); % Bits per symbol
width = 20; % Width of a pulse shaping function
pulse_shaping_function = window(@rectwin, width); 
% NOTE: Generates a rectangular window function of width = 20.
%       The Pulse Shaping Function obtained would be a column vector of size = 20x1.
%       pulse_shaping_function defined above is equivalent to defining an other function: ones(width, 1).

% Define the real and imaginary PAM constellation for 4-QAM
real_value = [-(2*sqrt(M)/2-1):2:-1 1:2:2*sqrt(M)/2-1];
imag_value = [-(2*sqrt(M)/2-1):2:-1 1:2:2*sqrt(M)/2-1];
k_4QAM =  1 / sqrt(2 * (M-1) / 3);
% NOTE: Eavg = 2*(M-1)/3 for an M-QAM Signal AND k_MQAM = 1 / sqrt(Eavg); For 4-QAM, Eavg = 2.

% Symbol Generation for 4-QAM Modulation
% --------------------------------------
bits = rand(1, N*k, 1) > 0.5; % Random 1's and 0's
bitsReshape = reshape(bits, k, N).';
bin2DecMatrix = ones(N,1)*(2.^((k/2-1):-1:0)) ; % Conversion from binary to decimal
% Process real part
bitsReal = bitsReshape(:,(1:k/2));
decimalReal = sum(bitsReal.*bin2DecMatrix,2);
grayDecimalReal = bitxor(decimalReal, floor(decimalReal/2));
% Process imaginary part
bitsImag = bitsReshape(:,(k/2+1:k));
decimalImag = sum(bitsImag.*bin2DecMatrix,2);
grayDecimalImag = bitxor(decimalImag, floor(decimalImag/2)); 
% Mapping the Gray coded symbols into constellation
modRe = real_value(grayDecimalReal+1);
modIm = imag_value(grayDecimalImag+1);

% Complex Constellation
mod = modRe + (1i * modIm);
mod1 = k_4QAM * mod; % Normalization of transmit power to one 
mod2 = mod1' * pulse_shaping_function'; % Each symbol is multiplied by pulse shaping function which is a rectangular function
mod_reshaped = reshape(mod2', 1, size(mod2,1)*size(mod2,2));

length_mod_reshaped = length(mod_reshaped);

% Power Spectrum Calculation for 4-QAM Modulation
% -----------------------------------------------
psd1 = abs(fft(mod_reshaped)) / length_mod_reshaped / 2;
psd_4QAM = psd1(1:(length_mod_reshaped/2)).^2;

freq_4QAM = [0:length_mod_reshaped/2-1] / Tsym;


% Figure(s)
% ---------
close all; 
figure
subplot(4,2,3);
semilogy(freq_4QAM, psd_4QAM); % Plot on a semilog (base-10 logarithmic) scale
title('Power Spectral Density plot on a logarithmic scale for 4-QAM');
grid on;
xlabel('Normalized Frequency');
ylabel('PSD in dB');

subplot(4,2,5);
semilogy(freq_msk, psd_msk); % Plot on a semilog (base-10 logarithmic) scale
title('Power Spectral Density plot on a logarithmic scale for MSK');
grid on;
xlabel('Normalized Frequency');
ylabel('PSD in dB');

subplot(4,2,4);
plot(freq_4QAM, psd_4QAM); 
title('Power Spectral Density plot on a linear scale for 4-QAM');
grid on;
xlabel('Normalized Frequency');
ylabel('PSD');

subplot(4,2,6);
plot(freq_msk, psd_msk); 
title('Power Spectral Density plot on a linear scale for MSK');
grid on;
xlabel('Normalized Frequency');
ylabel('PSD');