disp('End of Recording.');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stop recording %
stop(recObj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Play back the recording.
play(recObj);

% Store data in double-precision array.
myRecording = getaudiodata(recObj);

% Plot the waveform.
plot(myRecording);