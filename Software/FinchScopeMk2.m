

function varargout = FinchScopeMk2(varargin)

% FINCHSCOPEMK2 MATLAB code for finchscopemk2.fig
%      FINCHSCOPEMK2, by itself, creates a new FINCHSCOPEMK2 or raises the existing
%      singleton*.
%
%      H = FINCHSCOPEMK2 returns the handle to a new FINCHSCOPEMK2 or the handle to
%      the existing singleton*.
%
%      FINCHSCOPEMK2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINCHSCOPEMK2.M with the given input arguments.
%
%      FINCHSCOPEMK2('Property','Value',...) creates a new FINCHSCOPEMK2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FinchScopeMk2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FinchScopeMk2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help finchscopemk2

% Last Modified by GUIDE v2.5 31-Oct-2014 13:41:47

% Begin initialization code - DO NOT EDIT

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

% --- Executes just before finchscopemk2 is made visible.
function FinchScopeMk2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to finchscopemk2 (see VARARGIN)

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
a = arduino('COM6');
a.pinMode(4,'output');

% Create video object
% Putting the object into manual trigger mode and then
% starting the object will make GETSNAPSHOT return faster
% since the connection to the camera will already have
% been established.
handles.video = videoinput('winvideo', 1, 'UYVY_360x240');% Convert the input images to grayscale.

%%Color Control
cmap = jet(100);
[~,idx] = sortrows(rgb2hsv(cmap), -1);  %# sort by Hue
%C = gray(100);
%C = C(idx,:);
C=gray(64);
%

%set(handles.video,'TimerPeriod', 0.05, ...
%'TimerFcn',['if(~isempty(gco)),'...
%'handles=guidata(gcf);'... % Update handles
%'{@supportFscope,handles};'... % Get picture using GETSNAPSHOT and put it into axes using IMAGE
%'set(handles.cameraAxes,''ytick'',[],''xtick'',[]),'... % Remove tickmarks and labels that are inserted when using IMAGE
%'else '...
%'delete(imaqfind);'... % Clean up - delete any image acquisition objects
%'end']);

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
colormap(bone(64));

% cmap = jet(100);
% [~,idx] = sortrows(rgb2hsv(cmap), -1);  %# sort by Hue
% C = gray(100);
% C = C(idx,:);
% 

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
% hObject    handle to captureImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% frame = getsnapshot(handles.video);
frame = get(get(handles.cameraAxes,'children'),'cdata'); % The current displayed frame
save('testframe.mat', 'frame');
disp('Frame saved to file ''testframe.mat''');


% --- Executes on button press in startAcquisition.
function startAcquisition_Callback(hObject, eventdata, handles)
% hObject    handle to startAcquisition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Start/Stop acquisition
if strcmp(get(handles.startAcquisition,'String'),'Start Acquisition')
    % Camera is not acquiring. Change button string and start acquisition.
    set(handles.startAcquisition,'String','Stop Acquisition');
    trigger(handles.video);
else
    % Camera is acquiring. Stop acquisition, save video data,
    % and change button string.
    stop(handles.video);
    disp('Saving captured video...');
    
    videodata = getdata(handles.video);
    save('testvideo.mat', 'videodata');
    disp('Video saved to file ''testvideo.mat''');
    
    start(handles.video); % Restart the camera
    set(handles.startAcquisition,'String','Start Acquisition');
end

% --- Executes when user attempts to close FinchScopeMk2.
function myCameraGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to FinchScopeMk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
delete(imaqfind);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a;
a.digitalWrite(4,1);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a;
global b
b = 0;
a.digitalWrite(5, 0); % led on pin 4
a.digitalWrite(4,0);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a;
maxNumberOfImages = 255;
set(hObject, 'Min', 1);
set(hObject, 'Max', maxNumberOfImages);
set(hObject, 'SliderStep', [1/maxNumberOfImages , 10/maxNumberOfImages ]);
global b
b = round(get(hObject,'Value'))
a.analogWrite(5, b); % led on pin 4

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global lims;
set(hObject, 'Min', 0);
set(hObject, 'Max', 100);
set(hObject, 'SliderStep', [1/200 1/50] );
lims(2)=get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global lims;
set(hObject, 'Min', 0);
set(hObject, 'Max', 100);
set(hObject, 'SliderStep', [1/200 1/50] );
lims(1)=get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
