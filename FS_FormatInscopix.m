function FS_FormatInscopix
  % FS_FormatInscopix

  % Parse Data from old data formats into FreedomScope forma
  %   Created: 2017/08/09
  %   By: WALIII
  %   Updated: 2017/08/09
  %   By: WALIII

  % FS_AV_parse will do several things:
  %
  %   1. Seperate Audio and Video, and place them into .mat files in a .mat
  %      directory
  %   2. Make spectrogram .gif files for extracted audio, for perusing
  %      manually.
  %   3. Uses the dependancy extractmedia(), an amazing script created by Nathan Perkins

  % Run in the Directory of the .mov files. FS_AVparse should be run first:
  % FS_AVparse-->FS_TemplateMatch-->FS_FS_Plot_ROI--> BatchDff2----> FS_Image_ROI--> FS_FS_Plot_ROI


  mat_dir=[pwd,'/mat'];
  gif_dir=[pwd,'/gif'];
  error_dir =[pwd,'/error'];

  if exist(mat_dir,'dir') rmdir(mat_dir,'s'); end
  if exist(gif_dir,'dir') rmdir(gif_dir,'s'); end
  % if exist(error_dir,'dir') rmdir(error_dir,'s'); end

  mkdir(mat_dir);
  mkdir(gif_dir);
  mkdir(error_dir);

  outlier_flag=0;
  if nargin<1 | isempty(DIR), DIR=pwd; end

  mov_listing=dir(fullfile(DIR,'*.mat'));
  mov_listing={mov_listing(:).name};
  filenames=mov_listing;


  disp('Parsing Audio and Video files');

  [nblanks formatstring]=fb_progressbar(100);
  fprintf(1,['Progress:  ' blanks(nblanks)]);


for i=1:length(mov_listing)

      [path,file,ext]=fileparts(filenames{i});
  	fprintf(1,formatstring,round((i/length(mov_listing))*100));
      FILE = fullfile(DIR,mov_listing{i})

load(FILE,'fs','mic_data')
      % Format AUDIO DATA
      audio.nrChannels = 1;
      audio.bits = 16;
      mic_data = resample(mic_data,48000,24414);
      audio.nrFrames = length(mic_data);
      audio.data = double(mic_data)';% transposed to fit rhe current format.
      audio.rate = 48000; % after upsampling


% Load from the tif in the upstream directory

cd('..');

fname = fullfile(pwd,[mov_listing{i}(1:end-3),'tif'])
info = imfinfo(fname);
num_images = numel(info);
for k = 1:num_images
    temp = imread(fname, k, 'Info', info);
    temp = imresize(temp,4/9);
    %temp = uint8(temp ./ 256);
    video.frames(:,:,k) = temp;
    clear temp;
end

      video.nrFramesTotal = size(video.frames,3);
      video.times = ((1:size(video.frames,3))/22)'; % inscopix video frame rate is 22fps
cd(DIR);


save(fullfile(mat_dir,[file '.mat']),'audio','video','-v7.3');
clear video;
clear audio;
end
