function [out_mov, n] = FS_Format(in_mov,startT)
% Function used to eliminate redundancy in formats across data
% WAL3
% d07.08.2016

n = size(size(in_mov),2);
counter = 1;

  switch n
      case 2 % OLD FreedomScope format.
        try
          for ii = startT:size(in_mov)
            out_mov(:,:,counter) = squeeze(mov_data(ii).cdata(:,:,2,:));
            counter = counter+1;
          end
      disp('WARNING: old FS format detected!')
        catch
            try % If converted from RGB
          for ii = startT:size(in_mov,2)
            out_mov(:,:,counter) = (in_mov(ii).cdata(:,:,:));
            counter = counter+1;
          end
      disp('WARNING: non-FS format detected!')
            catch %.. if needs RGB conversion
          for ii = startT:size(in_mov,2)
            out_mov(:,:,counter) = squeeze(mov_data(ii).cdata(:,:,2,:));
            counter = counter+1;
          end
      disp('WARNING: non-FS format detected!')
            end
        end

  case 3 % Regular, typical format.
          out_mov = in_mov;

  case 4 % RGB format: convert to greyscale
          for ii = startT:size(in_mov,4)
            out_mov(:,:,counter) = squeeze(mov_data(ii).cdata(:,:,2,ii));
            counter = counter+1;
          end

      otherwise
          disp('WARNING: Corrupted data afoot!')
  end
