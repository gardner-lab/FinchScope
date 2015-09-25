
function FS_AVparse(DIR,varargin)

%========================================%
%                FS_AVparse              %
%                 07.18.15               %
%                  WALIII                %
%========================================%


% FS_AVparse will do several things:

%   1. Seperate Audio and Video, and place them into .mat files in a .mat
%      directory
%   2. Make spectrogram .gif files for extracted audio, for perusing
%      manually.

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


disp('Parsing Ausio and Video files');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

for i=1:length(mov_listing)

    [path,file,ext]=fileparts(filenames{i});

    
	fprintf(1,formatstring,round((i/length(mov_listing))*100));
    FILE = fullfile(DIR,mov_listing{i})
    [video, audio] = mmread(FILE)


mic_data = audio.data;
fs = audio.rate;

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
