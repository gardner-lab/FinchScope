function fb_plot_allpxs(MOV_DATA,MIC_DATA,FRAME_IDX,varargin)
%fb_plot_allpxs uses the center of mass (df/f here) (COM) across time to define
% a color, and the opacity is dictated by the max df/f
%
%	fb_plot_allpxs(MOV_DATA,MIC_DATA,FRAME_IDX,varargin)
%
%	MOV_DATA
%
%	MIC_DATA
%
%	FRAME_IDX
%
%	the following may be passed as parameter/value pairs:
%
%		filt_rad
%
%		filt_alpha
%		
%		lims
%
%
%



nparams=length(varargin);

filt_rad=60; % gauss filter radius
filt_alpha=20; % gauss filter alpha
lims=5; % contrast prctile limits (i.e. clipping limits lims 1-lims)
cmap=colormap('jet');
per=0; % baseline percentile (0 for min)
fs=24.414e3;
bgcolor=[ .75 .75 .75 ]; % rgb values for axis background
time_select=0;
sono_cmap=colormap('hot');

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})	
		case 'baseline'
			baseline=varargin{i+1};
		case 'filt_rad'
			filt_rad=varargin{i+1};
		case 'trim_per'
			trim_per=varargin{i+1};
		case 'filt_alpha'
			filt_alpha=varargin{i+1};
		case 'per'
			per=varargin{i+1};
		case 'lims'
			lims=varargin{i+1};
		case 'fs'
			fs=varargin{i+1};
		case 'cmap'
			cmap=varargin{i+1};
		case 'bgcolor'
			bgcolor=varargin{i+1};
		case 'time_select'
			time_select=varargin{i+1};
		case 'sono_cmap'
			sono_cmap=varargin{i+1};
	end
end


% convert frames to times

frame_idx=FRAME_IDX./fs;
[b,a]=ellip(5,.2,80,[500]/(fs/2),'high');

figure();

if time_select
	[ext_sound,ext_image,ext_idxs]=fb_spectro_navigate(MIC_DATA);

	ext_idxs_t=ext_idxs./fs; % convert extraction points to times 
	frame_chop=zeros(1,2);

	sono_mark=zeros(1,2);

	[s,f,t]=fb_pretty_sonogram(filtfilt(b,a,double(MIC_DATA)),fs,'n',2048,'overlap',2040,'nfft',[],'low',1,'zeropad',0);
	
	for i=1:2
		[val,loc]=min(abs(frame_idx-ext_idxs_t(i)));
		frame_chop(i)=loc;

		[val,loc]=min(abs(t-ext_idxs_t(i)));
		sono_mark(i)=t(loc);

	end


	subplot(7,1,1:3);
	imagesc(t,f,s);axis xy;ylim([0 9e3]);hold on;
	plot([sono_mark ;sono_mark ],[0 0 ;9e3 9e3],'k--','color','w','linewidth',2);
	set(gca,'TickDir','out');box off;

	colormap(sono_cmap);freezeColors();

	FULL_MIC=MIC_DATA;
	MIC_DATA=MIC_DATA(ext_idxs(1):ext_idxs(2));
	MOV_DATA=MOV_DATA(:,:,frame_chop(1):frame_chop(2));
	FRAME_IDX=FRAME_IDX(frame_chop(1):frame_chop(2));

end

[rows,columns,frames]=size(MOV_DATA);

disp('Gaussian filtering the movie data...');

h=fspecial('gaussian',filt_rad,filt_alpha);
MOV_DATA=imfilter(MOV_DATA,h,'circular');

disp(['Converting to df/f using the ' num2str(per) ' percentile for the baseline...']);

baseline=repmat(prctile(MOV_DATA,per,3),[1 1 frames]);
dff=((MOV_DATA-baseline)./baseline).*100;

% take the center of mass across dim 3 (time) for each point in space

disp('Computing the center of mass...');

com_idx=zeros(1,1,frames);

for i=1:frames
	com_idx(:,:,i)=i;
end

com_idx=repmat(com_idx,[rows columns 1]);

mass=sum(dff,3);
com_dff=sum((dff.*com_idx),3)./mass;

max_proj=max(dff,[],3);

disp('Creating images...');

clims(1)=prctile(max_proj(:),lims);
clims(2)=prctile(max_proj(:),100-lims);

norm_max_proj=min(max_proj,clims(2));
norm_max_proj=max(norm_max_proj-clims(1),0);
norm_max_proj=norm_max_proj./(clims(2)-clims(1));

% map to [0,1] for ind2rgb

clims(1)=min(com_dff(:));
clims(2)=max(com_dff(:));

norm_dff=min(com_dff,clims(2)); % clip to max
norm_dff=max(norm_dff-clims(1),0); % clip min
norm_dff=norm_dff./(clims(2)-clims(1)); % normalize to [0,1]


idx_img=round(norm_dff.*size(cmap,1));
im1_rgb=ind2rgb(idx_img,cmap);

[s,f,t]=fb_pretty_sonogram(filtfilt(b,a,double(MIC_DATA)),fs,'n',2048,'overlap',2040,'nfft',4096,'low',1,'zeropad',0);
cbar_idxs=linspace(0,size(cmap,1),1e3);

subplot(7,1,4:6);
imagesc(t,f,s);axis xy;ylim([0 9e3]);
set(gca,'TickDir','out');box off;
colormap(sono_cmap);freezeColors();

subplot(7,1,7);
imagesc(cbar_idxs);axis off;
colormap(cmap);freezeColors();

figure();

h=image(im1_rgb);
set(h,'AlphaData',norm_max_proj);
set(gca,'color',bgcolor,'tickdir','out');
set(gcf,'renderer','opengl','InvertHardCopy','off');

% create sonogram image with legend 




