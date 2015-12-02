function fb_plot_roi_stackplot(ROI,T,varargin)
%
%
%
%
%
%

% parameter collection

nparams=length(varargin);

linewidth=1.2;
colors=colormap('winter');
spacing=.1;

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'linewidth'
			linewidth=varargin{i+1};
		case 'colors'
			colors=varargin{i+1};
		case 'spacing'
			spacing=varargin{i+1};
	end
end

ave_fs=1./(diff(T(1:2)));
ntraces=size(ROI,1);

%colors=colormap([ colors '(' num2str(ntraces) ')' ]);

% cycle backwards, top to bottom so that bottom is on top

for i=ntraces:-1:1
	tmp=ROI(i,:);
	plot(T,tmp+(i-1).*spacing,'k-','linewidth',linewidth,'color',colors(i,:));
	hold on;
end

axis tight;
