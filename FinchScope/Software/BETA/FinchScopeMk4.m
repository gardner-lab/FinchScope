

function varargout = FinchScopeMk4(varargin)

% FinchScope DAQ software.
% WALIII
% d05.23.15
%
% NOTE: before starting, you will need to identify that both the camera,
% and arduino are recognized by matlab. This can be done with the comand:
% >> imaqhwinfo % for the camera
% >> 
%
%
%
%% INITIALIZE CODE (DO NOT EDIT)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FinchScopeMk4_OpeningFcn, ...
                   'gui_OutputFcn',  @FinchScopeMk4_OutputFcn, ...
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

end

function FinchScopeMk4_OpeningFcn(hObject, eventdata, handles, varargin)


% Choose default command line output for finchscopemk4
handles.output = hObject;
handles.test = 0;
handles.TrigState = 'off';
% Update handles structure
guidata(hObject, handles);
clear a;
global a;
global clips;
global lims;
global condition;
global test
global contrast
contrast = 65000;
test = 0;
clips=[0 255]; % initialize
lims=[10 90];
a = arduino('COM7');
a.pinMode(4,'output');
a.pinMode(13,'output');
a.pinMode(9,'output')
condition = 1;


handles.video = videoinput('winvideo', 2, 'UYVY_720x480');% Convert the input images to grayscale.
handles.audio =audiorecorder(44100, 16, 1, 2);
src= getselectedsource(handles.video);
set(src, 'AnalogVideoFormat', 'ntsc_m'); % set analog video input to NTSC

    handles.video.FramesPerTrigger = 1;
    handles.video.TriggerRepeat = Inf;
    handles.video.FrameGrabInterval = 1;
    handles.vidRes = get(handles.video, 'VideoResolution');
    handles.nBands = get(handles.video, 'NumberOfBands');
    handles.hIm1 = image( zeros(handles.vidRes(2), handles.vidRes(1), handles.nBands),'parent',handles.cameraAxes);
    handles.video.ReturnedColorSpace = 'grayscale';
% initialize channel
global channel
channel = 1;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes finchscopemk4 wait for user response (see UIRESUME)
uiwait(handles.myCameraGUI);
end





% --- Outputs from this function are returned to the command line.
function varargout = FinchScopeMk4_OutputFcn(hObject, eventdata, handles)
% varargout cell array for returning output args (see VARARGOUT);
% hObject handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;
end

%% START CAMERA
function startStopCamera_Callback(hObject, eventdata, handles)
% hObject handle to startStopCamera (see GCBO)
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)
global a
% Start/Stop Camera
if strcmp(get(handles.startStopCamera,'String'),'Start Camera')
    % Camera is off. Change button string and start camera.
    a.digitalWrite(4,1); % toggle relay, turn on camera power
    set(handles.startStopCamera,'String','Stop Camera')
 
    set(handles.startAcquisition,'Enable','on');
    set(handles.captureImage,'Enable','on');  
    try

    handles.video.FramesPerTrigger = 1;
    handles.video.TriggerRepeat = Inf;
    handles.video.FramesAcquiredFcnCount=1;
    handles.video.FramesAcquiredFcn = {@imaqcallback,hObject, handles};
   start(handles.video); 
       
catch
    
    handles.video=0;
    
end
else
    % Camera is on. Stop camera and change button string.
    set(handles.startStopCamera,'String','Start Camera')
      a.analogWrite(13, 0); % turn off led on pin 13
      a.digitalWrite(4,0); % toggle relay, turn OFF camera power
  stop(handles.video)
 %  handles.hIm1 = image( zeros(handles.vidRes(2), handles.vidRes(1), handles.nBands),'parent',handles.cameraAxes);
%     set(handles.startAcquisition,'Enable','off');
    set(handles.captureImage,'Enable','off');
    set(handles.startAcquisition,'Enable','off');
end
end

%% AQUIRE ONE FRAME
% --- Nested Callback for having acquired an image
    function imaqcallback(video,event,hObject, handles)
    % access the video object in a try construct, in case the callback
    % gets fired after the object is deleted on cleanup
global test
global a
global contrast
video=handles.video;

  
% get the latest frame and clear the buffer
%TIFF
        II = getdata(video,1,'uint16');
    
        handles.size=size(II);
        
        flushdata(video);
        %I=rgb2gray(I);
    set(handles.hIm1,'cdata',II);
            colormap(bone(contrast)); % for 16 bit range

  if test == 1
  %ROI_1 calculation
       xmin=handles.shape(2);xmax=handles.shape(2)+handles.shape(3)-1;
       ymin=handles.shape(1);ymax=handles.shape(1)+handles.shape(4)-1;      
       J=II(xmin:xmax,ymin:ymax);
       A=J.*handles.setmask;
       
       TotalInt = sum(sum(A))/handles.maxInt;
 % ROI_2 calculation      
       xmin2=handles.shape2(2);xmax2=handles.shape2(2)+handles.shape2(3)-1;
       ymin2=handles.shape2(1);ymax2=handles.shape2(1)+handles.shape2(4)-1;      
       J2=II(xmin2:xmax2,ymin2:ymax2);
       A2=J2.*handles.setmask2;
       
       TotalInt2 = sum(sum(A2))/handles.maxInt2;
       
       Difference = TotalInt-TotalInt2;
       Difference = round(((Difference)/(65535))*1000); % scale between 1 and 1000
      if Difference > 150 %STIMULATION
          disp 'feedback on'
            a.digitalWrite(9,1) % stim TTL ON
            t2 = timer;
            t2.StartDelay = 0.2; %timer in seconds ( set to 200ms)
            t2.TimerFcn = @(myTimerObj, thisEvent)a.digitalWrite(9,0); % stim TTL OFF
            start(t2)
      end
      
    set(handles.edit11,'String', num2str(Difference));
  end

 % Triggering   
 if get(handles.radiobutton3, 'value') == 1 % if video recording radio  button is on

     Triggering(hObject,handles)
 end
 
       guidata(hObject, handles);
    end

%% AQUISITION
% --- Executes on button press in captureImage.
function captureImage_Callback(hObject, eventdata, handles)
newfilename = datestr(clock,30);
frame = get(get(handles.cameraAxes,'children'),'cdata'); % The current displayed frame
save(newfilename, 'frame','-v7.3');
disp('Frame saved to file');
end

% --- Executes on button press in startAcquisition.
function startAcquisition_Callback(hObject, eventdata, handles)

% Start/Stop acquisition
if strcmp(get(handles.startAcquisition,'String'),'Start Acquisition')
REC_ON(hObject,handles);
else
    % Camera is acquiring. Stop acquisition, save video data,
    % and change button string.
REC_OFF(hObject,handles);
end
end

function REC_ON(hObject,handles)
global channel;
global newfilename;
global aviobj
global condition
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

end

function  REC_OFF(hObject,handles)
global channel;
global a;
global newfilename;
global aviobj
global condition  
if condition == 2;
     stop(handles.video);
   if channel == 2; 
    stop(handles.audio);
    audiodata = getaudiodata(handles.audio);
    save(newfilename,'audiodata','-v7.3');
   end
    disp('Saving captured video...');
  
a.digitalWrite(13, 0) % turn off LED ASAP to prevent bleaching.

close(handles.video.DiskLogger);
delete(aviobj);
clear aviobj;
clear handles.audio
handles.audio = audiorecorder(44100, 16, 1, 0);

 condition = 1;
 start(handles.video)
   guidata(hObject,handles); 
end  
%a.digitalWrite(13, 0)% Turn off LED when camera is not on.
    set(handles.startAcquisition,'String','Start Acquisition');

end


%% TRIGGERING
function Triggering(hObject,handles)
global a
global b

if b ==0
    b = 1;
end
if a.analogRead(0)>500 % only do below stuff if TTL_1 is on, i.e. song is detected
a.analogWrite(13,b) % turn LED on, to set leval, 'b'
REC_ON(hObject,handles)
disp 'song detected'
else
REC_OFF(hObject,handles)
end

end


%% CLOSE FSCOPE
% --- Executes when user attempts to close FinchScopeMk4.
function myCameraGUI_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);
delete(instrfind({'Port'},{'COM7'}))
close all;
clear all;
end



%% AUDIO TOGGLE
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


%% LED CONTROL
function slider1_Callback(hObject, eventdata, handles)

global a;
maxNumberOfImages = 255;
set(hObject, 'Min', 1);
set(hObject, 'Max', maxNumberOfImages);
set(hObject, 'SliderStep', [1/maxNumberOfImages , 10/maxNumberOfImages ]);
global b
b = round(get(hObject,'Value'));
LEDpower = b/255*100;
set(handles.edit12, 'String', num2str(LEDpower));% display LED power
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

% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
global a
global b

if b == 0
else
a.analogWrite(13, 0); % turn off led on pin 13

end
end

function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double
end


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


%% TTL in/out
function radiobutton2_Callback(hObject, eventdata, handles)


end

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
if handles.TrigState == 'off'
  disp 'Triggering ON'
  handles.TrigState = 'on';
else
    handles.TrigState = 'off';
    disp 'Triggering OFF'
end
 guidata(hObject,handles); 
end

%% MODE SELECTION
function listbox1_Callback(hObject, eventdata, handles)


end

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%% GRAYSCALE CONVERSION/ RGB
function checkbox2_Callback(hObject, eventdata, handles)


end



%% -----[ ROI COORDINATES ]------%
% ROI_1 X-coordinate
function edit4_Callback(hObject, eventdata, handles)


end

function edit4_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% ROI_1 Y-coordinate
function edit5_Callback(hObject, eventdata, handles)


end
function edit5_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% ROI_1 Radius
function edit6_Callback(hObject, eventdata, handles)


end
function edit6_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% ROI_2 X-coordinate
function edit7_Callback(hObject, eventdata, handles)


end
function edit7_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% ROI_2 Y-coordinate
function edit8_Callback(hObject, eventdata, handles)


end
function edit8_CreateFcn(hObject, eventdata, handles)



if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% ROI_2 radius
function edit9_Callback(hObject, eventdata, handles)


end
function edit9_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% Difference btw ROI1 and ROI2
function edit11_Callback(hObject, eventdata, handles)


end
function edit11_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


%% ROI TOGGLES ( for slecting ROI_1 and ROI_2 )
% ROI_1 toggle button, set the region for feedback 
function togglebutton1_Callback(hObject, eventdata, handles)
% if strcmp(handles.StartPlot, 'on')==1
%     set(handles.StartPlot_button, 'String', 'Start Plot');
%     handles.StartPlot = 'off';
%     axes(handles.axes3);
%     cla;
% end
global test


handles.shape = round(getrect(handles.cameraAxes));
% check if values are correct
if handles.shape(1)<0 || handles.shape(1) > handles.size(2) || handles.shape(2)<0 || handles.shape(2) > handles.size(1) 
    disp('not valid')
    return
end

set(handles.edit4, 'String', num2str(handles.shape(1)));
set(handles.edit5, 'String', num2str(handles.shape(2)));
Dc= min(handles.shape(4),handles.shape(3)) ;
handles.shape(3)=Dc;
handles.shape(4)=Dc;

guidata(hObject, handles); 
set(handles.edit6, 'String', num2str(0.5*handles.shape(3)));

axes(handles.cameraAxes);

child=get(gca, 'Children');
if size (child,1)==1
    rectangle('Position', handles.shape, 'Curvature', [1 1], 'EdgeColor', 'g');
    handles.mask='on';
elseif size (child,1) ==2
     rectangle('Position', handles.shape, 'Curvature', [1 1], 'EdgeColor', 'g');
    handles.mask='on';
else
    set(child(2),'Position', handles.shape);
end
    
    guidata(hObject, handles);
   handles.setmask=SetMask(hObject, handles);
   handles.maxInt= sum(sum(handles.setmask));
    handles.mask='on';
    
    
   
    guidata(hObject, handles);
    % StartLive_button_Callback(hObject, eventdata, handles);
test = 1;


end


% ROI_2 toggle button, set the region for feedback 
function togglebutton2_Callback(hObject, eventdata, handles)

global test


handles.shape2 = round(getrect(handles.cameraAxes));
% check if values are correct
if handles.shape2(1)<0 || handles.shape2(1) > handles.size(2) || handles.shape2(2)<0 || handles.shape2(2) > handles.size(1) 
    disp('not valid')
    return
end

set(handles.edit7, 'String', num2str(handles.shape2(1)));
set(handles.edit8, 'String', num2str(handles.shape2(2)));
Dc= min(handles.shape2(4),handles.shape2(3)) ;
handles.shape2(3)=Dc;
handles.shape2(4)=Dc;

guidata(hObject, handles); 
set(handles.edit9, 'String', num2str(0.5*handles.shape2(3)));

axes(handles.cameraAxes);

child=get(gca, 'Children');
if size (child,1)==2
    rectangle('Position', handles.shape2, 'Curvature', [1 1], 'EdgeColor', 'r');
    handles.mask='on';
elseif size (child,1) ==2
     rectangle('Position', handles.shape2, 'Curvature', [1 1], 'EdgeColor', 'r');
    handles.mask='on';
else

    set(child(1),'Position', handles.shape2);
end
    
    guidata(hObject, handles);
   handles.setmask2=SetMask2(hObject, handles);
   handles.maxInt2= sum(sum(handles.setmask2));
    handles.mask='on';
   
    guidata(hObject, handles);
    % StartLive_button_Callback(hObject, eventdata, handles);
test = 1;




end


% RESET ROI selection
function pushbutton9_Callback(hObject, eventdata, handles)

end

%% Custom Functions

% Provide standard routine to set the mask for later  calculation of
% intensity

 function out = SetMask (hObject, handles)
handles = guidata(hObject);
    mdl=round(0.25*handles.shape(3));
    xm=round(0.5*handles.shape(3));
    ym=round(0.5*handles.shape(4));
    Y = ones(xm*2,1)*[-1*xm+1:xm]; 
    X = [-1*ym+1:ym]'*ones(1,ym*2); 
    Z = X.^2 + Y.^2; 
    Zmdl= 2*mdl^2;

    circle_mask = zeros([handles.shape(3) handles.shape(4)]); 
    circle_mask(find(Z <= Zmdl)) = 1;   
    
    out=uint16(circle_mask); 

 disp 'ROI 1 set'

    guidata(hObject, handles);
    %out = circle_mask;
    %fg2=figure(2);
    %imshow(circle_mask);
 end

    
  function out = SetMask2 (hObject, handles)
handles = guidata(hObject);
    mdl2=round(0.25*handles.shape2(3));
    xm2=round(0.5*handles.shape2(3));
    ym2=round(0.5*handles.shape2(4));
    Y2 = ones(xm2*2,1)*[-1*xm2+1:xm2]; 
    X2 = [-1*ym2+1:ym2]'*ones(1,ym2*2); 
    Z2 = X2.^2 + Y2.^2; 
    Zmdl2= 2*mdl2^2;

    circle_mask2 = zeros([handles.shape2(3) handles.shape2(4)]); 
    circle_mask2(find(Z2 <= Zmdl2)) = 1;   
    
    out=uint16(circle_mask2); 

 disp 'ROI 2 set'

    guidata(hObject, handles);
    %out = circle_mask;
    %fg2=figure(2);
    %imshow(circle_mask);
    end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)

global contrast;
maxContrast = 65535;
set(hObject, 'Min', 1);
set(hObject, 'Max', maxContrast);
set(hObject, 'SliderStep', [1/maxContrast , 10/maxContrast ]);

contrast = round(get(hObject,'Value'));
end

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end
