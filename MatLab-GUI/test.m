Fs = 233e3;
frameSize = 20e3;
hchirp = dsp.Chirp('SampleRate',Fs,...
  'SamplesPerFrame',frameSize,...
  'InitialFrequency',11e3,...
  'TargetFrequency',11e3+55e3);

hss = dsp.SpectrumAnalyzer('SampleRate',Fs);
hss.SpectrumType = 'Spectrogram';
hss.RBWSource = 'Property';
hss.RBW = 500;
hss.TimeSpanSource = 'Property';
hss.TimeSpan = 2;
hss.PlotAsTwoSidedSpectrum = false;

for idx = 1:500
  y = step(hchirp)+ 0.05*randn(frameSize,1);  
  step(hss,y);
end

release(hss);
