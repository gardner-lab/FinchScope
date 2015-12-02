function [MATCHES,SCORE,TEMPLATE]=fb_quick_template_match(FILE,varargin)
%
%
%
%
%

fs=24.414e3;
n=1024;
overlap=1e3;
down_factor=5;
template=[];
nparams=length(varargin);
gif_dir='gif';
out_dir='extraction';
dat_dir='syllable_data';
MATCHES=[];
padding=[.2 .2];

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})	
		case 'fs'
			fs=varargin{i+1};
		case 'template'
			template=varargin{i+1};
		case 'gif_dir'
			gif_dir=varargin{i+1};
		case 'out_dir'
			out_dir=varargin{i+1};
		case 'dat_dir'
			dat_dir=varargin{i+1};
		case 'padding'
			padding=varargin{i+1};
	end
end


if nargin<1 | isempty(FILE)
	[filename,pathname]=uigetfile({'*.mat'},'Pick a .mat file to retrieve mic data for',fullfile(pwd));
	[path,file,ext]=fileparts(fullfile(pathname,filename));
else
	[path,file,ext]=fileparts(FILE);
end

load(fullfile(path,[file ext]),'mic_data','fs');

[b,a]=ellip(5,.2,80,[500]/(fs/2),'high');
mic_data=filtfilt(b,a,double(mic_data));

temp_mat=[];

mkdir(out_dir);

if isempty(template)
	
	TEMPLATE.data=fb_spectro_navigate(mic_data);
	TEMPLATE.features=fb_smscore(TEMPLATE.data,fs);

	[s,f,t]=pretty_sonogram(TEMPLATE.data,fs,'low',1);

	minf=1;
	maxf=min(find(f>=10e3));

	imwrite(flipdim(uint8(s(minf:maxf,:)),1),hot(63),fullfile(out_dir,'template.gif'),'gif');
	save(fullfile(out_dir,'template.mat'),'TEMPLATE');

else
	
	TEMPLATE=template;
	clear template;

end

score_file=fullfile(dat_dir,[ file '_score.mat' ]);

if exist(score_file,'file')
	load(score_file,'features');
	file_features=features;
	clear features;
else
	file_features=fb_smscore(mic_data,fs);
end

file_length=size(file_features{1},2);
template_length=size(TEMPLATE.features{1},2)-1;

for j=1:length(file_features)
	
	score_temp{j}=[];

	for k=1:file_length-template_length
		score_temp{j}=[score_temp{j} sum(sum(abs( file_features{j}(:,k:k+template_length)-TEMPLATE.features{j} )))];
	end

	% keep the raw scores for further analysis

	raw_temp{j}=score_temp{j};

	score_temp{j}=score_temp{j}-mean(score_temp{j});
	score_temp{j}=score_temp{j}/std(score_temp{j});
	score_temp{j}(score_temp{j}>0)=0;
	score_temp{j}=abs(score_temp{j});

end

attributes=length(score_temp);
product_score=score_temp{1};

for j=2:attributes, product_score=product_score.*score_temp{j}; end

[pks,locs]=findpeaks(product_score,'MINPEAKHEIGHT',2,'MINPEAKDISTANCE',template_length);

SCORE=score_temp;

if isempty(locs)
    return;
end

MATCHES(:,1)=(locs*(n-overlap)*down_factor)-n;
MATCHES(:,2)=MATCHES(:,1)+length(TEMPLATE.data);

MATCHES(:,1)=MATCHES(:,1)-padding(1)*fs;
MATCHES(:,2)=MATCHES(:,2)+padding(2)*fs;

mkdir(fullfile(out_dir,gif_dir));

to_del=[];

for i=1:size(MATCHES,1)

	if MATCHES(i,1)<1 | MATCHES(i,2)>length(mic_data)
		to_del=[to_del i];
		continue;
	end

	% write out sonograms for each match

	[s,f,t]=pretty_sonogram(mic_data(MATCHES(i,1):MATCHES(i,2)),fs,'low',1);

	minf=1;
	maxf=min(find(f>=10e3));

	savefile=[ file '_' sprintf('%04.0f',i) ];

	imwrite(flipdim(uint8(s(minf:maxf,:)),1),hot(63),fullfile(out_dir,gif_dir,[ savefile '.gif' ]),'gif');

end

MATCHES(to_del,:)=[];
