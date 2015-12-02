function [P,x]=fb_peak_probability(PEAKS,varargin)
%
%
%
%
%
%



% select file to load

nparams=length(varargin);
exclude=[];
use_com=0;
range=[-inf inf];
time_bound=[0 20];
win_size=.05;

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})	
		case 'fig_num'
			fig_num=varargin{i+1};
		case 'exclude'
			exclude=varargin{i+1};	
		case 'use_com'
			use_com=varargin{i+1};
		case 'range'
			range=varargin{i+1};
	end	
end



% get the pairwise distance between all ROIs

% for now, take euclidean distance between the centroid of each ROI

nrois=length(PEAKS);

for i=1:nrois
	PEAKS{i}(PEAKS{i}<range(1)|PEAKS{i}>range(2))=[];
end

% activity difference, correlation

%roi_dist=pdist(centroid,'euclidean');

% take the center of mass for each dff trace


% in a sliding window, bin


bins=time_bound(1):win_size:time_bound(end);
bins

% concatenate peaks

pk_times=cat(2,PEAKS{:});

[n]=histc(pk_times,bins);

p=n./nrois;

x=[];
P=[];
for i=1:length(bins)-1
	x=[x bins(i:i+1)];
	P=[P repmat(p(i),[1 2])];
end

