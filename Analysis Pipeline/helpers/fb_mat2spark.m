function fb_mat2spark(DATA,varargin)
% takes a dff matrix, assuming X,Y,Z, where Z is the time-series
%
%
%  example:
%
%  mov_data=fb_retrieve_mov();
%  fb_mat2spark(mov_data,'resize',.25,'output_type','txt');


output_file='sparkdata.txt';
output_type='txt';
resize=.25;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETER COLLECTION  %%%%%%%%%%%%%%

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'output_file'
			output_file=varargin{i+1};
		case 'output_type'
			output_type=varargin{i+1};
		case 'resize'
			resize=varargin{i+1};
	end
end

if resize~=1
	disp(['Resizing movie data by a factor of ' num2str(resize)]);
	DATA=imresize(DATA,resize);
end

if strcmp(lower(output_type),'t')
	fid=fopen(output_file,'w');
else
	fid=fopen(output_file,'wb'); % not working yet, stick to txt
end

[rows,columns,frames]=size(DATA);

% could reduce file access by first reshaping into a 2d matrix

%keymat=zeros(rows*columns,2); % keys contain two columns (x,y)
newmat=zeros(rows*columns,frames+2); % two extra columns for the keys

% rows are y, columns are x

disp('Reformatting data (this will take a minute)');

[nblanks formatstring]=fb_progressbar(100);
fprintf(1,['Progress:  ' blanks(nblanks)]);

counter=1;
tmp=zeros(1,2);
for i=1:rows
	for j=1:columns

		fprintf(1,formatstring,round((counter/(rows*columns))*100));
		
		tmp(1)=j; % x
		tmp(2)=i; % y
		tmp2=squeeze(DATA(i,j,:));
		newmat(counter,:)=[tmp tmp2(:)'];	
		counter=counter+1;
	end
end

fprintf(1,'\n');

disp('Writing file...');

if strcmp(lower(output_type(1)),'t')
	formatstring='%.43g';
	for i=1:frames+1
		formatstring=[formatstring ' %.43g'];
	end
	formatstring=[formatstring '\n'];
	fprintf(fid,formatstring,newmat');
else
	fwrite(fid,newmat','double');
end

fclose(fid);


