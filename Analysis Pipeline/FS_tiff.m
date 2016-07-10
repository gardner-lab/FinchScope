
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

[files, n] = FS_Format(videodata,1);

for i = 1: size(files,3)
    files2(:,:,i) = wiener2(files(:,:,i),[3 3]);
end


% files3 = convn(files2, single(reshape([1 1 1] / 3, 1, 1, [])), 'same');



imwrite(uint8(files2(:,:,1)),'G.tif');


for i=2:size(files2,3) %number of images to be read
    
    K = files2(:,:,i);
    %K = wiener2(files2(:,:,i),[5 5]);
    %G  = filter2(fspecial('average',3),files2(:,:,i));
    %GG = medfilt2(G);

imwrite(uint8(K),'G.tif','WriteMode','append');
end

end
