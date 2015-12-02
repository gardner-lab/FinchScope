function fb_detrend_and_align(DIR,TEMPLATE,ROIS,varargin)
%
%
%
%
%
%

nparams=length(varargin);

fs=22;
per=12;
cut=25;
out_dir='extraction';
save_dir='detrended_aligned';
dat_dir='trace_data';
padding=[1 1];

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'cut'
			cut=varargin{i+1};
		case 'out_dir'
			out_dir=varargin{i+1};
		case 'dat_dir'
			dat_dir=varargin{i+1};
	end
end


if nargin<1 | isempty(DIR), DIR=pwd; end


mkdir(dat_dir);
% get a list of .tif files

tmp=dir(fullfile(DIR,'*.mat'));
file_list={tmp(:).name};

disp('Cleaning ROIs');

[rois,include]=fb_clean_roi(ROIS);

mkdir(fullfile(out_dir,save_dir));

for i=1:length(file_list)

	disp(['Processing file ' file_list{i}]);

	[path file ext]=fileparts(file_list{i});

	trace_file=fullfile(dat_dir,[ file '_roitraces.mat' ]);
	peak_file=fullfile(dat_dir,[ file '_peaks.mat' ]);
	frame_file=fullfile(dat_dir,[ file '_frameidx.mat' ]);

	% load mat file

	load([file_list{i}],'mic_data','fs');

	if ~exist(trace_file,'file')|~exist(frame_file,'file')
		[mov_data,frame_idx]=fb_retrieve_mov(file_list{i});
		movie_fs=1./((frame_idx(2)-frame_idx(1))/fs);
		save(frame_file,'frame_idx','movie_fs');
	else
		load(frame_file,'frame_idx','movie_fs');
	end

	% now with the mov_data apply rois
	% assume we've loaded in mic_data from the appropriate file

	if ~exist(trace_file,'file')
		[roi_traces]=fb_extract_roi_traces(rois,mov_data,frame_idx);
		save(trace_file,'roi_traces');
	else
		load(trace_file,'roi_traces');
	end

	% detrend and make dff traces

	raw_cut=roi_traces.raw(cut:end,:);

	dff_detrended=fb_roi_detrend(raw_cut,'fs',movie_fs,'dff',1,'win',.4,'per',12);

	%for j=1:size(raw_cut,2)
	%	figure(1);plot(smooth(dff_detrended(:,j),5));
	%	pause();
	%end

	% now take the extraction points, align all data

	matches=fb_quick_template_match(file_list{i},'template',TEMPLATE,'padding',padding);

	% fit calcium traces
	%
	% find frame idx closest to the match points

	cut_frame_idx=frame_idx(cut:end);

	% number of frames spanning the template and the left and right pads

	template_l=round(((length(TEMPLATE.data)/fs)+padding(2)+padding(1))*movie_fs)

	for j=1:size(matches,1)

		if all(matches(j,1)<cut_frame_idx) | all(matches(j,2)>cut_frame_idx)
			disp('Match out of bounds');
			continue;
		end
	
		disp(['Saving match ' num2str(j)]);

		% otherwise find the right index and align the data

		dist=abs(matches(j,1)-cut_frame_idx);
		[~,startidx]=min(dist);
	
		align_detrended=dff_detrended(startidx:startidx+template_l,:);
		align_raw=raw_cut(startidx:startidx+template_l,:);
		align_mic_data=mic_data(matches(j,1):matches(j,2));
		align_frame_idx=cut_frame_idx(startidx:startidx+template_l);

		savefile=[ file '_' sprintf('%04.0f',j) ];

		save(fullfile(out_dir,save_dir,[ savefile '.mat' ]),...
			'align_detrended','align_raw','align_mic_data',...
				'fs','movie_fs','align_frame_idx','rois','matches','cut','padding','TEMPLATE')

	end
end
