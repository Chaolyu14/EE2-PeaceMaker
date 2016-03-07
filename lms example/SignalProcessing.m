 noise = dsp.AudioFileReader('noise.wav');
 speech = dsp.AudioFileReader('hello.mp3');
 hfft = dsp.FFT('FFTLengthSource', 'Property', ...
 'FFTLength', 512);

 hmfw = dsp.AudioFileWriter('Speech+Noise.wav','SampleRate', speech.SampleRate);
 hmfw1 = dsp.AudioFileWriter('ClearSignal.wav','SampleRate', speech.SampleRate); 
 AP = dsp.AudioPlayer('SampleRate',speech.SampleRate, ...
			'QueueDuration',10, ...
			'OutputNumUnderrunSamples',true);
 lms = dsp.LMSFilter('Length',11, ...
   'Method','Normalized LMS',...
   'AdaptInputPort',true, ...
   'StepSizeSource','Input port', ...
   'WeightsOutputPort',false);
        
a = 1; % adaptation control
mu = 0.1; % step size
reset_weights = false;

hOut = dsp.SignalSink;
hErr = dsp.SignalSink;
 
 while ~isDone(speech)
    audio1 = step(noise);       % taking inputs and convert them into a 1024*2 double array
    audio2 = step(speech);
   
    audio3 = audio1 + audio2; % adding noise and speech signals together
    step(hmfw, audio3);         % write into a wav file

%    drawnow
%    
%    if nUnderrun > 0
%    fprintf('Audio player queue underrun by %d samples.\n'...
%	     ,nUnderrun);
%    end
    
   [y(:,1), err(:,1)] = step(lms,audio1(:,1),audio3(:,1),mu,a);
   [y(:,2), err(:,2)] = step(lms,audio1(:,2),audio3(:,2),mu,a);
   
   fft_y1 = step(hfft, y);
 %  fft_y1  = fft_y1';
   fft_err1 = step(hfft, err);
 %  fft_err1 =  fft_err1';
   
   
   subplot(2,2,1), plot(audio1),axis([0 1024 -1 1]), title('noise + signal');
   subplot(2,2,2), plot(err),axis([0 1024 -1 1]), title('Err');
   subplot(2,2,3), stem(fft_y1), axis([0 128 -10 10]), title('fft');
   subplot(2,2,4), stem(fft_err1),  axis([0 128 -10 10]), title('fft_err');
   
   drawnow
   nUnderrun = step(AP,err);
   step(hmfw1, err);         % write into a wav file
 end

  
 release(noise); % release the input file
 release(speech);
 release(hmfw1);
 %pause(AP.QueueDuration); 
 release(AP);
 
 