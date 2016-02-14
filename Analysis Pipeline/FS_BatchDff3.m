function FS_BatchDff3(DIR, varargin)
  % FS_BatchDff3 

  % Run through Template matched files in a directory and make Dif 
  % videos (Spatially downsampled, in AVI format) as well as MAX projections of
  % These AVI videos.

  %   Created: 2016/02/12
  %   By: WALIII
  %   Updated: 2016/02/15
  %   By: WALIII

  % FS_BatchDff_TM will do several things:
  %
  %   1.  Create AVI file, abckgorund subtracted AVIs
  %   2.  Make MAX projections of these AVIs
  %   3.  Run in the Directory of the all .mat files
  %


mat_dir='DFF_MOVIES';
counter = 1;

if exist(mat_dir,'dir') rmdir(mat_dir,'s'); end
mkdir(mat_dir);


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

	load(fullfile(DIR,mov_listing{i}),'video');

    %create DFF
    figure, set(gcf, 'Color','white')
      axis tight
      set(gca, 'nextplot','replacechildren', 'Visible','off');

%# create AVI object

save_filename=[ fullfile(mat_dir,file) ];

vidObj = VideoWriter(save_filename);
vidObj.Quality = 40;
vidObj.FrameRate = 30;
open(vidObj);
colormap(bone);

try
   LastFrame = video.nrFramesTotal;
catch
        LastFrame = size(video.frames,2);
    end
        
mov_data = video.frames(1:LastFrame);
%%%%
try
for iii=1:(length(mov_data)-2)
   mov_data3 = single(rgb2gray(mov_data(iii).cdata));
   mov_data4 = single(rgb2gray(mov_data(iii+1).cdata));
   %mov_data5 = single(rgb2gray(mov_data(i+2).cdata));
   mov_data2(:,:,iii) = uint16((mov_data3 + mov_data4)/2);
end
catch
    % Non- FreedomScope Image
   disp('non-FS image detected. Processing anyway..')
 for iii=1:(length(mov_data)-2)
   mov_data3 = single((mov_data(iii).cdata));
   mov_data4 = single((mov_data(iii+1).cdata));
   %mov_data5 = single(rgb2gray(mov_data(i+2).cdata));
   mov_data2(:,:,iii) = ((mov_data3 + mov_data4)/2);
end   
end

%test=(mov_data2/2^16);
test=(mov_data2);




Y = diff(test,1,3);
test = Y;
test=imresize((test),.5);
h=fspecial('disk',3);
test=imfilter(test,h);

%# Filter out large fluctuations...
% h=fspecial('disk',30);
% bground=imfilter(test,h);
% % % bground=smooth3(bground,[1 1 5]);
% test=test-bground;


%%%%%
% Scale videos by pixel value intensities of a single, representative frame
LinKat =  cat(1,test(:,1,15)); % take this from the 15 frame
for i = 2:size(test,1)
Lin = cat(1,test(:,i,size(test,3)));
LinKat = cat(1,LinKat,Lin);
end



H = (prctile(LinKat,99))+200; % clip pixel value equal to the 95th percentile value
L = (prctile(LinKat,30));% clip the pixel value equal to the bottem 20th percentile value
%%%%%
test=imresize(test,2);

[optimizer, metric] = imregconfig('multimodal');

%# create movie
for ii=10:(size(test,3)-10);
    %test3(:,:,i) = imregister(test2(:,:,i),test2(:,:,1),'rigid',optimizer,metric);
 

    image('CData',test(:,:,ii),'CDataMapping','scaled');
   caxis([double(L),double(H)])%caxis([0,70]) % change caxis

set(gca,'LooseInset',get(gca,'TightInset'))

   writeVideo(vidObj, getframe(gca));
end
close(gcf)

%# save as AVI file, and open it using system video player
close(vidObj);

FrameInfo = max(test(:,:,4:size(test,3)),[],3);
FrameInfo2 = std(double(test(:,:,10:size(test,3))),[],3);
colormap(bone)
imagesc(FrameInfo);
%set(gca,'ydir','normal'); % Otherwise the y-axis would be flipped
X = mat2gray(FrameInfo);
X = im2uint16(X);
imwrite(X,save_filename,'png')

% TotalX(:,:,counter) = X;


counter = counter+1;
clear mov_data;
clear X;
clear FrameInfo;
clear test;
clear LinKat;
clear Kat;
clear H;
clear L;
clear mov_data2
clear mov_data3
clear mov_data4
clear test
clear iii;
end
fprintf(1,'\n');
%%
%% Register Images
% [optimizer, metric] = imregconfig('multimodal');
% for g = 1:size(TotalX,3)
%     tiledImage(:,:,g) = imregister(TotalX(:,:,g), TotalX(:,:,1),'rigid',optimizer, metric);
% end



%FrameInfo2 = max(TotalX,[],3);
%imwrite(FrameInfo2,'Dff_composite','png')

%% Save Data from aggregate
% Test = TotalX2;
%mov_data = video.frames;
%im_resize = 1;

%save(save_filename,'Test','mov_data','im_resize','-v7.3')
