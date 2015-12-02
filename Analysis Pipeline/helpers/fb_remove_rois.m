function ROI=fb_remove_roi(ROI,DEL_ROIS)
%
%
%
%
%

% pull in data, if cell, then map to multiple ROIs


ROI.coordinates(DEL_ROIS)=[];
ROI.stats(DEL_ROIS)=[];
