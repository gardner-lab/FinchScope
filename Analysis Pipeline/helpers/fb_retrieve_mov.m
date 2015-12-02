function [MOV_DATA,FRAME_IDX]=fb_retrieve_mov(FILE,varargin)
%fb_retrieve_mov retrieves the movie data for a split mat file (the mat
%files in the 'mat' directory created by fb_data_split)
%
%	[MOV_DATA,FRAME_IDX]=fb_retrieve_mov(FILE,varargin)
%
%	FILE
%	specify the filename to process, if left empty the user is presented 
%	with a GUI to select the file (default: empty)
%
%	MOV_DATA
%	rows x columns x frame matrix containing the movie data
%
%	FRAME_IDX
%	timestamps (in samples) for the onset of each frame, divide
%	by the sample rate to convert to time (in s)
%
%	the following may be specified as parameter/value pairs:
%
%		im_resize
%		resize factor for the movie data (<1 downsamples, >1 upsamples, 1=no change, default: 1)
%
%
%

FRAME_IDX=[];
MOV_DATA=[];

nparams=length(varargin);

im_resize=1;

% parameter collection

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'im_resize'
			im_resize=varargin{i+1};
	end
end

% if no file is specified, get one

if nargin<1 | isempty(FILE)
	[filename,pathname]=uigetfile({'*.mat';'*.tif'},'Pick a .mat file to retrieve movie data for',fullfile(pwd));
	[path,file,ext]=fileparts(fullfile(pathname,filename));
else
	[path,file,ext]=fileparts(FILE);
end


% movie filename one directory down

if strcmp(ext,'.mat')
	mov_filename=fullfile([file '.tif']);	
	load(fullfile(path,[file ext]),'rising_data','fs');
elseif strcmp(ext,'.tif')
	mov_filename=[file '.tif'];
end

image_info=imfinfo(mov_filename);

% get the frame indices, marked by rising edges in the split signal

nframes=length(image_info);

width=image_info(1).Width;
height=image_info(1).Height;

if ~isempty(im_resize)
	width=width*im_resize;
	height=height*im_resize;
end

if strcmp(ext,'.mat')
	
	FRAME_IDX=find(rising_data>0);
	frame_val=rising_data(FRAME_IDX);

	% get the movie specifications

	first_frame=frame_val(1);
	last_frame=frame_val(end);
	
elseif strcmp(ext,'.tif')

	first_frame=1;
	last_frame=nframes;

end

mov_idx=first_frame:last_frame;
MOV_DATA=zeros(height,width,length(mov_idx));

% get the actual movie data

disp('Retrieving movie data...');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

counter=1;
for i=first_frame:last_frame
	imdata=imread(mov_filename,i);

	fprintf(1,formatstring,round((counter/length(mov_idx))*100));

	if ~isempty(im_resize)
		imdata=imresize(imdata,im_resize);
	end

	MOV_DATA(:,:,counter)=imdata;
	counter=counter+1;
end

fprintf(1,'\n');

% FRAME_IDX is used to determine the closest point in time for the onset
% of a given frame
