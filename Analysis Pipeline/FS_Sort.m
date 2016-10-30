function FS_Sort(motif)

% Sort data by motif



%% Custom Paramaters
nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'filt_rad'
			filt_rad=varargin{i+1};
		case 'filt_alpha'
			filt_alpha=varargin{i+1};
	end
end


mov_listing=dir(fullfile(pwd,'*.mat')); % Get all .mat file names
mov_listing={mov_listing(:).name};
filenames=mov_listing;
Here = pwd;
