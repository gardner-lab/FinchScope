function roi_ave= FS_Plot_ROI(ROIS,varargin)
% FS_Plot_ROI.m

% Selects an arbitrary number of roi's for plotting. Run in .mat directory.
%   Created: 2015/08/02
%   By: WALIII
%   Updated: 2016/02/15
%   By: WALIII

%% Starting Variables
colors=eval(['winter(' num2str(length(ROIS.coordinates)) ')']);
sono_colormap='hot';
baseline=3;
n = 1; % How much to interpolate by?
ave_fs=25*n; % multiply by a variable 'n' if you want to interpolate
save_dir='roi';
template=[];
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
counteri = 1;

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
	end
end



mkdir(save_dir);
% ROIS is a cell array of image indices returned by fb_select_roi

mov_listing=dir(fullfile(pwd,'*.mat'));
mov_listing={mov_listing(:).name};


for i=1:length(mov_listing)
clear tmp; clear mov_data; clear frames; clear mic_data; clear ave_time; clear offset2; clear vid_times; clear mov_data_aligned;
warning('off','all')
	disp(['Processing file ' num2str(i) ' of ' num2str(length(mov_listing))]);
	load(fullfile(pwd,mov_listing{i}),'mov_data_aligned','mic_data','fs','vid_times','video','audio','mov_data','motif');
warning('on','all')



G = exist('mov_data');

if G == 1;
% Get Audio/Video template matched offsets
[mov_data2, n] = FS_Format(mov_data,1);


    	disp(' Template match detected: Compensating for A/V mis-alignment...')
		 offset2 = (vid_times(:,1)-mic_data(1,2)/fs); % vid_times(:,1)-(vid_times(1,1)+(vid_times(1,1)-mic_data(1,2)/fs))
		 timevec=(offset2'); %movie_fs
		 G = diff(vid_times(:,1), 1);

		 mic_data= mic_data(:,1); % only use data column

else
            	disp(' Non-template matched video: proceed to align to A/V timestamps...')
	mov_data = video.frames;
	vid_times = video.times;
	mic_data = audio.data;
    fs = audio.rate;
	G = diff(vid_times(:,1), 1);
	timevec = (vid_times');
[mov_data2, n] = FS_Format(mov_data,1);



end




mov_data = double(mov_data2);

% Check For Dropped Frames:
if any(G >.25) %0.05 for 30fps
    disp('   **    Dropped Frame detected    **  ')
else
    disp('No Dropped Frames Detected')


% Format ROIs
[rows,columns,frames]=size(mov_data);

roi_n=length(ROIS.coordinates);
roi_t=zeros(roi_n,frames);
ave_time=0:1/ave_fs:length(mic_data)/fs;
[path,file,ext]=fileparts(mov_listing{i});
save_file=[ file '_roi' ];


	% resize if we want to add this later...



	disp('Computing ROI averages...');

	[nblanks,formatstring]=fb_progressbar(100);
	fprintf(1,['Progress:  ' blanks(nblanks)]);

	% unfortunately we need to for loop by frames, otherwise
	% we'll eat up too much RAM for large movies

	for j=1:roi_n
        
		fprintf(1,formatstring,round((j/roi_n)*100));

		for k=1:frames

			tmp=mov_data(ROIS.coordinates{j}(:,2),ROIS.coordinates{j}(:,1),k);
			roi_t(j,k)=mean(tmp(:));
		end
	end

	fprintf(1,'\n');
	dff=zeros(size(roi_t));

roi_ave.analogIO_dat{counteri} = mic_data;
roi_ave.analogIO_time{counteri}= (1:length(mic_data))/fs;
roi_ave.interp_time{counteri} = ave_time;
                G2 = exist('motif');
                if G2 == 1;
                    roi_ave.motif{counteri} = motif;
                end
                
%------[ Background and Neuropil]--------%
        % Background & Neuropil

[Bgnd, Npil] = FS_PreMotor_Neuropil(mov_data,ROI);

roi_ave.Bgnd{counteri}=interp1(timevec,Bkgd,ave_time,'spline');
roi_ave.Npil{counteri}=interp1(timevec,Npil,ave_time,'spline');

%------[ PROCESS ROIs]--------%
% interpolate ROIs to a common timeframe
	for j=1:roi_n
clear tmp; clear dff; clear yy2; clear yy;


		tmp=roi_t(j,:);
        tmp = tmp(:,(1:size(timevec,2)));
		if baseline==0
			norm_fact=mean(tmp,3);
		elseif baseline==1
			norm_fact=median(tmp,3);
		elseif baseline==2
			norm_fact=trimmean(tmp,trim_per,'round',3);
		else
			norm_fact=prctile(tmp,per);
		end

% Interpolate to timescale determined by 'n' paramater (see above)
dff(j,:)=((tmp-norm_fact)./norm_fact).*100;
yy=interp1(timevec,dff(j,:),ave_time,'spline');
yy2=interp1(timevec,tmp,ave_time,'spline');

roi_ave.interp_dff{j,counteri}=yy;
roi_ave.interp_raw{j, counteri}=yy2;
roi_ave.raw_time{j,counteri} = timevec;
roi_ave.raw_dat{j,counteri} = tmp;

    end
				roi_ave.filename{counteri}=mov_listing{i};
                        counteri = counteri+1; % In case we need to skip ROIs due to dropped frames, (instead of using u in the loop)


                
end
end

save(fullfile(save_dir,['ave_roi.mat']),'roi_ave');
disp('Generating average ROI figure...');
