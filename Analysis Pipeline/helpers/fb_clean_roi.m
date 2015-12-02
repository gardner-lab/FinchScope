function [ROI INCLUDE] = fb_clean_roi(ROI)
%
%
%

nrois=length(ROI.coordinates);
counter=1;

nrois=length(ROI.coordinates);
TO_DEL=[];

% find matches

nmatches=1;

roi=ROI;

idx=1:nrois;

while nmatches>0

	nmatches=0;
	nrois=length(ROI.stats);
	
	pairs=nchoosek(1:nrois,2);

	for i=1:size(pairs,1)
		
		x=pairs(i,1);
		y=pairs(i,2);

		if all(ROI.stats(x).Centroid==ROI.stats(y).Centroid)
			ROI.stats(y)=[];
			ROI.coordinates(y)=[];
			idx(y)=[];
			TO_DEL=[TO_DEL y];
			nmatches=1;
			
			break;
		end

	end
end

INCLUDE=idx;
