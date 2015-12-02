function ROI=fb_convert_imagej_roi(FILENAME,varargin)
%
%
%
%
%

% wrapper for ReadImageJROI

% pull in data, if cell, then map to multiple ROIs

rois=ReadImageJROI(FILENAME);
ROI.coordinates={};

if iscell(rois)

	for i=1:length(rois)
		% return in x,y pair format (all coordinates inside ROI)

		tmp=rois{i}.vnRectBounds; % top, left, bottom, right
		[y x]=meshgrid(tmp(1):tmp(3),tmp(2):tmp(4));
		ROI.coordinates{i}=[x(:) y(:)];
		
	end
else

	tmp=rois.vnRectBounds; % top, left, bottom, right
	[y x]=meshgrid(tmp(1):tmp(3),tmp(2):tmp(4));
	ROI.coordinates{1}=[x(:) y(:)];

end

for i=1:length(ROI.coordinates)
	ROI.stats(i).Centroid=mean(ROI.coordinates{i});
	ROI.stats(i).Diameter=max(pdist(ROI.coordinates{i},'euclidean'));
	k=convhull(ROI.coordinates{i}(:,1),ROI.coordinates{i}(:,2));
	ROI.stats(i).ConvexHull=ROI.coordinates{i}(k,:);
end

ROI.type='imagej';

end




