function [ROI STATS]=fb_image_roi(IMAGE,varargin)
%fb_select_roi selects an arbitrary number of roi's for plotting
%
%
%
%


% select file to load

nparams=length(varargin);
baseline=2; % 0 for mean, 1 for median, 2 for trimmed mean
filt_rad=12; % gauss filter radius
filt_alpha=4; % gauss filter alpha
lims=2; % contrast prctile limits
save_dir='image_roi';
label_color=[1 1 0];
scale=0;
label_fontsize=25;
roi_map='lines';

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'activity_colormap'
			activity_colormap=varargin{i+1};
		case 'save_dir'
			save_dir=varargin{i+1};
		case 'lims'
			lims=varargin{i+1};
		case 'label_color'
			label_color=varargin{i+1};
		case 'lims'
			lims=varargin{i+1};
		case 'roi_map'
			roi_map=varargin{i+1};
		case 'scale'
			scale=varargin{i+1};
	end
end

mkdir(save_dir);

% convert to uint8, faster loading for animation

[rows,columns]=size(IMAGE);

if scale
	clims=prctile(IMAGE(:),[lims 100-lims]);
	im=min(IMAGE,clims(2));
	im=max(im-dff_clims(1),0);
	im=im./(clims(2)-clims(1));
	im=uint8(im.*255);
else
	im=IMAGE;
end
clear IMAGE;

slider_fig=figure();

im_roi=image(im);
colormap('gray(255)');

hold on;
axis off;

% return a cell array with the ROI

ROI.coordinates={}; % indices for the ROI
centroid=[]; % keep the centroids for deleting

[xi,yi]=meshgrid(1:columns,1:rows); % collect all coordinates into xi and yi
exit_flag=0;
counter=1;

h_ellipse=imellipse(get(slider_fig,'currentaxes'));

xlimits=xlim();
ylimits=ylim();

xlimits(1)=xlimits(1)-10;
xlimits(2)=xlimits(2)+10;

ylimits(1)=ylimits(1)-10;
ylimits(2)=ylimits(2)+10;

fcn = makeConstrainToRectFcn('imellipse',xlimits,ylimits);
setPositionConstraintFcn(h_ellipse,fcn);

ellipses={};
pl_ellipses=[];
pl_centroids=[];
diameter=[];

counter=1;
del_flag=0;

while 1>0

	h=wait(h_ellipse);

	% convert the ROI into all pixels inside the polygon
	
	if isempty(h), break; end

	% if any element of h is outside the plotting window, enter delete mode

	if del_flag

		% loop through idx, any matches result in deleting that roi
		% is a centroid inside the ellipse?

		if length(centroid)>0	
		
			del=inpolygon(centroid(:,1),centroid(:,2),h(:,1),h(:,2));
			idx=find(del);

			% clean up

			ROI(idx)=[];
			centroid(idx,:)=[];
			ellipses(idx)=[];
			diameter(idx)=[];

			delete(pl_ellipses(idx));
			pl_ellipses(idx)=[];

		end
	end

	if any(h(:,1)>columns) | any(h(:,2)>rows) | any(h(:)<0)
	
		% placing the ellipse on the border changes delete mode

		if del_flag
			disp('Exiting delete mode');			
		else
			disp('Entering delete mode');
		end

		del_flag=~del_flag; % flip del_flag
		continue;
	end

	% don't plot anything if we're in delete mode

	if del_flag
		continue;
	end

	roi=inpolygon(xi,yi,h(:,1),h(:,2));
	[idx]=find(roi);

	% xi=columns yi=rows
	% collect the roi

	ROI.coordinates{end+1}=[ xi(idx) yi(idx) ];
	centroid(end+1,:)=[ mean(xi(idx)) mean(yi(idx)) ];

	% also store the diameter

	dist=pdist(h,'euclidean');
	diameter(end+1)=max(dist);

	set(0,'CurrentFigure',slider_fig);
	
	ellipses{end+1}=h;
	pl_ellipses(end+1)=plot(h(:,1),h(:,2),'-','linewidth',1.5,'color',[1 1 0]);

	% what's inside of the ROI?  this could also be used to normalize fluorescene per 
	% Svoboda et al. (take an annulus surrounding the ROI)

	counter=counter+1; % increment the colormap

end

save_fig=figure();

im_save=image(im);
colormap('gray(255)');
hold on;

axis off;
roi_map=eval([ roi_map '(' num2str(length(ellipses)) ')' ]);

for i=1:length(ellipses)
	h=ellipses{i};
	plot(h(:,1),h(:,2),'-','linewidth',1.5,'color',roi_map(i,:));
	text(centroid(i,1),centroid(i,2),sprintf('%i',i),...
		'color',label_color,'fontsize',label_fontsize,'fontweight','bold');
end


for i=1:length(ROI.coordinates)
	ROI.stats(i).Centroid=mean(ROI.coordinates{i});
	ROI.stats(i).Diameter=max(pdist(ROI.coordinates{i},'euclidean'));
	k=convhull(ROI.coordinates{i}(:,1),ROI.coordinates{i}(:,2));
	ROI.stats(i).ConvexHull=ROI.coordinates{i}(k,:);

end

ROI.type='image';
ROI.reference_image=im;

% draw rois onto max_proj and be done!

save(fullfile(save_dir,'roi_data_image.mat'),'ROI');
fb_multi_fig_save(save_fig,save_dir,'roi_map_image','tiff','res',100);
close([save_fig]);

end
