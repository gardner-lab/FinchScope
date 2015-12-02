function fb_clickable_map(ROI,CA_DATA,varargin)
% make current image a clickable map to address calcium traces
%
%
%
%
%


nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})	
	
	end
end

if ~isfield(ROI.stats,'ConvexHull')
	for i=1:nrois
		k=convhull(ROI.coordinates{i}(:,1),ROI.coordinates{i}(:,2));
		ROI.stats(i).ConvexHull=ROI.coordinates{i}(k,:);
	end
end

% get current figure handle, quit when it's closed

h_point=impoint(gca);

xlimits=xlim();
ylimits=ylim();

xlimits(1)=xlimits(1);
xlimits(2)=xlimits(2);

ylimits(1)=ylimits(1);
ylimits(2)=ylimits(2);

fcn = makeConstrainToRectFcn('impoint',xlimits,ylimits);
setPositionConstraintFcn(h_point,fcn);

nrois=length(ROI.coordinates);

disp('Select ROI using cross-hairs to plot');
disp('Press [RETURN] when finished to exit');
ax=gca;

while 1>0

	%[x,y,key]=ginput(1);
	
	h=wait(h_point);

	% h returns x,y check if we're in any of our ROIs

	if isempty(h), break; end
	
	x=h(1);
	y=h(2);

	for i=1:nrois
		
		in_roi=inpolygon(x,y,ROI.stats(i).ConvexHull(:,1),ROI.stats(i).ConvexHull(:,2));
		
		if in_roi
			disp(['Selected ROI ' num2str(i)]);
			figure();plot(CA_DATA(:,i));
			break;
		end

	end

end





