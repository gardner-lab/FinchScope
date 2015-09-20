

function varargout = FinchScopeMk3(varargin)

% FinchScope DAQ software.
% WALIII
% d02.09.15
%
% NOTE: before starting, you will need to identify that both the camera,
% and arduino are recognized by matlab. This can be done with the comand:
% >> imaqhwingo % for the camera
% >> 
%
%
%
%

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FinchScopeMk3_OpeningFcn, ...
                   'gui_OutputFcn',  @FinchScopeMk3_OutputFcn, ...
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

C=gray(64);
end

function FinchScopeMk3_OpeningFcn(hObject, eventdata, handles, varargin)


% Choose default command line output for finchscopemk3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
clear a;
global a;
global clips;
global lims;
global condition;
clips=[0 255]; % initialize
lims=[10 90];
a = arduino('COM3');
a.pinMode(4,'output');
a.pinMode(13,'output');
condition = 1
% Create video object
% Putting the object into manual trigger mode and then
% starting the object will make GETSNAPSHOT return faster
% since the connection to the camera will already have
% been established.
handles.video = videoinput('winvideo', 1, 'UYVY_720x480');% Convert the input images to grayscale.
%handles.audio =audiorecorder(44100, 16, 1, 2);
src= getselectedsource(handles.video);
set(src, 'AnalogVideoFormat', 'ntsc_m'); % set analog video input to NTSC

%%Color Control

% Set Video Properties

    handles.video.FramesPerTrigger = 1;
    handles.video.TriggerRepeat = Inf;
    handles.video.FrameGrabInterval = 1;
    handles.vidRes = get(handles.video, 'VideoResolution');
    handles.nBands = get(handles.video, 'NumberOfBands');
    handles.hIm1 = image( zeros(handles.vidRes(2), handles.vidRes(1), handles.nBands),'parent',handles.cameraAxes);
    
% initialize channel
global channel
channel = 1;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes finchscopemk3 wait for user response (see UIRESUME)
uiwait(handles.myCameraGUI);
end

function supportFscope(gunk,junk,handles)

global channel
global clips;
% 
% im=getsnapshot(handles.video);
% im = im(:,:,3,:); % color displayed on HUD. 1 = green 2 = blue 3 = red.
% 
% % adaptive histogram equalization
% %grayscale=rgb2gray(im); % converting based on luminance
% grayscale=mean(im,3);
% grayscale=grayscale-clips(1);
% grayscale=max(grayscale,0); % clips to 0
% grayscale=grayscale./(clips(2)-clips(1)); % max is 1
% grayscale=round(grayscale.*64); % spans 0 to 64
% %indimage=gray2ind(grayscale) %converting to int8 (0-64)
% %finalim=ind2rgb(indimage,bone(64));
% %image(finalim,'parent',handles.cameraAxes);
% image(grayscale);
% colormap(gray(64));
end



% --- Outputs from this function are returned to the command line.
function varargout = FinchScopeMk3_OutputFcn(hObject, eventdata, handles)
% varargout cell array for returning output args (see VARARGOUT);
% hObject handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;
end

% --- Executes on button press in startStopCamera.
function startStopCamera_Callback(hObject, eventdata, handles)
% hObject handle to startStopCamera (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Start/Stop Camera
if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
    % Camera is off. Change button string and start camera.
    set(handles.startStopCamera,'String','Stop Camera')
    start(handles.video)
    set(handles.startAcquisition,'Enable','on');
    set(handles.captureImage,'Enable','on');  
    video = handles.video;
    try
    % Use the timer to process input frames

   video.TimerPeriod = 1/30; % try updating 15 times/second.
   video.TimerFcn = {@imaqcallback, hObject, handles};
   
   
    start(handles.video);  
    % Alternative is to use the FramesAcquiredFcn if we need to ensure
    % that we process every frame.
%      video.FramesAcquiredFcnCount=1;
%     video.FramesAcquiredFcn = {@imaqcallback};

       
catch
    disp 'no video input'
    handles.video=0;
    
end
else
    % Camera is on. Stop camera and change button string.
    set(handles.startStopCamera,'String','Start Camera')
  stop(handles.video)
 %  handles.hIm1 = image( zeros(handles.vidRes(2), handles.vidRes(1), handles.nBands),'parent',handles.cameraAxes);
%     set(handles.startAcquisition,'Enable','off');
    set(handles.captureImage,'Enable','off');
end
end


% --- Nested Callback for having acquired an image
    function imaqcallback(video,event,hObject, handles)
    % access the video object in a try construct, in case the callback
    % gets fired after the object is deleted on cleanup
   video=handles.video;

  
        % get the latest frame and clear the buffer
 set(video,'ReturnedColorSpace','rgb');
        II = getdata(video,1,'uint8');
        handles.size=size(II);
        flushdata(video);
        %I=rgb2gray(I);
    set(handles.hIm1,'cdata',II);
               
        guidata(hObject, handles);
     
    end



% --- Executes on button press in captureImage.
function captureImage_Callback(hObject, eventdata, handles)
newfilename = datestr(clock,30);
frame = get(get(handles.cameraAxes,'children'),'cdata'); % The current displayed frame
save(newfilename, 'frame','-v7.3');
disp('Frame saved to file');
end

% --- Executes on button press in startAcquisition.
function startAcquisition_Callback(hObject, eventdata, handles)
global channel;
global a;
global newfilename;
global aviobj
global condition
% Start/Stop acquisition
if strcmp(get(handles.startAcquisition,'String'),'Start Acquisition')
    % Camera is not acquiring. Change button string and start acquisition.
    set(handles.startAcquisition,'String','Stop Acquisition');
   
 
   if channel == 2; 
    
    record(handles.audio);
   end
   if condition == 1;
   %INSERT
newfilename = datestr(clock,30);
  stop(handles.video);
    handles.video.LoggingMode = 'Disk&Memory';
    aviobj = VideoWriter(newfilename);
    handles.video.DiskLogger= aviobj;
  guidata(hObject, handles);
%record(handles.audio);
start(handles.video)
condition = 2
 % make sure that durring REC_OFF, it dosnt actually stop until after some aquisition.
   end
else
    % Camera is acquiring. Stop acquisition, save video data,
    % and change button string.
    


if condition == 2;
     stop(handles.video);
   if channel == 2; 
    stop(handles.audio);
    audiodata = getaudiodata(handles.audio);
    save(newfilename,'audiodata','-v7.3');
   end
    disp('Saving captured video...');
  
a.digitalWrite(13, 0) % turn off LED to prevent bleaching.

close(handles.video.DiskLogger);
delete(aviobj);
clear aviobj;
clear handles.audio
%handles.audio = audiorecorder(44100, 16, 1, 0);

 condition = 1
 start(handles.video)
   guidata(hObject,handles); 
end  
 
    set(handles.startAcquisition,'String','Start Acquisition');

end
end

% --- Executes when user attempts to close FinchScopeMk3.
function myCameraGUI_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);
delete(imaqfind);
close all;
clear all;
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
global a;
a.digitalWrite(4,1);
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
global channel;
if (get(hObject,'Value') == get(hObject,'Max'))
	display('Audio Recording ON');
    handles.audio = audiorecorder(44100,16, 1,2);
   channel = 2;
else
	display('Audio Recording OFF');
    channel = 1;
end
end

function pushbutton6_Callback(hObject, eventdata, handles)

global a;
global b
b = 0;
a.digitalWrite(13, 0); % led on pin 13
a.digitalWrite(4,0);
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)

global a;
maxNumberOfImages = 255;
set(hObject, 'Min', 1);
set(hObject, 'Max', maxNumberOfImages);
set(hObject, 'SliderStep', [1/maxNumberOfImages , 10/maxNumberOfImages ]);
global b
b = round(get(hObject,'Value'));
LEDpower = b/255*100 % display LED power
a.analogWrite(13, b); % led on pin 13
end

function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


function edit1_Callback(hObject, eventdata, handles)
end

function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)


global clips;
global lims;
im=getsnapshot(handles.video);
% adaptive histogram equalization
%grayscale=rgb2gray(im); % converting based on luminance
grayscale=mean(im,3);

% set clips to some prctile
clips(1)=prctile(grayscale(:),lims(1));
clips(2)=prctile(grayscale(:),lims(2));
end
% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)


global lims;
set(hObject, 'Min', 0);
set(hObject, 'Max', 100);
set(hObject, 'SliderStep', [1/200 1/50] );
lims(2)=get(hObject,'Value');
end

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)

global lims;
set(hObject, 'Min', 0);
set(hObject, 'Max', 100);
set(hObject, 'SliderStep', [1/200 1/50] );
lims(1)=get(hObject,'Value');
end

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


function edit2_Callback(hObject, eventdata, handles)
end

function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function edit3_Callback(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

