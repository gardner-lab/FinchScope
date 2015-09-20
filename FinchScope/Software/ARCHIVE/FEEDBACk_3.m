function varargout = FEEDBACk_3(varargin)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FEEDBACk_3_OpeningFcn, ...
                   'gui_OutputFcn',  @FEEDBACk_3_OutputFcn, ...
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



% --- Executes just before FEEDBACk_3 is made visible.
function FEEDBACk_3_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.mask = 'off';
handles.StartPlot = 'off';

clear plswork;
global plswork;
plswork = arduino('COM3');
plswork.pinMode(9,'output')
plswork.pinMode(4,'input')

plswork.pinMode(13,'output');
global IntData
global condition
global counterA
global threshCross
global counter
condition = 1;
counter = 1;

threshCross(1,1) = 0;
threshCross(1,2) = 0;
counterA = 1;

IntData=[];
    % reset and start up video capture
   % imaqreset
    %if size(varargin) == [1 1]        
    %    vid = videoinput(varargin{1});
    %else
    %    vid = videoinput('winvideo',2);
    %end
try
   
    inf = imaqhwinfo('winvideo',1);
    vid = videoinput('winvideo',1);
    handles.vid=vid;
    set(handles.vidFormat, 'String', inf.SupportedFormats);

    selNr=get(handles.vidFormat, 'Value');
    selList=get(handles.vidFormat,'String');
    %set(vid.VideoFormat, 'String', selList(selNr));
catch
    
    disp 'no video input'
    handles.vid=0;
end
 src = getselectedsource(vid);
 %AUDIO on
handles.audio =audiorecorder(44100, 8, 1, 0);

   %     src.BacklightCompensation  = 'off'; % new
   %     src.Exposuremode = 'manual';
        %src.WhiteBalanceMode = 'manual'; %new
        %src.Exposure = str2num (handles.Gain_text,'String');
        %src.Brghtness =str2num (handles.Gain_text,'String');
        
    vid.FramesPerTrigger = 1;
    vid.TriggerRepeat = Inf;
    vid.FrameGrabInterval = 1;

        %%%src.ColorEnable = 'off';
    %set up an images to put pictures in
    vidRes = get(vid, 'VideoResolution');
    nBands = get(vid, 'NumberOfBands');
    handles.hIm1 = image( zeros(vidRes(2), vidRes(1), nBands),'parent',handles.axes1);
    
    % get handles of some important objects (to avoid referencing handles)
    ax1 = handles.axes1;
    axes(ax1);
    colormap(gray);
    daspect([1,1,1]);
    
    ax3 = handles.axes3;

    % provide some information to the user
    a = vid.Name;
    str = ['Video Input Device: ' a];
    set(handles.txt_device1,'string',str);


    guidata(hObject, handles);
  
end

% --- Outputs from this function are returned to the command line.
function varargout = FEEDBACk_3_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
global b


% delete objects
try
    vid = handles.vid;
    stop(vid)
    delete(vid)
    clear vid
 b = 0;
 
    delete(instrfind({'Port'},{'COM3'}))
     handles.aviobj = close(handles.aviobj);
end

% Finally, close the figure
delete(hObject);

end

% --- Executes on selection change in vidFormat.
function vidFormat_Callback(hObject, eventdata, handles)
% hObject    handle to vidFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns vidFormat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from vidFormat
stop(vid);
delete(vid);
StartLive_button_Callback(hObject, eventdata, handles)
end




% --- Executes on button press in SetRegion_button.
function SetRegion_button_Callback(hObject, eventdata, handles)
% hObject    handle to SetRegion_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vid=handles.vid;
%% USING OVERVIEW
if strcmp(handles.StartPlot, 'on')==1
    set(handles.StartPlot_button, 'String', 'Start Plot');
    handles.StartPlot = 'off';
    axes(handles.axes3);
    cla;
end
handles.shape = round(getrect(handles.axes1));
% check if values are correct
if handles.shape(1)<0 || handles.shape(1) > handles.size(2) || handles.shape(2)<0 || handles.shape(2) > handles.size(1) 
    disp('not valid')
    return
end

set(handles.Xc_text, 'String', num2str(handles.shape(1)));
set(handles.Yc_text, 'String', num2str(handles.shape(2)));
if get(handles.CircMask_button, 'value') == 1
Dc= min(handles.shape(4),handles.shape(3)) ;
handles.shape(3)=Dc;
handles.shape(4)=Dc;
end
%guidata(hObject, handles); 
set(handles.Rc_text, 'String', num2str(0.5*handles.shape(3)));

axes(handles.axes1);

child=get(gca, 'Children');
if size (child,1)==1
    rectangle('Position', handles.shape, 'Curvature', [1 1], 'EdgeColor', 'b');
    handles.mask='on';
else
    set(child(1),'Position', handles.shape);
end
    
    guidata(hObject, handles);
   handles.setmask=SetMask(hObject, handles);
   handles.maxInt= sum(sum(handles.setmask));
    handles.mask='on';
   
    guidata(hObject, handles);
     StartLive_button_Callback(hObject, eventdata, handles);
end





% --- Executes on button press in Default_button.
function Default_button_Callback(hObject, eventdata, handles)
% hObject    handle to Default_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)   
if strcmp(handles.StartPlot, 'on')==1
    set(handles.StartPlot_button, 'String', 'Start Plot');
    handles.StartPlot = 'off';
    axes(handles.axes3);
    cla;
end

set(handles.CircMask_button, 'Value', 1);
    xc=round(handles.size(2)/2);
    yc=round(handles.size(1)/2);
    Rc=round(handles.size(1)*0.1);
    xc=xc-Rc;
    yc=yc-Rc;
    handles.shape = [xc yc 2*Rc 2*Rc];
    set(handles.Xc_text, 'String', num2str(handles.shape(1)));
    set(handles.Yc_text, 'String', num2str(handles.shape(2)));
    set(handles.Rc_text, 'String', num2str(0.5*handles.shape(3)));

    axes(handles.axes1);
    child=get(gca, 'Children');

    if size (child,1)==1
        rectangle('Position', handles.shape, 'Curvature', [1 1], 'EdgeColor', 'b')
    else
        set(child(1),'Position', handles.shape);
    end
    
    
    guidata(hObject, handles);
    
    handles.setmask=SetMask(hObject, handles);
    handles.maxInt= 2.55*sum(sum(handles.setmask));
    handles.mask='on';
   
    guidata(hObject, handles);
     StartLive_button_Callback(hObject, eventdata, handles);

end





% --- Executes on button press in StartLive_button.
function StartLive_button_Callback(hObject, eventdata, handles)
% hObject    handle to StartLive_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.output = hObject;

vidFormat = get(handles.vidFormat, 'String');
vid = handles.vid;
src = getselectedsource(vid);

fps=str2num(get(handles.framesPerSecond, 'String'));


% vid=handles.vid;
 set(handles.StopLive_button, 'Enable', 'on');
 
 set(handles.StartLive_button, 'Enable', 'off');
% Initialise the video input
try
    % Use the timer to process input frames
   
    vid.TimerPeriod = 1/fps; % try updating 15 times/second.
    vid.TimerFcn = {@imaqcallback, hObject, handles};
    
    % Alternative is to use the FramesAcquiredFcn if we need to ensure
    % that we process every frame.
    %vid.FramesAcquiredFcnCount=1;
    %vid.FramesAcquiredFcn = {@imaqcallback};

    start(vid);
        
catch
    disp 'no video input'
    handles.vid=0;
    
end

% Update handles structure
guidata(hObject, handles);
end % Start buttonpress function 



% --- Nested Callback for having acquired an image
    function imaqcallback(vid,event,hObject, handles)
    % access the video object in a try construct, in case the callback
    % gets fired after the object is deleted on cleanup
   vid=handles.vid;
   global IntData
   global II
    try
        % get the latest frame and clear the buffer
        II = getdata(vid,1);
        handles.size=size(II);
        flushdata(vid);
        %I=rgb2gray(I);
        set(handles.hIm1,'CData',II);
               
        guidata(hObject, handles);     
     end %try
     
     if strcmp(handles.mask, 'on')==1
       if strcmp(handles.StartPlot,'on')==1
        
       end
       xmin=handles.shape(2);xmax=handles.shape(2)+handles.shape(3)-1;
       ymin=handles.shape(1);ymax=handles.shape(1)+handles.shape(4)-1;      
      
       J=II(xmin:xmax,ymin:ymax);
       A=J.*handles.setmask;
       
       TotalInt = sum(sum(A))/handles.maxInt;
       
       set(handles.Int_text,'String', num2str(TotalInt));  
     PlotIntensity(hObject, handles, TotalInt,II);
    
    %%% Use these two lines to show the area that is actually being used
    %%% In the calculation of the Intensity
       %fig2=figure(2);
       %imshow(A);
     end
     
    end %function imaqcallback

     function PlotIntensity(hObject, handles, TotalInt,II)
    %handles=guihandles(hObject, handles)
    global IntData;
    global threshCross;
    global counterA; 
    global plswork;
    global b;
    global newfilename


    guidata(hObject, handles);
%%%LED TRIGGGER%%%%

    
if strcmp(handles.StartPlot,'on')==1
 

    %=======[SONG DETECTION]==========%  
        if plswork.analogRead(0)>500 % only do below stuff if TTL_1 is on, i.e. song is detected
    
plswork.analogWrite(13,b) % turn LED on, to set leval, 'b'
 guidata(hObject, handles);
         if get(handles.VidRec_button, 'value') == 1 % if video recording radio  button is on
         %aviobj = addframe(aviobj, II);    
         REC_ON(hObject, handles);
        
         end
    t=size(IntData,1)+1;
           IntData(t,1)=t/30; %x axis scaling
           IntData(t,2)=TotalInt; %Pixel values
           plot(handles.axes3,IntData(:,1),IntData(:,2),'b',threshCross(:,1),threshCross(:,2),'r*');
           hold on
     
    if get(handles.dataRec, 'value')==1 % If data (thresh information) recording button is on
   % fprintf(handles.fid, '%f , %f \n',IntData(t,:));
    end
    
 
%================[ FEEDBACK BLOCK ]================%
%% if plswork.analogRead(1)>400; % only do below stuff if TTL_2 is on, i.e. syllable is detected     

if TotalInt>80 %%%feedback paradigm, if avg ROI is over the thresholded amount125
    counterA = counterA+1;
    counterAA = num2str(counterA);
    disp 'threshold crossed'
    disp(counterAA);
     threshCross(counterA,1) = IntData(t,1);
     threshCross(counterA,2) = IntData(t,2);
      counterA = counterA+1;
      
 STIM; % STIM TTL output, in a function
         guidata(hObject, handles);

end
%       end
%===================================================%    
        else
     plswork.analogWrite(13,0)
REC_OFF(hObject,handles)
        IntData =[];
        threshCross = [];
        threshCross(1,1) = 0;
        threshCross(1,2) = 0;
        
        end
else
    
        IntData =[];
        threshCross = [];
        threshCross(1,1) = 0;
        threshCross(1,2) = 0;
 
        

end

       guidata(hObject, handles);
    end
    
    
   function STIM()
 
    global plswork;

 plswork.digitalWrite(9,1) % stim TTL ON
 t2 = timer;
t2.StartDelay = 0.2;
t2.TimerFcn = @(myTimerObj, thisEvent)plswork.digitalWrite(9,0); % stim TTL OFF
start(t2)

 end  
    
 function REC_ON(hObject, handles)
  guidata(hObject,handles);
 global condition
 global aviobj
 global newfilename

     if condition ==1;
         newfilename = datestr(clock,30);
  stop(handles.vid);
    handles.vid.LoggingMode = 'Disk&Memory';
    aviobj = VideoWriter(newfilename);
    handles.vid.DiskLogger= aviobj;
  guidata(hObject, handles);
record(handles.audio);
start(handles.vid)
record(handles.audio)

condition = 2;
     end
      guidata(hObject,handles); 
 end
 
 function REC_OFF(hObject, handles)
   guidata(hObject,handles);
 global condition
 global aviobj
 global newfilename
 global IntData
 global threshCross
 
 if condition ==2;
stop(handles.vid);
stop(handles.audio);
threshdata = threshCross;
ROIdat= IntData;
audiodata = getaudiodata(handles.audio);
save(newfilename,'audiodata','threshdata','ROIdat','-v7.3');
close(handles.vid.DiskLogger);
delete(aviobj);
clear aviobj;
clear handles.audio
handles.audio =audiorecorder(44100, 16, 1, 0);

 condition = 1;
 start(handles.vid)
   guidata(hObject,handles);
 end
 end
 
    
    % make a uint8 image from img
function out = make_uint8_img(img)
    if (islogical(img))
        out = uint8(img)*255;
    elseif (~isinteger(img))
        out = uint8(img*255);
    else
        out = uint8(img);
    end
end
% make 3 channel image
function out = make_3channel_img(img)
    if ndims(img) == 2
        out = zeros(size(img,1), size(img,2), 3, 'uint8');
        out(:,:,1) = img;
        out(:,:,2) = img;
        out(:,:,3) = img;
    else
        out = img;
    end
end
    
    % Provide standard routine to set the mask for later  calculation of
    % intensity
    function out = SetMask (hObject, handles)
  
    mdl=round(0.25*handles.shape(3));
    xm=round(0.5*handles.shape(3));
    ym=round(0.5*handles.shape(4));
    Y = ones(xm*2,1)*[-1*xm+1:xm]; 
    X = [-1*ym+1:ym]'*ones(1,ym*2); 
    Z = X.^2 + Y.^2; 
    Zmdl= 2*mdl^2;

    circle_mask = zeros([handles.shape(3) handles.shape(4)]); 
    circle_mask(find(Z <= Zmdl)) = 1;   
    
    out=uint8(circle_mask);
    %out = circle_mask;
    %fg2=figure(2);
    %imshow(circle_mask);
    end
    
    
% --- Executes on button press in StopLive_button.
function StopLive_button_Callback(hObject, eventdata, handles)
global plswork

 set(handles.StopLive_button, 'Enable', 'off');
 set(handles.StartLive_button, 'Enable', 'on');
plswork.analogWrite(13, 0);
  
 % video is open
    %delete(handles.vid);
    %clear handles.vid;
    stop(handles.vid);
    handles.hIm1 = image( zeros(handles.size(1), handles.size(2), 1),'parent',handles.axes1);
    guidata(hObject, handles);
    %return
end


% --- Executes on button press in clearPlot.
function clearPlot_Callback(hObject, eventdata, handles)
% hObject    handle to clearPlot (see GCBO)f
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes3);
cla;
end

% --- Executes on button press in StartPlot_button.
function StartPlot_button_Callback(hObject, eventdata, handles)
% hObject    handle to StartPlot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global IntData;
global plswork;

if strcmp(handles.mask, 'off')==1
    disp('no mask selected');
    return
end


if strcmp(handles.StartPlot, 'off')==1
    set(handles.StartPlot_button, 'String', 'Stop Plot');
    handles.StartPlot = 'on';
    IntData=[];
    
    % determine filename and create avi file
    
    strcmp(get(handles.FileName_text,'String'),'')
    if isempty(get(handles.FileName_text,'String'))==1
        video_filename_pattern = 'video####.avi';
    else
        video_filename_pattern = get(handles.FileName_text,'String');
    end
    video_ending = '.avi';
    data_ending='.txt';
    dir = get(handles.dirName, 'String');
    
    
    filename = next_filename(video_filename_pattern);
    video_filename= strcat(dir, filename, video_ending);
    data_filename= strcat(dir, filename, data_ending);
    
    if get(handles.dataRec, 'value')==1 
    handles.fid=fopen(data_filename,'at');
    end
    video_fps= 1/ handles.vid.TimerPeriod;
    video_codec_quality = 100;
    selNr=get(handles.fourCcCodec, 'Value');
    selList=get(handles.fourCcCodec,'String');
    video_codec_fourcc = char(selList(selNr));
    
    if get(handles.VidRec_button, 'value') == 1

   
%     
    end

    StartLive_button_Callback(hObject, eventdata, handles);
else
    set(handles.StartPlot_button, 'String', 'Start Plot');
    handles.StartPlot = 'off';
    %axes(handles.axes3);
    %cla;
     if get(handles.VidRec_button, 'value') == 1
         fclose(handles.fid);
     end
    if get(handles.VidRec_button, 'value') == 1
% delete(aviobj);
    end
end
    
    IntData =[];
    guidata(hObject, handles);
    StartLive_button_Callback(hObject, eventdata, handles);
end
    



% --- Executes during object creation, after setting all properties.
function FileName_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileName_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% returns a new filename for pattern if there is one
% otherwise returns pattern itself.
function out = next_filename(pattern)
    % save pattern ending and strip it off
    
    pattern = getfilename_root(pattern);

    % get position of all # chars
    pos = strfind(pattern, '#');
    if isempty(pos)
        out = pattern;
        return
    end

    % find position and length of (first) ###-field
    num_pos = pos(1);
    num_len = 1;
    for i=2:length(pos)
        if (pos(i)-pos(i-1))>1
            break
        end
        num_len = num_len + 1;    
    end
    prefix = pattern(1:num_pos-1);
    suffix = pattern(num_pos+num_len:length(pattern));

    % find a new filename with binary search
    i=1;
    low_bound = 0;
    while true
        if videofile_exists([prefix, extnum(i, num_len), suffix])
            low_bound = i;
            i=i*2;
            if low_bound>=10^num_len
                out = pattern; % no filename left!
                return;
            end
        else
            a = low_bound + 1;
            b = min(i - 1, 10^num_len-1);
            while a<=b
                m = (a+b)/2;
                if videofile_exists([prefix, extnum(m, num_len), suffix])
                    a=m+1;
                else
                    b=m-1;
                end
            end

            if a==10^num_len
                out = pattern;
            else
                out = [prefix, extnum(a, num_len), suffix];
            end
            return;
        end
    end
end


% true, if the avi or mpg file exists
function yes = videofile_exists(filename_root)
    yes = exist(strcat(filename_root, '.avi')) | exist(strcat(filename_root, '.txt'));
end

% example: extnum(123, 5) = '00123'
function x = extnum(nr, digits)
    x = num2str(nr);
    x = [repmat('0', 1, digits-length(x)),x];
end

% example: getfilename_root('Hello.txt') = 'Hello'
function out = getfilename_root(filename)
    K = strfind(filename, '.');
    if isempty(K)
        out = filename;
    else
        out = filename(1:(K(size(K,2))-1));
    end
end

% example: getfilename_ending('Hello.txt') = '.txt'
function out = getfilename_ending(filename)
    K = strfind(filename, '.');
    if isempty(K)
        out = '';
    else
        out = filename((K(size(K,2))):size(filename,2));
    end
end

% --- Executes on button press in selDirName.
function selDirName_Callback(hObject, eventdata, handles)
% hObject    handle to selDirName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curDir = get(handles.dirName, 'String');
DirName = uigetdir(curDir);
DirName =strcat(DirName, '\');
set(handles.dirName, 'String', DirName);

end

function fourCcCodec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fourCcCodec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    %video_codec_fourcc = 'IV50'; % Niet aanwezig op deze computer
    %video_codec_fourcc ='Indeo3';
    %video_codec_fourcc ='Indeo5';Werken met kleurenmap
     
    %%%%video_codec_fourcc ='RLE';% is goed met graymap en 100% 
    %video_codec_fourcc ='iYUV';  %%% Werkt ook OK met graymap en 100% 
    %video_codec_fourcc ='Cinepak';
    %video_codec_fourcc ='MSVC';
    %video_codec_fourcc = 'none';
    %video_codec_fourcc ='msYUV';
    %video_codec_fourcc ='mp43';% Laatste beste succes ook met graymap?!
end


function framesPerSecond_Callback(hObject, eventdata, handles)
% hObject    handle to framesPerSecond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framesPerSecond as text
%        str2double(get(hObject,'String')) returns contents of framesPerSecond as a double
 vid=handles.vid;
%  src = getselectedsource(vid);
 stop(vid);
 StartLive_button_Callback(hObject, eventdata, handles);
% try 
%  src.Gain = str2num (get(handles.Gain_text,'String'));
% end
% 
% %         src.Brightness =str2num (get(handles.Gain_text,'String'));
% %         disp('set brightness OK');
%  start(vid);
guidata(hObject, handles);
end


function Gain_text_Callback(hObject, eventdata, handles)
% hObject    handle to Gain_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gain_text as text
%        str2double(get(hObject,'String')) returns contents of Gain_text as a double
 vid=handles.vid;
 src = getselectedsource(vid);
 stop(vid);
try 
 src.Gain = str2num (get(handles.Gain_text,'String'));
end
try
    src.Gamma = str2num (get(handles.Gain_text,'String'));
    src.Hue = str2num (get(handles.Gain_text,'String'));
    src.Saturation = str2num (get(handles.Gain_text,'String'));
end

%         src.Brightness =str2num (get(handles.Gain_text,'String'));
%         disp('set brightness OK');
 start(vid);
guidata(hObject, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% NOT NECESSARY CALLBACKS

% --- Executes on button press in CircMask_button.
function CircMask_button_Callback(hObject, eventdata, handles)
% hObject    handle to CircMask_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CircMask_button

end

% --- Executes on button press in VidRec_button.
function VidRec_button_Callback(hObject, eventdata, handles)
% hObject    handle to VidRec_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VidRec_button

end





% --- Executes during object creation, after setting all properties.
function Gain_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gain_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


% --- Executes on button press in dataRec.
function dataRec_Callback(hObject, eventdata, handles)
% hObject    handle to dataRec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dataRec


end



function Xc_text_Callback(hObject, eventdata, handles)
% hObject    handle to Xc_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xc_text as text
%        str2double(get(hObject,'String')) returns contents of Xc_text as a double
end

% --- Executes during object creation, after setting all properties.
function Xc_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xc_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function Yc_txt_Callback(hObject, eventdata, handles)
% hObject    handle to Yc_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Yc_txt as text
%        str2double(get(hObject,'String')) returns contents of Yc_txt as a double

end

% --- Executes during object creation, after setting all properties.
function Yc_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Yc_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function Rc_text_Callback(hObject, eventdata, handles)
% hObject    handle to Rc_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rc_text as text
%        str2double(get(hObject,'String')) returns contents of Rc_text as a double
end


% --- Executes during object creation, after setting all properties.
function Rc_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rc_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end  
end



function FileName_text_Callback(hObject, eventdata, handles)
% hObject    handle to FileName_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileName_text as text
%        str2double(get(hObject,'String')) returns contents of FileName_text as a double

end

function dirName_Callback(hObject, eventdata, handles)
% hObject    handle to dirName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dirName as text
%        str2double(get(hObject,'String')) returns contents of dirName as a double
end

% --- Executes during object creation, after setting all properties.
function dirName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dirName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end





% --- Executes on selection change in fourCcCodec.
function fourCcCodec_Callback(hObject, eventdata, handles)
% hObject    handle to fourCcCodec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns fourCcCodec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fourCcCodec

end
% --- Executes during object creation, after setting all properties.








% --- Executes during object creation, after setting all properties.
function vidFormat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vidFormat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end





% --- Executes during object creation, after setting all properties.
function framesPerSecond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framesPerSecond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)

global plswork;
maxNumberOfImages = 255;
set(hObject, 'Min', 1);
set(hObject, 'Max', maxNumberOfImages);
set(hObject, 'SliderStep', [1/maxNumberOfImages , 10/maxNumberOfImages ]);
global b
b = round(get(hObject,'Value'));
LEDpower = b/255*100 % display LED power
plswork.analogWrite(13, b); % led on pin 13
end


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


% RECORD (without feedback)
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global condition
global plswork
% Start/Stop acquisition
if strcmp(get(handles.pushbutton10,'String'),'Start Acquisition')
    % Camera is not acquiring. Change button string and start acquisition.
    set(handles.pushbutton10,'String','Stop Acquisition');

    condition = 1;
REC_ON(hObject, handles)

else
    REC_OFF(hObject, handles)
plswork.analogWrite(13, 0);
 set(handles.pushbutton10,'String','Start Acquisition');
end
end


%SNAPSHOT
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
