



function FS_tiff(framerate,videodata)

% Convert FS to tiff- for 16 bit images

% WALIII
% 02.12.14

%videodata = double(videodata);


% files = videodata(:,:,2,:);
% 
% imwrite(uint16(files(:,:,:,1)),'R.tif');
% 
% 
% for i=2:size(files,4) %number of images to be read
% 
% imwrite(uint16(files(:,:,:,i)),'R.tif','WriteMode','append');
% end


files2 = videodata(:,:,1,:);

imwrite(uint16(files2(:,:,:,1)),'G.tif');


for i=2:size(files2,4) %number of images to be read

imwrite(uint16(files2(:,:,:,i)),'G.tif','WriteMode','append');
end


