function FS_DFF_STD_Image(DIR,varargin)
% FS_DFF_STD_Image.m


%run thorough directory and make STD and MAX images for every mat file in directory
% This Script is for 'unprocessed' videos
%
%   Created: 2016/03/09
%   By: WALIII
%   Updated: 2016/03/10
%   By: WALIII

% startFrame can equal 7, for full files
startFrame = 1;
dispword = strcat('Start frame is set to ', startFrame);
disp(dispword);
% Make directory for all subsequent videos...
mat_dir='DFF_Images2';
counter = 1;
if exist(mat_dir,'dir'); rmdir(mat_dir,'s'); end
mkdir(mat_dir);
MaxDir = strcat(mat_dir,'/MAX');
StdDir = strcat(mat_dir,'/STD');
AvgDir = strcat(mat_dir,'/AVG');
mkdir(MaxDir);
mkdir(StdDir);
mkdir(AvgDir)

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

    warning('off','all')
	load(fullfile(DIR,mov_listing{i}),'video','mov_data');
    warning('on','all')

save_filename_MAX=[ fullfile(MaxDir,file) ];
save_filename_STD=[ fullfile(StdDir,file) ];
save_filename_AVG=[ fullfile(AvgDir,file) ];

try
[mov_data2, n] = FS_Format(mov_data,1);
catch
[mov_data2, n] = FS_Format(video.frames,10);
end

a = 6;
			for iii = 1: size(mov_data2,3)
                mov_data2(:,:,iii) = wiener2(mov_data2(:,:,iii),[a a]);
            end
            
test= convn(mov_data2, single(reshape([1 1 1] / 3, 1, 1, [])), 'same');


test=imresize((test),.25);

h=fspecial('disk',50);
bground=imfilter(test,h);
% bground=smooth3(bground,[1 1 5]);
test=test-bground;
h=fspecial('disk',1);
test=imfilter(test,h);


test=imresize(test,4);

FrameInfo = max(test,[],3);


colormap(gray)
image(FrameInfo);

% X = uint16((2^16)*mat2gray(FrameInfo.^2));

X = mat2gray(FrameInfo);
X = im2uint16(X);
save_filename_MAX = strcat(save_filename_MAX,'_MAX','.tif');
imwrite(X,save_filename_MAX,'tif')

%% AVG movie

clear FrameInfo; FrameInfo = mean(test,3);

colormap(gray); image(FrameInfo);

% X = uint16((2^16)*mat2gray(FrameInfo.^2));

X = mat2gray(FrameInfo);
X = im2uint16(X);
save_filename_AVG = strcat(save_filename_AVG,'_AVG','.tif');
imwrite(X,save_filename_AVG,'tif')

%%



clear FrameInfo; FrameInfo = std(double(test),[],3); image(FrameInfo);

X = uint16((2^16)*mat2gray(FrameInfo.^2)); % Square the signal of the STD image, higher contrast...

save_filename_STD = strcat(save_filename_STD,'_STD','.tif');
imwrite(X,save_filename_STD,'tif')

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
