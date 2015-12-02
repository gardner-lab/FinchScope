function mergelist=fb_merge_peaks(PEAKS,VALS,varargin) 
%
%
%
%
%
%

win=5;
thresh=-inf;

nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'win'
			win=varargin{i+1};
		case 'thresh'
			thresh=varargin{i+1};
	end
end


for i=1:length(PEAKS)

	pklist=PEAKS{i}(VALS{i}>thresh);

	if isempty(pklist)
		mergelist{i}={};
		continue;
	end

	mergelist{i}{1}=pklist(1);

	for j=2:length(pklist)

		flag=1;

		for k=1:length(mergelist{i})


			if abs(pklist(j)-mean(mergelist{i}{k}))<=win
				mergelist{i}{k}=[mergelist{i}{k} pklist(j)];
				flag=0;
				break;
			end


		end

		if flag
			mergelist{i}{end+1}=pklist(j);
		end
	end
end
