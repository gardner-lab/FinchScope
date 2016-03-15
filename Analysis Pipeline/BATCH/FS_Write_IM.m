function FS_Write_IM(MaxDir,StdDir,file,mov_data)



  save_filename_MAX= strcat('MAX/',file);
  save_filename_STD= strcat('STD/',file);


  %%%%
  for i=1:(length(mov_data)-2)
     mov_data3 = single((mov_data(i).cdata));
     mov_data4 = single((mov_data(i+1).cdata));
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




  % % Clear all used Variables
  % clear mov_data;
  % clear LastFrame;
  % clear h;
  % clear bground;
  % clear X;
  % clear FrameInfo;
  % clear test;
  % clear LinKat;
  % clear Kat;
  % clear H;
  % clear L;
  % clear mov_data2;
  % clear mov_data3;
  % clear mov_data4;
