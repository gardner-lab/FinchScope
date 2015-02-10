

function varargout = FinchScopeMk2(varargin)

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
                   'gui_OpeningFcn', @FinchScopeMk2_OpeningFcn, ...
                   'gui_OutputFcn',  @FinchScopeMk2_OutputFcn, ...
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

function FinchScopeMk2_OpeningFcn(hObject, eventdata, handles, varargin)


% Choose default command line output for finchscopemk2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
clear a;
global a;
global clips;
global lims;
clips=[0 255]; % initialize
lims=[10 90];
a = arduino('COM5');
a.pinMode(4,'output');
a.pinMode(13,'output');
% Create video object
% Putting the object into manual trigger mode and then
% starting the object will make GETSNAPSHOT return faster
% since the connection to the camera will already have
% been established.
handles.video = videoinput('winvideo', 2, 'UYVY_720x480');% Convert the input images to grayscale.
handles.audio = audiorecorder(44100, 16, 2,2);
%%Color Control
cmap = jet(100);
[~,idx] = sortrows(rgb2hsv(cmap), -1);  %# sort by Hue

C=gray(64);

% Set Video Properties
set(handles.video,'TimerPeriod', 0.05,'TimerFcn',{@supportFscope,handles});
triggerconfig(handles.video,'manual');
handles.video.FramesPerTrigger = Inf; % Capture frames until we manually stop it



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes finchscopemk2 wait for user response (see UIRESUME)
uiwait(handles.myCameraGUI);

function supportFscope(gunk,junk,handles)

global clips;

im=getsnapshot(handles.video);
im = im(:,:,1,:); % color displayed on HUD. 1 = green 2 = blue 3 = red.

% adaptive histogram equalization
%grayscale=rgb2gray(im); % converting based on luminance
grayscale=mean(im,3);
grayscale=grayscale-clips(1);
grayscale=max(grayscale,0); % clips to 0
grayscale=grayscale./(clips(2)-clips(1)); % max is 1
grayscale=round(grayscale.*64); % spans 0 to 64
%indimage=gray2ind(grayscale) %converting to int8 (0-64)
%finalim=ind2rgb(indimage,bone(64));
%image(finalim,'parent',handles.cameraAxes);
image(grayscale);
colormap(gray(64));



% --- Outputs from this function are returned to the command line.
function varargout = FinchScopeMk2_OutputFcn(hObject, eventdata, handles)
% varargout cell array for returning output args (see VARARGOUT);
% hObject handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;


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
    
else
    % Camera is on. Stop camera and change button string.
    set(handles.startStopCamera,'String','Start Camera')
    stop(handles.video)
    set(handles.startAcquisition,'Enable','off');
    set(handles.captureImage,'Enable','off');
end

% --- Executes on button press in captureImage.
function captureImage_Callback(hObject, eventdata, handles)
newfilename = datestr(clock,30);
frame = get(get(handles.cameraAxes,'children'),'cdata'); % The current displayed frame
save(newfilename, 'frame');
disp('Frame saved to file');


% --- Executes on button press in startAcquisition.
function startAcquisition_Callback(hObject, eventdata, handles)

% Start/Stop acquisition
if strcmp(get(handles.startAcquisition,'String'),'Start Acquisition')
    % Camera is not acquiring. Change button string and start acquisition.
    set(handles.startAcquisition,'String','Stop Acquisition');
    trigger(handles.video);
    record(handles.audio);
else
    % Camera is acquiring. Stop acquisition, save video data,
    % and change button string.
    stop(handles.video);
    stop(handles.audio);
    disp('Saving captured video...');
    global a;
a.digitalWrite(13, 0) % turn off LED to prevent bleaching.
    
    newfilename = datestr(clock,30);
    videodata = getdata(handles.video);
    audiodata = getaudiodata(handles.audio);
    save(newfilename, 'videodata','audiodata');
    %save('audiodata_test', 'audiodata');
    disp('Audio/Video saved to file');
    
    start(handles.video); % Restart the camera
    set(handles.startAcquisition,'String','Start Acquisition');
end

% --- Executes when user attempts to close FinchScopeMk2.
function myCameraGUI_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);
delete(imaqfind);
close all;
clear all;



% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
global a;
a.digitalWrite(4,1);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)

function pushbutton6_Callback(hObject, eventdata, handles)

global a;
global b
b = 0;
a.digitalWrite(13, 0); % led on pin 13
a.digitalWrite(4,0);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)

global a;
maxNumberOfImages = 255;
set(hObject, 'Min', 1);
set(hObject, 'Max', maxNumberOfImages);
set(hObject, 'SliderStep', [1/maxNumberOfImages , 10/maxNumberOfImages ]);
global b
b = round(get(hObject,'Value'))
a.analogWrite(13, b); % led on pin 13


function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)


function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)


global lims;
set(hObject, 'Min', 0);
set(hObject, 'Max', 100);
set(hObject, 'SliderStep', [1/200 1/50] );
lims(2)=get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)

global lims;
set(hObject, 'Min', 0);
set(hObject, 'Max', 100);
set(hObject, 'SliderStep', [1/200 1/50] );
lims(1)=get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


