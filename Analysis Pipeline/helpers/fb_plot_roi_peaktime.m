function roi_ave=fb_plot_roi_peaktime(ROI_MU,ROI_TIME,ROI_STATS,MOV_DATA,varargin)
%fb_select_roi selects an arbitrary number of roi's for plotting
%
%
%
%
%

roi_colors='jet';
filt_alpha=5;
filt_rad=15;
lims=.05;

nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})	
		case 'roi_colors'
			colors=varargin{i+1};
		case 'filt_alpha'
			filt_alpha=varargin{i+1};
		case 'filt_rad'
			filt_rad=varargin{i+1};
		case 'lims'
			lims=varargin{i+1};
		case 'roi_select'
			roi_select=varargin{i+1};
	end
end

samples=length(ROI_TIME);
cmap=colormap([ roi_colors '(' num2str(samples) ')']);

h1=fspecial('gauss',filt_rad,filt_alpha);

disp('Gaussian filtering fluorescence data...');

MOV_DATA=imfilter(MOV_DATA,h1,'circular');
max_proj=max(MOV_DATA,[],3);

clims(1)=prctile(max_proj(:),lims);
clims(2)=prctile(max_proj(:),100-lims);

max_proj=min(max_proj,clims(2)); % clip to max
max_proj=max(max_proj-clims(1),0); % clip min
max_proj=max_proj./(clims(2)-clims(1)); % normalize to [0,1]

max_cmap=colormap('gray');

figure();
image(max_proj.*size(max_cmap,1));hold on;
colormap(max_cmap);

for i=1:length(ROI_STATS)

	% get the convex hull for the ROI, then create a patch

	[val loc]=findpeaks(ROI_MU(i,:),'minpeakheight',1);

	% take the first peak

	peaktime=ROI_TIME(loc(1))

	vtx=ROI_STATS(i).ConvexHull
	patch(vtx(:,1),vtx(:,2),1,'facecolor',cmap(loc(1),:),'edgecolor','none');

end

% cycle through ROIs and plot using a time color-code
