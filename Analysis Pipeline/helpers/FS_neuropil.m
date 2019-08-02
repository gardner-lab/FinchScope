function [Bgnd, Npil] = FS_neuropil(out_mov,ROI,resize)
% Extract Neuropil

% d09/24/17
% WAL3


% Make indexes for the ROI coordinates
  for i = 1:size(ROI.coordinates,2);
  if i == 1;
    X2 = [round(ROI.coordinates{i}(:,2)*resize),round(ROI.coordinates{i}(:,1)*resize)];
    else
    X = [round(ROI.coordinates{i}(:,2)*resize),round(ROI.coordinates{i}(:,1)*resize)];
    X2 = cat(1,X2,X);
  end
  end

  % Diagnostics
 % XA = ROI.reference_image;
%   XA = mean(out_mov,3);
%
%   XA(sub2ind( size(XA), X2(:,1), X2(:,2))) = NaN;
%   figure();
%   imagesc(XA);


for ii = 1:size(out_mov,3)
    temp = out_mov(:,:,ii);
Bgnd(:,ii) = mean(mean(temp));
temp(sub2ind( size(temp), X2(:,1), X2(:,2))) = NaN;
Npil(:,ii) = nanmean(nanmean(temp));
clear temp;
end

clear out_mov;
clear video;

end
