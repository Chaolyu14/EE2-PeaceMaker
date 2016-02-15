IN = dsp.AudioRecorder('OutputNumOverrunSamples',true);
OUT = dsp.AudioFileWriter('myvoice.wav','FileFormat', 'WAV');
disp('Speak into microphone now');
tic;
while toc <= 10,
  [audio,Overrun] = step(IN);
  step(OUT,audio);
  if Overrun > 0
    fprintf('Audio recorder queue was overrun by %d samples\n'...
        ,Overrun);
  end
end
release(IN);
release(OUT);
disp('Recording complete');
