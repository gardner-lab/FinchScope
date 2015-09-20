



function FS_tiff(videodata)

% Convert FS to tiff- for 16 bit images

% WALIII
% 02.12.14

%videodata = double(videodata);


files = videodata(:,:,:,:);

imwrite(uint8(files(:,:,:,1)),'RGB.tif');


for i=2:size(files,4) %number of images to be read

imwrite(uint8(files(:,:,:,i)),'RGB.tif','WriteMode','append');
end


frame1(:,:) = rgb2gray(videodata(:,:,:,1));

imwrite(uint8(frame1(:,:)),'G.tif');


for i=2:size(videodata,4) %number of images to be read
frame(:,:) = rgb2gray(videodata(:,:,:,i));
imwrite(uint8(frame),'G.tif','WriteMode','append');
end


