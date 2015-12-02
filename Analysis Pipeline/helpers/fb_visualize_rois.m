function fig_num=fb_visualize_rois(ROI,varargin)
%
%
%
%
%
%



nparams=length(varargin);

roi_map=[1 0 1];
bg_map='gray';

label_fontsize=9;
label_color=[1 1 0];
clims=[0 1];
label=0;
fig_num=[];
filled=0;
weights=[];
weights_map='winter';
weights_range=[ -inf inf ];
ref_image=[];
ncolors=[];
weights_correction=0;
weights_scale=[];
tags_id=[];
tags_label=[];

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})	
		case 'roi_map'
			roi_map=varargin{i+1};
		case 'label_fontsize'
			label_fontsize=varargin{i+1};
		case 'label_color'
			label_color=varargin{i+1};
		case 'label'
			label=varargin{i+1};
		case 'resize'
			resize=varargin{i+1};
		case 'clims'
			clims=varargin{i+1};
		case 'scale_bar'
			scale_bar=varargin{i+1};
		case 'fig_num'
			fig_num=varargin{i+1};
		case 'filled'
			filled=varargin{i+1};
		case 'weights'
			weights=varargin{i+1};
		case 'weights_map'
			weights_map=varargin{i+1};
		case 'weights_range'
			weights_range=varargin{i+1};
		case 'weights_correction'
			weights_correction=varargin{i+1};
		case 'weights_scale'
			weights_scale=varargin{i+1};
		case 'tags_id'
			tags_id=varargin{i+1};
		case 'tags_labels'
			tags_labels=varargin{i+1};
		case 'tags_colors'
			tags_colors=varargin{i+1};
		case 'ref_image'
			ref_image=varargin{i+1};
		case 'ncolors'
			ncolors=varargin{i+1};
			
	end
end


nrois=length(ROI.coordinates);

if isempty(fig_num)
	fig_num=figure();
end

if ~isempty(ref_image)
	imagesc(ROI.reference_image);
	colormap(gray);
	freezeColors();
	axis off;
	hold on;
end

% scale bar?

% scale weights, 64 colors

if ~iscell(weights)
	nweights=length(weights);
else
	nweights=sum(cellfun(@length,weights));
end

if ~isempty(weights)
	if ~isempty(ncolors)
		weights_map=eval([ weights_map '(' num2str(ncolors) ')' ]);
	else
		weights_map=eval([ weights_map '(' num2str(nweights) ')' ]);
		ncolors=nweights;
	end

end

% map weights to colors

if ~iscell(weights)

	if length(weights_scale)<1
		weights_min=min(weights);
		weights_max=max(weights);
	else
		weights_min=weights_scale(1);
		weights_max=weights_scale(2);
	end

	weights=(weights-min(weights))./(max(weights)-min(weights));
	weights=ceil(weights.*(ncolors-1)+1);
else

	for i=1:length(weights)
		weights{i}(weights{i}<weights_range(1)|weights{i}>weights_range(2))=[];
	end

	tmp=cat(2,weights{:});

	if length(weights_scale)<1
		weights_min=min(tmp);
		weights_max=max(tmp);
	else
		weights_min=weights_scale(1);
		weights_max=weights_scale(2);
	end

	for i=1:length(weights)
		weights{i}=(weights{i}-weights_min)./(weights_max-weights_min);
		weights{i}=ceil(weights{i}.*(ncolors-1)+1);
	end
end


if ~isfield(ROI.stats,'ConvexHull')
	for i=1:nrois
		k=convhull(ROI.coordinates{i}(:,1),ROI.coordinates{i}(:,2));
		ROI.stats(i).ConvexHull=ROI.coordinates{i}(k,:);
	end
end

if ~isempty(tags_id) & isempty(tags_label)

	for i=1:length(tags_id)
		tags_label{i}=[ num2str(i) ];
	end

end

counter=1;	

for i=1:nrois

	tmp=ROI.stats(i).ConvexHull;
	tmp_c=ROI.stats(i).Centroid;
	npoints=size(tmp,1);

	if filled
		if ~iscell(weights)
			if ~isempty(weights)
				fill(tmp(:,1),tmp(:,2),weights_map(weights(i),:))
			else
				if any(isnan(roi_map(i,:)))
					plot(tmp(:,1),tmp(:,2),'-','color',[1 0 1],'linewidth',1);
				else
					fill(tmp(:,1),tmp(:,2),roi_map(i,:),'edgecolor','none')
				end	
			end
		else
			if ~isempty(weights{i})

				split=length(weights{i});
				split_points=floor(npoints/split);
				split_segments=floor(linspace(1,npoints,split+1));

				for j=2:split+1
					slice=split_segments(j-1):split_segments(j);
					fill([tmp_c(1);tmp(slice,1)],[tmp_c(2);tmp(slice,2)],...
						weights_map(weights{i}(j-1),:),'edgecolor','none');
				end
            else
             	plot(tmp(:,1),tmp(:,2),'-','linewidth',1,'color',roi_map(1,:));
			end
		end

	else	
	
		plot(tmp(:,1),tmp(:,2),'-','linewidth',1,'color',roi_map(i,:));
	
	end

	hold on;

	if ~isempty(tags_id)

		idx=find(tags_id==i);
		
		if ~isempty(idx)
			
			x=mean(ROI.coordinates{i}(:,1));
			y=mean(ROI.coordinates{i}(:,2));

			text(x+5,y+5,tags_label{idx},...
				'color',label_color,'fontsize',label_fontsize);
			
		end
	end
	
	if counter<size(roi_map,1)
		counter=counter+1;
	else
		counter=1;
	end
end

%freezeColors();
%
%subplot(9,1,9);
%pts=linspace(0,1,ncolors);
%imagesc(pts);
%set(gca,'XTick',linspace(1,ncolors,4),'XTickLabels',[round([linspace(weights_min,weights_max,4)]*10)/10]+weights_correction,'ytick',[],...
%	'linewidth',1.5,'TickLength',[.02 .02]);
%colormap(weights_map)

if isempty(ref_image)
	xlim([0 size(ROI.reference_image,2)]);
	ylim([0 size(ROI.reference_image,1)]);
	set(gca,'ydir','rev');
end
