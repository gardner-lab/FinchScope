function ROI_TRACES=fb_extract_roi_traces(ROIS,MOV_DATA,FRAME_IDX,varargin)
%fb_select_roi selects an arbitrary number of roi's for plotting
%
%
%
%
%

colors=eval(['winter(' num2str(length(ROIS.coordinates)) ')']);
sono_colormap='hot';
baseline=3;
ave_fs=200;
save_dir='roi';
template=[];
fs=24.414e3;
per=2;
max_row=5;
min_f=0;
max_f=9e3;
lims=1;
dff_scale=20;
t_scale=.5;
resize=1;
detrend_traces=0;
crop_correct=0;
movie_fs=22;

nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})	
		case 'colors'
			colors=varargin{i+1};
		case 'sono_colormap'
			sono_colormap=varargin{i+1};
		case 'baseline'
			baseline=varargin{i+1};
		case 'ave_fs'
			ave_fs=varargin{i+1};
		case 'save_dir'
			save_dir=varargin{i+1};
		case 'template'
			template=varargin{i+1};
		case 'fs'
			fs=varargin{i+1};
		case 'per'
			per=vargin{i+1};
		case 'max_row'
			max_row=varargin{i+1};
		case 'dff_scale'
			dff_scale=varargin{i+1};
		case 't_scale'
			t_scale=varargin{i+1};
		case 'resize'
			resize=varargin{i+1};
		case 'detrend_traces'
			detrend_traces=varargin{i+1};
		case 'crop_correct'
			crop_correct=varargin{i+1};
	end
end

if resize~=1
	disp(['Adjusting ROIs for resizing by factor ' num2str(resize)]);

	for i=1:length(ROIS.coordinates)
		ROIS.coordinates{i}=round(ROIS.coordinates{i}.*resize);
	end
end


roi_n=length(ROIS.coordinates);

[rows,columns,frames]=size(MOV_DATA);
ave_time=0:1/ave_fs:frames./movie_fs;

% need to interpolate the average onto a new time bases

ROI_TRACES.raw={};
ROI_TRACES.interp_dff=zeros(length(ave_time),roi_n);
ROI_TRACES.interp_raw=zeros(length(ave_time),roi_n);

% resize if we want

if resize~=1

	disp(['Resizing movie data by factor of ' num2str(resize)]);

	frameone=imresize(MOV_DATA(:,:,1),resize);
	[new_rows,new_columns]=size(frameone);

	new_mov=zeros(new_rows,new_columns,frames);

	for j=1:frames		
		new_mov(:,:,j)=imresize(MOV_DATA(:,:,j),resize);
	end
	
	%im_resize=im_resize.*resize;
	MOV_DATA=new_mov;
	clear new_mov;

end


% roi_traces

[rows,columns,frames]=size(MOV_DATA);
roi_t=zeros(frames,roi_n);

if length(FRAME_IDX)~=frames
	warning('Trial %i file %s may be corrupted, frame indices %g not equal to n movie frames %g',...
		i,mov_listing{i},length(FRAME_IDX),frames);	
	FRAME_IDX=FRAME_IDX(1:frames);
end

timevec=FRAME_IDX./fs;

disp('Computing ROI averages...');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

% unfortunately we need to for loop by frames, otherwise
% we'll eat up too much RAM for large movies

for j=1:roi_n
	fprintf(1,formatstring,round((j/roi_n)*100));

	for k=1:frames
		tmp=MOV_DATA(ROIS.coordinates{j}(:,2),ROIS.coordinates{j}(:,1),k);
		roi_t(k,j)=mean(tmp(:));
	end
end

fprintf(1,'\n');

dff=zeros(size(roi_t));

% interpolate ROIs to a common timeframe

for j=1:roi_n

	tmp=roi_t(:,j);

	if baseline==0
		norm_fact=mean(tmp,3);
	elseif baseline==1
		norm_fact=median(tmp,3);
	elseif baseline==2
		norm_fact=trimmean(tmp,trim_per,'round',3);
	else
		norm_fact=prctile(tmp,per);
	end

	dff(:,j)=((tmp-norm_fact)./norm_fact).*100;

	yy=interp1(timevec,dff(:,j),ave_time,'spline');
	yy2=interp1(timevec,tmp,ave_time,'spline');

	ROI_TRACES.interp_dff(:,j)=yy;
	ROI_TRACES.interp_raw(:,j)=yy2;

end


ROI_TRACES.raw=roi_t; % store for average
ROI_TRACES.interp_t=ave_time;
ROI_TRACES.t=FRAME_IDX./fs;
