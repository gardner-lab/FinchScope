function FS_BatchSB(DIR, varargin)

%run thorough directory and make Background Subtracted Movies in AVI format
% This Script is for 'unprocessed' videos


% WALIII
% For unprocessed videos
% 09.05.15


mat_dir='BackgroundSubtracted_Movies';
counter = 1;

if exist(mat_dir,'dir') rmdir(mat_dir,'s'); end
mkdir(mat_dir);


outlier_flag=0;
if nargin<1 | isempty(DIR), DIR=pwd; end
mov_listing=dir(fullfile(DIR,'*.mat'));
mov_listing={mov_listing(:).name};
filenames=mov_listing;


disp('Creating BS movies');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

for i=1:length(mov_listing)
  clear video;
  clear NormIm;
  clear dff2;
  clear dff;
  clear mov_data3;
  clear mov_data2;
  clear mov_data;

      [path,file,ext]=fileparts(filenames{i});
      save_filename=[ fullfile(mat_dir,file) ];
  	fprintf(1,formatstring,round((i/length(mov_listing))*100));
  try
  load(fullfile(DIR,mov_listing{i}),'video');
  sT = 20;
  mov_data = video.frames(:,:,:,sT:end);
  catch
      load(fullfile(DIR,mov_listing{i}),'mov_data');
      sT = 1;
      mov_data = mov_data.frames(:,:,:,sT:end);
  end

  %%%%
  % Detect Bad frames
  counter = 1;
  TERM_LOOP = 0;
  for i=sT:(size(mov_data,4))
     mov_data2(:,:,counter) = single(rgb2gray(mov_data(:,:,:,counter)));
        counter = counter+1;

  end

  mov_data3 = convn(mov_data2, single(reshape([1 1 1] / 3, 1, 1, [])), 'same');



    %create DFF
    figure, set(gcf, 'Color','white')
      axis tight
      set(gca, 'nextplot','replacechildren', 'Visible','off');

%# create AVI object

save_filename=[ fullfile(mat_dir,file) ];

vidObj = VideoWriter(save_filename);
vidObj.Quality = 100;
vidObj.FrameRate = 30;
open(vidObj);
colormap(bone);


test=mov_data3;
test=imresize((test),.25);

h=fspecial('disk',60);
bground=imfilter(test,h);
% bground=smooth3(bground,[1 1 5]);
test=(test-bground)./bground;
h=fspecial('disk',1);
test=imfilter(test,h);

%%%%%
% Scale videos by pixel value intensities of a single, representative frame
% LinKat =  cat(1,test(:,1,20)); % take this from the 15 frame
% for i = 2:size(test,2)
% Lin = cat(1,test(:,i,size(test,3)));
% LinKat = cat(1,LinKat,Lin);
% end
H = prctile(mean(max(test(:,:,:))),70);
L = prctile(min(mean(test(:,:,:))),40);
%%%%%
test=imresize(test,4);

[optimizer, metric] = imregconfig('multimodal');
%# create movie
for i=1:(size(mov_data3,3));
    %test3(:,:,i) = imregister(test2(:,:,i),test2(:,:,1),'rigid',optimizer,metric);
   image(test(:,:,i),'CDataMapping','scaled');
   caxis([double(L),double(H)])%caxis([0,70]) % change caxis
   writeVideo(vidObj, getframe(gca));
end
close(gcf)

%# save as AVI file, and open it using system video player
close(vidObj);

FrameInfo = max(test,[],3);
%figure();
colormap(bone)
imagesc(FrameInfo);
%set(gca,'ydir','normal'); % Otherwise the y-axis would be flipped
X = mat2gray(FrameInfo);
X = im2uint8(X);
imwrite(X,save_filename,'png')

TotalX(:,:,counter) = X;


counter = counter+1;
clear mov_data;
clear h;
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

end
fprintf(1,'\n');
%%
%% Register Images
% [optimizer, metric] = imregconfig('multimodal');
% for g = 1:size(TotalX,3)
%     tiledImage(:,:,g) = imregister(TotalX(:,:,g), TotalX(:,:,1),'rigid',optimizer, metric);
% end



FrameInfo2 = max(TotalX,[],3);
imwrite(FrameInfo2,'Dff_composite','png')

%% Save Data from aggregate
% Test = TotalX2;
%mov_data = video.frames;
%im_resize = 1;

%save(save_filename,'Test','mov_data','im_resize','-v7.3')
