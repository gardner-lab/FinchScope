function fb_detrend_and_align(ROIS,varargin)
%detrends and aligns data aligned to silence
%
%
%
%
%

nparams=length(varargin);

fs=22;
per=12;
cut=25;
out_dir='extraction_silence';
save_dir='detrended_aligned';
disp_minfs=1;
disp_maxfs=9e3;
dat_dir='trace_data';
padding=[0];
fs=24.414e3;
colors='hot';
minlength=.2;

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


mkdir(dat_dir);
% get a list of .tif files

tmp=dir('*.mat');
file_list={tmp(:).name};

disp('Cleaning ROIs');

[rois,include]=fb_clean_roi(ROIS);

mkdir(fullfile(out_dir,save_dir));
mkdir(fullfile(out_dir,'gif'));

min_smps=round(minlength*fs);

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

	raw_cut=roi_traces.raw(cut:end,:);

	dff_detrended=fb_roi_detrend(raw_cut,'fs',movie_fs,'dff',1,'win',.4,'per',12);

	% now take the extraction points, align all data

	mic_data=mic_data./max(abs(mic_data));
	[song_bin,song_t]=zftftb_song_det(mic_data,fs,'song_thresh',.001,'ratio_thresh',2,...
		'pow_thresh',.07,'songduration',.7,'songpow_thresh',-inf,'silence',0,'song_band',[2e3 7e3]);

	raw_t=[1:length(mic_data)]./fs;

	% interpolate song detection to original space, collate idxs

	detection=interp1(song_t,double(song_bin),raw_t,'nearest'); 
	matches=markolab_collate_idxs(detection,round(padding(1)*fs));

	% is there a silent gap between the matches?

	if matches(1,1)~=1
		matches=[ [ 1 1 ];matches ];
	end

	if matches(end,1)~=length(detection)
		matches(end+1,:)=[length(detection) length(detection)];
	end

	ext_pts=[];


	for j=1:size(matches,1)-1

		% start at the end of the previous match

		startpt=matches(j,2);
		stoppt=matches(j+1,1);

		dist=stoppt-startpt;

		% is the extraction long enough?  if so, extract!

		if dist>min_smps
			ext_pts(end+1,:)=[ startpt stoppt ];
		end

	end

	% find frame idx closest to the match points

	cut_frame_idx=frame_idx(cut:end);

	[sonogram_im sonogram_f sonogram_t]=zftftb_pretty_sonogram(mic_data,fs,'len',16.7,'overlap',3.3,'clipping',-5);

	sonogram_im=flipdim(sonogram_im,1)*62;
	[f,t]=size(sonogram_im);
	im_son_to_vec=(length(mic_data)-(3.3/1e3)*fs)/t;


	for j=1:size(ext_pts,1)


		if (ext_pts(j,1)<cut_frame_idx(1) & ext_pts(j,2)<cut_frame_idx(1)) | (ext_pts(j,1)>cut_frame_idx(end) & ext_pts(j,2)>cut_frame_idx(end))
			continue;
		end

		if ext_pts(j,1)<cut_frame_idx(1)
			ext_pts(j,1)=cut_frame_idx(1);
		end

		if ext_pts(j,2)>cut_frame_idx(end)
			ext_pts(j,2)=cut_frame_idx(end);
		end

		sonogram_im(1:10,ceil(ext_pts(j,1)/im_son_to_vec):ceil(ext_pts(j,2)/im_son_to_vec))=62;

		disp(['Saving match ' num2str(j)]);

		% otherwise find the right index and align the data

		dist=abs(ext_pts(j,1)-cut_frame_idx);
		[~,startidx]=min(dist);

		dist=abs(ext_pts(j,2)-cut_frame_idx);
		[~,stopidx]=min(dist);

		align_detrended=dff_detrended(startidx:stopidx,:);
		align_raw=raw_cut(startidx:stopidx,:);
		align_mic_data=mic_data(ext_pts(j,1):ext_pts(j,2));
		align_frame_idx=cut_frame_idx(startidx:stopidx);

		savefile=[ file '_' sprintf('%04.0f',j) ];

		[s,f,t]=zftftb_pretty_sonogram(align_mic_data,fs,'filtering',300,'norm_amp',0,'clipping',-5);
		startidx=max([find(f<=disp_minfs)]);
		stopidx=min([find(f>=disp_maxfs)]);
		s=s(startidx:stopidx,:)*62;
		s=flipdim(s,1);
		
		imwrite(uint8(s),colormap([ colors '(63)']),fullfile(out_dir,'gif',[ savefile '.gif']),'gif');	

		save(fullfile(out_dir,save_dir,[ savefile '.mat' ]),...
			'align_detrended','align_raw','align_mic_data',...
				'fs','movie_fs','align_frame_idx','rois','ext_pts','cut','padding')

	end

	reformatted_im=markolab_im_reformat(sonogram_im,(ceil((length(mic_data)/fs)/10)));
	imwrite(uint8(reformatted_im),colormap([ colors '(63)']),fullfile(out_dir,'gif',[ file '.gif' ]),'gif');

end
