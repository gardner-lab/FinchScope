function [ImageDataMax ImageDataSTD] = FS_GrabIMdata();

  % this will grab all the Matrix of the std image, from the aligned data ( for Jeff)


  START_DIR_ROOT = pwd;

  % Get a list of all files and folders in this folder.
  files = dir(START_DIR_ROOT)
  files(1:2) = [] % Exclude parent directories.
  dirFlags = [files.isdir]% Get a logical vector that tells which is a directory.
  subFolders = files(dirFlags)% Extract only those that are directories.


  for i = 1:length(subFolders)
        cd(START_DIR_ROOT);
        clear nextDir; clear mov_listing; clear filenames;

        try % in case there are Directories you can't enter...
          nextDir = strcat(subFolders(i).name,'/mat/extraction/mov')
          cd(nextDir);
        catch
          disp(' could not enter DIR...')
        end


      mov_listing=dir(fullfile(pwd,'*.mat')); % Get all .mat file names
      mov_listing={mov_listing(:).name};
      filenames=mov_listing;


    for ii=1:length(mov_listing) % for all .mat files in directory,
        clear mov_data; clear mov_data_aligned; clear mov_data_aligned_actual; % Make sure the buffer is clear...

          [path,file,ext]=fileparts(filenames{ii});
              load(fullfile(pwd,mov_listing{ii}),'mov_data_aligned');

mov_data = mov_data_aligned;
          % Smooth Data...

          for iv=1:(length(mov_data)-2)
             mov_data3 = single((mov_data(iv).cdata));
             mov_data4 = single((mov_data(iv+1).cdata));
             %mov_data5 = single(rgb2gray(mov_data(i+2).cdata));
             mov_data2(:,:,iv) = uint8((mov_data3 + mov_data4)/2);
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


          %image(FrameInfo);

          X = mat2gray(FrameInfo);
          X = im2uint16(X);

          % save_filename_MAX = strcat(save_filename_MAX,'_MAX','.tif');
          % imwrite(X,save_filename_MAX,'png')
          ImageDataSTD{i,ii} = X;
          
          clear FrameInfo; clear mov_data2;
          FrameInfo = std(double(test),[],3);
          % image(FrameInfo);

          % X = mat2gray(FrameInfo);
          % X = im2uint16(X);

          X = uint16((2^16)*mat2gray(FrameInfo.^2)); % Square the signal of the STD image, higher contrast...

          ImageDataMax{i,ii} = X;
          clear X;

end
end
