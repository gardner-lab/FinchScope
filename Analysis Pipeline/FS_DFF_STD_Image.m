function FS_DFF_STD_Image(DIR,startFrame,varargin)
% FS_DFF_STD_Image.m


%run thorough directory and make STD and MAX images for every mat file in directory
% This Script is for 'unprocessed' videos
%
%   Created: 2016/03/09
%   By: WALIII
%   Updated: 2016/03/10
%   By: WALIII

% startFrame can equal 7, for full files

% Make directory for all subsequent videos...
mat_dir='DFF_Images';
counter = 1;
if exist(mat_dir,'dir') rmdir(mat_dir,'s'); end
mkdir(mat_dir);
MaxDir = strcat(mat_dir,'/MAX')
StdDir = strcat(mat_dir,'/STD')
mkdir(MaxDir);
mkdir(StdDir);


outlier_flag=0;
if nargin<1 | isempty(DIR), DIR=pwd; end
mov_listing=dir(fullfile(DIR,'*.mat'));
mov_listing={mov_listing(:).name};
filenames=mov_listing;


disp('Creating Dff movies');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

for i=1:length(mov_listing)
clear video;

    [path,file,ext]=fileparts(filenames{i});
	fprintf(1,formatstring,round((i/length(mov_listing))*100));

	load(fullfile(DIR,mov_listing{i}),'video','mov_data');


save_filename_MAX=[ fullfile(MaxDir,file) ];
save_filename_STD=[ fullfile(StdDir,file) ];

try
   LastFrame = video.nrFramesTotal;
   mov_data = video.frames(startFrame:LastFrame); % dont take dead frames, looks like by fr
catch
  disp('no number of frames total found, defaulting until the end of the video...')
   LastFrame = size(mov_data,2);
 mov_data = mov_data(startFrame:LastFrame); % dont take dead frames, looks like by fr
end

%%%%
for i=1:(length(mov_data)-2)
   mov_data3 = single(rgb2gray(mov_data(i).cdata));
   mov_data4 = single(rgb2gray(mov_data(i+1).cdata));
   %mov_data5 = single(rgb2gray(mov_data(i+2).cdata));
   mov_data2(:,:,i) = uint8((mov_data3 + mov_data4)/2);
end

test=mov_data2;
test=imresize((test),.25);

h=fspecial('disk',50);
bground=imfilter(test,h);
% bground=smooth3(bground,[1 1 5]);
test=test-bground;
h=fspecial('disk',1);
test=imfilter(test,h);


test=imresize(test,4);

FrameInfo = max(test,[],3);


colormap(bone)
imagesc(FrameInfo);

X = mat2gray(FrameInfo);
X = im2uint8(X);
save_filename_MAX = strcat(save_filename_MAX,'_MAX','.png');
imwrite(X,save_filename_MAX,'png')

clear FrameInfo;
FrameInfo = std(double(test),[],3);
imagesc(FrameInfo);

X = mat2gray(FrameInfo);
X = im2uint8(X);

save_filename_STD = strcat(save_filename_STD,'_STD','.png');
imwrite(X,save_filename_STD,'png')

TotalX(:,:,counter) = X;


counter = counter+1; % Up the counter

% Clear all used Variables
clear mov_data;
clear LastFrame;
clear h;
clear bground;
clear X;
clear FrameInfo;
clear test;
clear LinKat;
clear Kat;
clear H;
clear L;
clear mov_data2;
clear mov_data3;
clear mov_data4;

end
fprintf(1,'\n');

%% Register Images
% [optimizer, metric] = imregconfig('multimodal');
% for g = 1:size(TotalX,3)
%     tiledImage(:,:,g) = imregister(TotalX(:,:,g), TotalX(:,:,1),'rigid',optimizer, metric);
% end


% FrameInfo2 = max(TotalX,[],3);
% imwrite(FrameInfo2,'Dff_composite','png')
