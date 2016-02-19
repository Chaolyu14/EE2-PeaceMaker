function varargout = testGUI(varargin)
% TESTGUI MATLAB code for testGUI.fig
%      TESTGUI, by itself, creates a new TESTGUI or raises the existing
%      singleton*.
%
%      H = TESTGUI returns the handle to a new TESTGUI or the handle to
%      the existing singleton*.
%
%      TESTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTGUI.M with the given input arguments.
%
%      TESTGUI('Property','Value',...) creates a new TESTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testGUI

% Last Modified by GUIDE v2.5 15-Feb-2016 17:11:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @testGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                     'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before testGUI is made visible.
function testGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testGUI (see VARARGIN)

% Choose default command line output for testGUI
handles.output = hObject;

 % set the sample rate (Hz)

 % create the recorder 
 handles.AR = dsp.AudioRecorder('SampleRate',44100,...
                       'SamplesPerFrame',1024);
 handles.Fs = handles.AR.SampleRate;

 handles.AP = dsp.AudioPlayer('SampleRate',handles.Fs,...
    'OutputNumUnderrunSamples',true);
% assign a timer function to the recorder
% set(handles.recorder,'TimerPeriod',1,'TimerFcn',{@audioTimer,hObject});
 handles.TS = dsp.TimeScope();

 % save the handles structure
  handles.filename = [datestr(now,'yyyy-mm-dd_HHMMSS') '.wav'];
  handles.AFR = dsp.AudioFileReader;
  handles.AFW = dsp.AudioFileWriter(handles.filename,'FileFormat', 'WAV');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Start_Recording.
function Start_Recording_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Recording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Streaming %
tic
Tstop  = inf;
count = 0;
axes(handles.axes1); 

disp('Start recording');
disp('Speak into microphone now');
while toc < Tstop
    audioIn = step(handles.AR);
              %step(handles.TS, audioIn);
              step(handles.AFW,audioIn);
    plot(audioIn);
    axis([0 1024 -0.5 0.5]);
    drawnow
    count = count + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Hint: get(hObject,'Value') returns toggle state of Start_Recording


% --- Executes on button press in Finish_Recording.
function Finish_Recording_Callback(hObject, eventdata, handles)
% hObject    handle to Finish_Recording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 % save the recorder to file
release(handles.AR);
release(handles.AFW);
disp('End of Recording.');


info = audioinfo(handles.filename);

disp(info);

% --- Executes on button press in Filtering.
function Filtering_Callback(hObject, eventdata, handles)
% hObject    handle to Filtering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Streaming %
TS = dsp.TimeScope('YLimits',[-0.1,0.1],'SampleRate',handles.Fs,...
    'TimeSpan',44100/1024);
Tstop = inf;
tic
count = 0;
while toc < Tstop % Run for 20 seconds
    audioIn = step(handles.AR);
    audioOut = step(NotchFilter,audioIn);
    step(TS,audioOut);
    count = count + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in Playback.
function Playback_Callback(hObject, eventdata, handles)
% hObject    handle to Playback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
%[y,Fs] = audioread(handles.filename);
while ~isDone(handles.AFR(handles.filename))
  audio = step(handles.AFR);
  nUnderrun = step(handles.AP,audio);
  if nUnderrun > 0
    fprintf('Audio player queue underrun by %d samples.\n'...
	     ,nUnderrun);
  end
end
pause(handles.AP.QueueDuration); % wait until audio is played to the end
release(handles.AFR);            % close the input file
release(handles.AP);             % close the audio output device

disp('sound played');


function audioTimer(hObject,varargin)
% get the handle to the figure/GUI  (this is the handle we passed in 
 % when creating the timer function in myGuiName_OpeningFcn)
 hFigure = varargin{2};
 % get the handles structure so we can access the plots/axes
 handles = guidata(hFigure);
 % get the audio samples
 samples = getaudiodata(hObject);

hfig = figure;
figname = hfig.Name;
hfig.Name = 'My Window';

function NotchFilter
% Notch Filter %
Wo = 200/(handles.Fs/2);
Q  = 35;
BW = Wo/Q;
[b,a] = iirnotch(Wo,BW);
NotchFilter = dsp.BiquadFilter('SOSMatrix',[b,a]);