function FS_TemplateMatch(TEMPLATE,varargin)
%FS_TemplateMatch allows the user to select a song template, and then attempts to find
%matches to the template through a running Euclidean distance score (similar to SAP)
%
%	fb_template_match(TEMPLATE,varargin)
%
%	TEMPLATE
%	template (vector, default: empty, user selects via GUI)
%
%	the following may be passed as parameter/value pairs:
%
%		fs
%		sampling frequency of the TDT data (float, default: 24.414e3)
%
%		movie_fs
%		sampling frequency of the movie file (float, default: 20)
%
%		colors
%		colormap to use for template and extraction sonograms (string, default: hot)
%
%		min_f
%		minimum frequency to show for template and extraction sonograms (float, default: 0)
%
%		max_f
%		maximum frequency to show for template and extraction sonograms (float, default: 10e3)
%
%		extract_sounds
%		indicates whether or not to extract and save hits (logic, default: 1)
%
%		im_resize
%		resize factor for movie files (<1 downsamples, >1 upsamples, 1 or empty no change, default: empty)
%
%		padding
%		two element vector that specifies how many seconds before and after the match to extract
%		(2 float vector, default: [.2 .2])
%
% set the defaults

nparams=length(varargin);
fs=48.000e3;
movie_fs=30;
colors='hot';
min_f=0;
max_f=12e3;
extract_sounds=1;
out_dir='';
sound_dir='';
template_data=[];
im_resize=[]; % setting this to .5 seems reasonable, depends on required resolution
padding=[0.25 .75];

% parameter collection

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'fs'
			fs=varargin{i+1};
		case 'colors'
			colors=varargin{i+1};
		case 'storedir'
			storedir=varargin{i+1};
		case 'extract_sounds'
			extract_sounds=varargin{i+1};
		case 'out_dir'
			out_dir=varargin{i+1};
		case 'sound_dir'
			sound_dir=varargin{i+1};
		case 'template_data'
			template_data=varargin{i+1};
		case 'im_resize'
			im_resize=varargin{i+1};
		case 'padding'
			padding=varargin{i+1};
		case 'movie_fs'
			movie_fs=varargin{i+1};
	end
end

if isempty(sound_dir)
	sound_dir=pwd;
end


% leave option to skip clustering and simply return scores
% what to call the extraction directory?

if isempty(out_dir)
	out_dir=fullfile(pwd,'extraction');
end


% collect all directories in the phrase directory
% have we already extracted a template?

% remove cruft from old extractions

if exist(out_dir,'dir')
	disp('Looks like you have extracted before...');
	response=[];
	while isempty(response)
		response=input('Would you like to overwrite the old extraction (y or n)?  ','s');
		switch (lower(response))
			case 'y'
				if exist(fullfile(out_dir,'mov'),'dir')
					rmdir(fullfile(out_dir,'mov'),'s');
				end
				if exist(fullfile(out_dir,'gif'),'dir')
					rmdir(fullfile(out_dir,'gif'),'s');
				end
			case 'n'
				disp('Quitting...');
				return;
			otherwise
				response=[];
		end
	end
end

mkdir(out_dir);

if isempty(template_data)
	if ~exist(fullfile(out_dir,'template_data.mat'))

		if nargin<1 | isempty(TEMPLATE)
			TEMPLATE=select_template(pwd);
		end

		% compute the features of the template

		disp('Computing the spectral features of the template');
		template_features=fb_smscore(TEMPLATE,fs);
		save(fullfile(out_dir,'template_data.mat'),'TEMPLATE','template_features');

	else
		disp('Loading stored template...');
		load(fullfile(out_dir,'template_data.mat'),'TEMPLATE','template_features');
	end


	template_fig=figure('Visible','off');
	[template_image,f,t]=fb_pretty_sonogram(TEMPLATE,fs,'low',2.5,'zeropad',1024,'N',2048,'overlap',2040);

	startidx=max(find(f<min_f));

	if isempty(startidx), startidx=1; end

	stopidx=min(find(f>max_f));

	imagesc(t,f(startidx:stopidx),template_image(startidx:stopidx,:));set(gca,'ydir','normal');

	xlabel('Time (in s)');
	ylabel('Fs');
	colormap(colors);
	fb_multi_fig_save(template_fig,fullfile(out_dir),'template','eps,png');

	close([template_fig]);
else
	template_features=template_data;
end

% get the template size so we can extract hits of the same size

[junk,templength]=size(template_features{1});
templength=templength-1;

% have we computed the difference between the template and the sound data?

skip=0;
response=[];
if exist(fullfile(out_dir,'cluster_data.mat'),'file')
	disp('Looks like you have computed the scores before...');

	while isempty(response)
		response=input('Would you like to (r)ecompute or (s)kip to clustering?  ','s');
		switch (lower(response))
			case 'r'
				skip=0;
			case 's'
				skip=1;
			otherwise
				response=[];
		end
	end
end

if ~skip

	mat_files={};

	mat_files=dir('*.mat');
	mat_files={mat_files(:).name};

	disp('Computing features for the sound files...');

	mat_file_features(fullfile(sound_dir,'syllable_data'),mat_files);

	disp('Comparing sound files to the template...');
	template_match(template_features,fullfile(sound_dir,'syllable_data'),fullfile(out_dir,'cluster_data.mat'),templength);

end

if extract_sounds
	property_names={'cos','derivx', 'derivy', 'amp','product','curvature'};
	save(fullfile(out_dir,'cluster_data.mat'),'property_names','-append'); 

	skip=0;
	response=[];
	if exist(fullfile(out_dir,'cluster_results.mat'),'file')
		disp('Looks like you have clustered the data before..');

		while isempty(response)
			response=input('Would you like to (r)ecluster or (s)kip?  ','s');
			switch (lower(response))
				case 'r'
					skip=0;
				case 's'
					skip=1;
				otherwise
					response=[];
			end
		end
	end


	if ~skip
		uiwait(fb_data_plotter(fullfile(out_dir,'cluster_data.mat'),fullfile(out_dir,'cluster_results.mat')));
	end


	load(fullfile(out_dir,'cluster_results.mat'),'sorted_syllable');
	load(fullfile(out_dir,'cluster_data.mat'),'filenames');

	% create a model based on the user's selection, use this for score generation

	act_templatesize=length(TEMPLATE);

	skip=0;
	response=[];
	if exist(fullfile(out_dir,'extracted_data.mat'),'file')
		disp('Looks like you have extracted the data before..');

		while isempty(response)
			response=input('Would you like to (r)eextract or (s)kip?  ','s');
			switch (lower(response))
				case 'r'
					skip=0;
				case 's'
					skip=1;
				otherwise
					response=[];
			end
		end
	end


	if ~skip

		[mic_data2 vid_times mic_data mov_data used_filenames motif]=...
			extract_hits(sorted_syllable,filenames,act_templatesize,round(fs*padding));

		% each rising edge indicates a new frame, map onto time from onset

		extract_movies(mic_data2, vid_times, mic_data,mov_data,used_filenames,out_dir,im_resize,movie_fs,fs,min_f,max_f,padding,motif)%extract_movies(out_dir,im_resize,movie_fs,mic_data,fs,min_f,max_f);

		%save(fullfile(out_dir,'extracted_data.mat'),'mic_data','sync_data','ttl_data',...
			%'rise_data','fall_data','used_filenames','-v7.3');
        	save(fullfile(out_dir,'extracted_data.mat'),'mov_data','mic_data',...
			'used_filenames','-v7.3');
	else
% 		load(fullfile(out_dir,'extracted_data.mat'),'mic_data','sync_data','ttl_data',...
% 			'rise_data','fall_data','used_filenames');
        load(fullfile(out_dir,'extracted_data.mat'),'mov_data','mic_data',...
			'used_filenames');
	end

end

end

%%%%

% function to compute the spectral features for all the pertinent wave files

function mat_file_features(DIR,MAT_FILES)

if ~exist(DIR), mkdir(DIR); end

par_save = @(FILE,features) save([FILE],'features');

parfor i=1:length(MAT_FILES)

	input_file=MAT_FILES{i};
	output_file=fullfile(DIR,[ MAT_FILES{i}(1:end-4) '_score.mat']);

	if exist(output_file,'file'), continue; end

	disp(['Computing features for ' MAT_FILES{i}]);

	% simply read in the file and score it

	data=load(input_file,'audio'); % data=load(input_file,'mic_data','fs');
    
    % load in buffer/longer audio from file 
    currentpath = cd('..');
    parentpath = pwd();
    cd(currentpath);
    try
    [y,Fs] = audioread([parentpath,'/',MAT_FILES{i}(1:end-4),'.mov']);
    catch
    currentpath = cd('../..');
    parentpath = pwd();
    cd(currentpath);
    [y,Fs] = audioread([parentpath,'/',MAT_FILES{i}(1:end-4),'.mov']);
    end
    
%     [Xa,Ya,D(i,:)]= alignsignals(y,data.audio.data); % get offset.
    
     sound_features=fb_smscore(y,data.audio.rate); %sound_features=fb_smscore(data.mic_data,data.fs);

	%sound_features=fb_smscore(data.audio.data,data.audio.rate); %sound_features=fb_smscore(data.mic_data,data.fs);
	% save for recollection

	par_save(output_file,sound_features);

end

end

%%%%

% find the Euclidean distance in each spectral feature between the template
% and the targets

function template_match(TEMPLATE,DIR,SAVEFILE,TEMPLATESIZE)

% do the template matching here...

%disp('Comparing the target sounds to the template...');

file_listing=dir(fullfile(DIR,'..','*.mat'));
file_listing={file_listing(:).name};

file_listing{:}

variableCellArray={};
raw_scores={};
peakLocation={};

parfor i=1:length(file_listing)

	disp([file_listing{i}]);
	% load the features of the sound data

	[path,file,ext]=fileparts(file_listing{i});

	input_file=fullfile(DIR,[ file '_score.mat' ]);
	target=getfield(load(input_file,'features'),'features');

	[junk,targetlength]=size(target{1});

	score_temp={};
	raw_temp={};
	temp_mat=[];
	raw_mat=[];

	% also store the non-normalized scores for comparison (for statistical analysis ensure
	% we're on a common scale)

	for j=1:length(target)
		score_temp{j}=[];

		for k=1:targetlength-TEMPLATESIZE
			score_temp{j}=[score_temp{j} sum(sum(abs(target{j}(:,k:k+TEMPLATESIZE)-TEMPLATE{j})))];
		end

		% keep the raw scores for further analysis

		raw_temp{j}=score_temp{j};

		score_temp{j}=score_temp{j}-mean(score_temp{j});
		score_temp{j}=score_temp{j}/std(score_temp{j});
		score_temp{j}(score_temp{j}>0)=0;
		score_temp{j}=abs(score_temp{j});

	end

	attributes=length(score_temp);

	product_score=score_temp{1};

	for j=2:attributes, product_score=product_score.*score_temp{j}; end

	if length(product_score)<3
		variableCellArray{i}=temp_mat;
		peakLocation{i}=[];
        raw_scores{i}=raw_mat;
		continue;
	end

	warning('off','signal:findpeaks:largeMinPeakHeight');
	[pks,locs]=findpeaks(product_score,'MINPEAKHEIGHT',.05,'MinPeakDistance',6);
	warning('on','signal:findpeaks:largeMinPeakHeight');

	if isempty(locs)
		variableCellArray{i}=temp_mat;
		peakLocation{i}=[];
		raw_scores{i}=raw_mat;
		continue;
	end

	curvature=gradient(gradient(product_score));

	for j=1:attributes, temp_mat(:,j)=log(score_temp{j}(locs)); end
	for j=1:attributes, raw_mat(:,j)=raw_temp{j}(locs); end

	temp_mat(:,attributes+1)=log(product_score(locs));
	temp_mat(:,attributes+2)=log(abs(curvature(locs)));

	peakLocation{i}=locs;
	variableCellArray{i}=temp_mat;
	raw_scores{i}=raw_mat;

end

filenames=file_listing;

empty_coords=find(cellfun(@isempty,variableCellArray));
variableCellArray(empty_coords)=[];
raw_scores(empty_coords)=[];
peakLocation(empty_coords)=[];
filenames(empty_coords)=[];

save(SAVEFILE,'variableCellArray','peakLocation','filenames','peakLocation','raw_scores');

end

%%%% small function for template selection

function TEMPLATE=select_template(DIR)

	[filename,pathname]=uigetfile({'*.mat';'*.wav'},'Pick a sound file to extract the template from',fullfile(DIR,'..'));
	load(fullfile(pathname,filename),'audio');%load(fullfile(pathname,filename),'mic_data');
	TEMPLATE=fb_spectro_navigate(audio.data);%TEMPLATE=fb_spectro_navigate(mic_data);

end

%%%% the grand finale, extract the data!

%%
function [MIC_DATA2 VID_TIMES MIC_DATA MOV_DATA USED_FILENAMES MOTIF]=...
		extract_hits(SELECTED_PEAKS,FILENAMES,TEMPLATESIZE,PADDING)
% function [RAW_DATA SYNC_DATA TTL_DATA RISE_DATA FALL_DATA USED_FILENAMES]=...
% 		extract_hits(SELECTED_PEAKS,FILENAMES,TEMPLATESIZE,PADDING)

N=1024;
NOVERLAP=1e3;
DOWNSAMPLE=5;

%EXTRACTSIZE=TEMPLATESIZE+NW;

MOV_DATA=[];

disp('Pre-allocating matrices (may take a minute)...');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);
%%
counter=0;
for i=1:length(SELECTED_PEAKS)

	fprintf(1,formatstring,round((i/length(SELECTED_PEAKS))*100));

	data=load(FILENAMES{i},'audio');%data=load(FILENAMES{i},'mic_data');

	for j=1:length(SELECTED_PEAKS{i})

		peakLoc=SELECTED_PEAKS{i}(j);

		% the startpoint needs to be adjusted using the following formula
		% peaklocation*(WINDOWLENGTH-OVERLAP)*SUBSAMPLING-WINDOWLENGTH

		startpoint=(peakLoc*(N-NOVERLAP)*DOWNSAMPLE)-N;
		endpoint=startpoint+TEMPLATESIZE+N;

		startpoint=startpoint-PADDING(1);
		endpoint=endpoint+PADDING(2); %+D(i,:)*48000

		if length(data.audio.data)>endpoint && startpoint>0%if length(data.mic_data)>endpoint && startpoint>0
			counter=counter+1; % here is where early motifs are excluded...
		end
	end
end
%%

fprintf('\n');
disp(['Found ' num2str(counter) ' trials ']);

RAW_DATA=zeros(length(startpoint:endpoint),counter,'single');
% SYNC_DATA=zeros(size(RAW_DATA),'single');
% TTL_DATA=zeros(size(RAW_DATA),'single');
% RISE_DATA=zeros(size(RAW_DATA),'single');
% FALL_DATA=zeros(size(RAW_DATA),'single');

USED_FILENAMES={};

trial=1;
motif_num = 0;

disp('Extracting data');
fprintf(1,['Progress:  ' blanks(nblanks)]);

for i=1:length(SELECTED_PEAKS)

	fprintf(1,formatstring,round((i/length(SELECTED_PEAKS))*100));

	load(FILENAMES{i},'audio','video');
    
    
     try
    currentpath = cd('..');
    parentpath = pwd();
    cd(currentpath);
    [y,Fs] = audioread([parentpath,'/',FILENAMES{i}(1:end-4),'.mov']);
    catch
    currentpath = cd('../..');
    parentpath = pwd();
    cd(currentpath);
    [y,Fs] = audioread([parentpath,'/',FILENAMES{i}(1:end-4),'.mov']);
    end
    [Xa,Ya,D]= alignsignals(y,audio.data); % get offset.
   

	counter=1;
	for j=1:length(SELECTED_PEAKS{i})

		peakLoc=SELECTED_PEAKS{i}(j);

		% the startpoint needs to be adjusted using the following formula
		% peaklocation*(WINDOWLENGTH-OVERLAP)*SUBSAMPLING-WINDOWLENGTH

		startpoint=(peakLoc*(N-NOVERLAP)*DOWNSAMPLE)-N;
		endpoint=startpoint+TEMPLATESIZE+N;

		startpoint=startpoint-PADDING(1)+D;
		endpoint=endpoint+PADDING(2)+D;
        

            
        startpoint_video=round((startpoint/48e3)*round(video.FrameRate));
        endpoint_video=round((endpoint/48e3)*round(video.FrameRate));

        nframes=length(video.frames);
        
        if length(audio.data)>endpoint && startpoint>0 ...
                && nframes>endpoint_video && startpoint_video>0
		



            idx1=startpoint/48000; %time in seconds
            idx2=endpoint/48000;

            [~,loc1]= min(abs(video.times-idx1)); %what is the closest time in frames, using time index
            [~,loc2]= min(abs(video.times-idx2));


            startT = loc1;
            endT = loc2;


            VID_TIMES{trial} = video.times(startT:endT);

            MOV_DATA{trial}=video.frames(:,:,:,startT:endT);
			MIC_DATA(:,trial)=audio.data(startpoint:endpoint); % this is just the audio data
            MIC_DATA2(:,trial)= (startpoint:endpoint); % these are the actual index values of the mic data



		 if size(USED_FILENAMES,1)>=1 & strcmp(USED_FILENAMES{end},FILENAMES{i}) == 0 & catchcase == 0;% if newfilename does not equal; the previous one, and no catchcase,
				motif_num = 1;
		 	else
				motif_num = motif_num+1;
				catchcase =0;
		 end


			USED_FILENAMES{end+1}=FILENAMES{i};

			MOTIF{trial}=motif_num;

			trial=trial+1;
			counter=counter+1;
        elseif size(USED_FILENAMES) == [0,0];
            motif_num = 1;
            catchcase = 1; % make sure this goes through..
        elseif strcmp(USED_FILENAMES{end},FILENAMES{i}) == 0 % if its the first, new case
			motif_num = 1;
            catchcase = 1; % make sure this goes through..
        else
            motif_num = motif_num+1; % if its the last (truncated)
            catchcase = 1; % make sure this goes through..
            
		
%         else
%             motif_num = motif_num+1; % if there is a motif before the start condition...
        end
    end
end

fprintf('\n');

end

function extract_movies(MIC_DATA2, VID_TIMES, MIC_DATA,MOV_DATA,USED_FILENAMES,OUT_DIR,IM_RESIZE,MOVIE_FS,FS,MIN_F,MAX_F,PADDING,MOTIF)
%function extract_movies(RISE_DATA,FALL_DATA,USED_FILENAMES,OUT_DIR,IM_RESIZE,MOVIE_FS,MIC_DATA,FS,MIN_F,MAX_F)

if exist(fullfile(OUT_DIR,'mov'),'dir')
	rmdir(fullfile(OUT_DIR,'mov'),'s');
end

if exist(fullfile(OUT_DIR,'gif'),'dir')
	rmdir(fullfile(OUT_DIR,'gif'),'s');
end

mkdir(fullfile(OUT_DIR,'mov'));
mkdir(fullfile(OUT_DIR,'gif'));

[uniq_filenames,~,uniq_idx]=unique(USED_FILENAMES);

[nblanks formatstring]=fb_progressbar(100);

disp('Saving movie and audio data');
fprintf(1,['Progress:  ' blanks(nblanks)]);

for i=1:length(USED_FILENAMES)

	fprintf(1,formatstring,round((i/length(USED_FILENAMES))*100));

	[path,file,ext]=fileparts(USED_FILENAMES{i});

	% movie filename one directory down

	%mov_filename=fullfile('..',[file '.mov']);
data2=load((file),'video');
% 	image_info=imfinfo(mov_filename);
%

% 	frame_idx=RISE_DATA(RISE_DATA(:,i)>0,i);
%
% 	frame_idx=find(RISE_DATA(:,i)>0);
% 	frame_val=RISE_DATA(frame_idx,i);
%
% 	first_frame=frame_val(1);
% 	last_frame=frame_val(end);

first_frame = 1;
last_frame = length(MOV_DATA);

mov_idx=first_frame:last_frame;

	width=data2.video.width;
	height=data2.video.height;

	if ~isempty(IM_RESIZE)
		width=width*IM_RESIZE;
		height=height*IM_RESIZE;
	end

	%mov_data=zeros(height,width,length(mov_idx));

	counter=1;
% 	for j=first_frame:last_frame
% 		imdata=MOV_DATA(j);
%
% 		if ~isempty(IM_RESIZE)
% 			imdata=imresize(imdata,IM_RESIZE);
% 		end
%
% 		mov_data(:,:,counter)=imdata;
% 		counter=counter+1;
% 	end

	file_matches=find(uniq_idx==uniq_idx(i));
	chunk=find(file_matches==i);

	save_filename=[ file '_' sprintf('%04.0f',chunk) ];

	% frame_idx is used to determine the closest point in time for the onset
	% of a given frame
	%

	mic_data(:,1)=MIC_DATA(:,i);
    mic_data(:,2)=MIC_DATA2(:,i);
    mov_data= MOV_DATA{i};
    vid_times = VID_TIMES{i};
	motif = MOTIF{i};
	fs=FS;
	movie_fs=MOVIE_FS;

	if isempty(IM_RESIZE)
		im_resize=1;
	else
		im_resize=IM_RESIZE;
	end

	% save an initial baseline estimate?

	save(fullfile(OUT_DIR,'mov',[ save_filename '.mat' ]),...
		'mov_data','mic_data','movie_fs','fs','im_resize','vid_times','motif','-v7.3');
    %save(fullfile(OUT_DIR,'mov',[ save_filename '.mat' ]),...
	%	'mov_data','mov_idx','frame_idx','mic_data','fs','movie_fs','im_resize','-v7.3');

	% save sonogram of extraction

	%[s,f,t]=fb_pretty_sonogram(double(mic_data(:,1)),fs,'low',1.5,'zeropad',1024,'N',2048,'overlap',2040);
  [b,a]=ellip(5,.2,80,[500]/(fs/2),'high');
	[s,f,t]=fb_pretty_sonogram(filtfilt(b,a,mic_data(:,1)./abs(max(mic_data(:,1)))),fs,'low',2.5,'zeropad',0);

	startidx=max(find(f<MIN_F));

	if isempty(startidx), startidx=1; end
	stopidx=min(find(f>MAX_F));

	% minpt=1;
	% maxpt=min(find(f>=10e3));
for i = 1:60;
	g = round(size(s,1)/60);
	if ~rem(i,3)*i/3;
		k = find(abs(t-PADDING(1)) < 0.0001);
		bkw = max(t)-PADDING(2);
		k2 = find(abs(t-bkw) < 0.0001);
		s((((i*g)-g)+1:i*g),k:k+3) = 100; s((((i*g)-g)+1:i*g),k2:k2+3) = 100;
	end;
end;

warning off;
	imwrite(flipdim(uint8(s(startidx:stopidx,:)),1),hot,fullfile(OUT_DIR,'gif',[save_filename '.gif']),'gif');
warning on;
	%imwrite(flipdim(uint8(s),1),hot,fullfile(OUT_DIR,'gif',[ save_filename '.gif']),'gif');

end

fprintf('\n');


end

