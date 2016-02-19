nlms = dsp.LMSFilter('Length',11, ...
   'Method','Normalized LMS',...
   'AdaptInputPort',true, ...
   'StepSizeSource','Input port', ...
   'WeightsOutputPort',false);
x = sin(0:0.5:49.5); % Noise                              % unwanted signals
x = x';
d = x;         % Set desired to x

a = 1; % adaptation control, 1 to on filter 0 to off
mu = 0.01; % step size

% put in while loop
[y, err] = step(nlms,x,d,mu,a);

subplot(2,1,1);
plot(d);
title('Noise + Signal');
subplot(2,1,2);
plot(err);
title('Signal');
drawnow

