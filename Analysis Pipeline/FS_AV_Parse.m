
function FS_AV_Parse2(DIR,day,varargin)

%========================================%
%                FS_AVparse              %
%                 08.02.15               %
%                  WALIII                %
%========================================%


% day indicates what day in the LS this has occured

% FS_AVparse will do several things:

%   1. Seperate Audio and Video, and place them into .mat files in a .mat
%      directory
%   2. Make spectrogram .gif files for extracted audio, for perusing
%      manually.
%   3. Uses the dependancy extractmedia(), an amazing script created by Nathan Perkins

% Run in the Directory of the .mov files. FS_AVparse should be run first of 
% the analysis sequence. ** This requires mmreader to function!

% FS_AVparse-->FS_SongDetect-->FS_DetrendAlign-->FS_ROIselect-->FS_ROIplot


mat_dir='mat';
gif_dir='gif';


if exist(mat_dir,'dir') rmdir(mat_dir,'s'); end
if exist(gif_dir,'dir') rmdir(gif_dir,'s'); end

mkdir(mat_dir);
mkdir(gif_dir);




outlier_flag=0;
if nargin<1 | isempty(DIR), DIR=pwd; end

mov_listing=dir(fullfile(DIR,'*.mov'));
mov_listing={mov_listing(:).name};



filenames=mov_listing;


disp('Parsing Audio and Video files');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

for i=1:length(mov_listing)

    [path,file,ext]=fileparts(filenames{i});

    
	fprintf(1,formatstring,round((i/length(mov_listing))*100));
    FILE = fullfile(DIR,mov_listing{i})
    %[video, audio] = mmread(FILE)
    
    %Extract Audio and video data...
[a_ts, a, v_ts, v] = extractmedia(FILE);




% Format VIDEO DATA
[video.width, video.height, video.channels] = size(v{1});
video.times = v_ts+0.1703*(day-1);

video.nrFramesTotal = size(v,2);
video.FrameRate = 1/mean(diff(v_ts));
for ii = 1: size(v,2)
    video.frames(ii).cdata(:,:,:) = v{ii};
    video.frames(ii).colormap = [];
end
% Format AUDIO DATA
audio.nrChannels = 1;
audio.bits = 16;
audio.nrFrames = length(a);
audio.data = a;
audio.rate = 48000;
audio.TotalDurration = audio.nrFrames/48000;
mic_data = a;
fs = 48000;


		[b,a]=ellip(5,.2,80,[500]/(fs/2),'high');
		plot_data=mic_data./abs(max(mic_data));

		[s,f,t]=fb_pretty_sonogram(filtfilt(b,a,mic_data./abs(max(mic_data))),fs,'low',1.5,'zeropad',0);

		minpt=1;
		maxpt=min(find(f>=10e3));

		imwrite(flipdim(uint8(s(minpt:maxpt,:)),1),hot,fullfile(gif_dir,[file '.gif']),'gif');
		save(fullfile(mat_dir,[file '.mat']),'audio','video','-v7.3');



end
fprintf(1,'\n');
%%
