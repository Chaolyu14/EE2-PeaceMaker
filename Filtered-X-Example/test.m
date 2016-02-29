Fs     = 8e3;  % 8 kHz
N      = 800;  % 800 samples@8 kHz = 0.1 seconds
Flow   = 160;  % Lower band-edge: 160 Hz
Fhigh  = 2000; % Upper band-edge: 2000 Hz
delayS = 7;
Ast    = 20;   % 20 dB stopband attenuation
Nfilt  = 8;    % Filter order

% Design bandpass filter to generate bandlimited impulse response
Fd = fdesign.bandpass('N,Fst1,Fst2,Ast',Nfilt,Flow,Fhigh,Ast,Fs);
Hd = design(Fd,'cheby2','FilterStructure','df2tsos',...
    'SystemObject',true);

% Filter noise to generate impulse response
H = step(Hd,[zeros(delayS,1); log(0.99*rand(N-delayS,1)+0.01).* ...
    sign(randn(N-delayS,1)).*exp(-0.01*(1:N-delayS)')]);
H = H/norm(H);



ntrS = 30000;
s = randn(ntrS,1); % Synthetic random signal to be played
Hfir = dsp.FIRFilter('Numerator',H.');
dS = step(Hfir,s) + ... % random signal propagated through secondary path
    0.01*randn(ntrS,1); % measurement noise at the microphone

M = 250;
muS = 0.1;
hNLMS = dsp.LMSFilter('Method','Normalized LMS','StepSize', muS,...
    'Length', M);
[yS,eS,Hhat] = step(hNLMS,s,dS);

n = 1:ntrS;
plot(n,dS,n,yS,n,eS);
xlabel('Number of iterations');
ylabel('Signal value');
title('Secondary Identification Using the NLMS Adaptive Filter');
legend('Desired Signal','Output Signal','Error Signal');

delayW = 15;
Flow   = 200; % Lower band-edge: 200 Hz
Fhigh  = 800; % Upper band-edge: 800 Hz
Ast    = 20;  % 20 dB stopband attenuation
Nfilt  = 10;  % Filter order

% Design bandpass filter to generate bandlimited impulse response
Fd2 = fdesign.bandpass('N,Fst1,Fst2,Ast',Nfilt,Flow,Fhigh,Ast,Fs);
Hd2 = design(Fd2,'cheby2','FilterStructure','df2tsos',...
    'SystemObject',true);

% Filter noise to generate impulse response
G = step(Hd2,[zeros(delayW,1); log(0.99*rand(N-delayW,1)+0.01).*...
    sign(randn(N-delayW,1)).*exp(-0.01*(1:N-delayW)')]);
G = G/norm(G);
    

% FIR Filter to be used to model primary propagation path
Hfir = dsp.FIRFilter('Numerator',G.');

% Filtered-X LMS adaptive filter to control the noise
L = 350;
muW = 0.0001;
Hfx = dsp.FilteredXLMSFilter('Length',L,'StepSize',muW,...
    'SecondaryPathCoefficients',Hhat);

% Sine wave generator to synthetically create the noise
A = [.01 .01 .02 .2 .3 .4 .3 .2 .1 .07 .02 .01]; La = length(A);
F0 = 60; k = 1:La; F = F0*k;
phase = rand(1,La); % Random initial phase
Hsin = dsp.SineWave('Amplitude',A,'Frequency',F,'PhaseOffset',phase,...
    'SamplesPerFrame',512,'SampleRate',Fs);

% Audio player to play noise before and after cancellation
Hpa = dsp.AudioPlayer('SampleRate',Fs,'QueueDuration',2);

% Spectrum analyzer to show original and attenuated noise
Hsa = dsp.SpectrumAnalyzer('SampleRate',Fs,'OverlapPercent',80,...
    'SpectralAverages',20,'PlotAsTwoSidedSpectrum',false,...
    'ShowLegend',true, ...
    'ChannelNames', {'Original noisy signal', 'Attenuated noise'});

for m = 1:400
    s = step(Hsin); % Generate sine waves with random phase
    x = sum(s,2);   % Generate synthetic noise by adding all sine waves
    d = step(Hfir,x) + ...  % Propagate noise through primary path
        0.1*randn(size(x)); % Add measurement noise
    if m <= 200
        % No noise control for first 200 iterations
        e = d;
    else
        % Enable active noise control after 200 iterations
        xhat = x + 0.1*randn(size(x));
        [y,e] = step(Hfx,xhat,d);
    end
    step(Hpa,e);     % Play noise signal
    step(Hsa,[d,e]); % Show spectrum of original (Channel 1)
                     % and attenuated noise (Channel 2)
end
release(Hpa); % Release audio device
release(Hsa); % Release spectrum analyzer