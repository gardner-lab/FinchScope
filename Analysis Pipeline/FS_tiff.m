
function FS_tiff(videodata)
  % FS_tiff

  %   Create multipage Tiff stack from the .mov files form the FreedomScope

  %   Created: 2016/02/12
  %   By: WALIII
  %   Updated: 2016/02/15
  %   By: WALIII

  % FS_BatchDff_TM will do several things:
  %
  %   1. Create a grayscale mtif, called 'G.tif'
  %   2. Creates a RGB mtif, called 'RGB.tif'
  %   
  %


files2 = videodata(:,:,:,:);

imwrite(uint8(rgb2gray(files2(:,:,:,1))),'G.tif');


for i=2:size(files2,4) %number of images to be read

imwrite(uint8(rgb2gray(files2(:,:,:,i))),'G.tif','WriteMode','append');
imwrite(uint8(files2(:,:,:,i)),'RGB.tif','WriteMode','append');
end

end
