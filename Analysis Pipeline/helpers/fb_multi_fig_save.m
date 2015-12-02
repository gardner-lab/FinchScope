function multi_fig_save(fighandle,save_dir,filename,formats,varargin)
%save in multiple formats in a single command
%
%	multi_save(fighandle,save_dir,filename,formats)
%
%
%
%
%

renderer='painters';
res=300;

nparams=length(varargin);

if mod(nparams,2)>0
	error('Parameters must be specified as parameter/value pairs');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'renderer'
			renderer=varargin{i+1};
		case 'res'
			res=varargin{i+1};
	end
end

renderer=[ '-' renderer];
res=[ '-r' num2str(res)];

if nargin<4
	formats='eps,fig,png';
end

try
	if ~isempty(strfind(formats,'eps')) || strcmp(formats,'all')
		print(fighandle,'-depsc2',renderer,fullfile(save_dir,[filename '.eps']));
	end

	if ~isempty(strfind(formats,'tiffn')) || strcmp(formats,'all')
		print(fighandle,'-dtiffn',renderer,fullfile(save_dir,[filename '.tif']));
		
		if exist('rsetwrite')>0
			disp('Writing rset...')
			rsetwrite(fullfile(save_dir,[filename '.tif']),fullfile(save_dir,[filename '.rset']));
			response=[];
			while isempty(response)
				response=input('(K)eep the original .tiff or (d)elete?  ','s');
				switch lower(response(1))
					case 'k'
						break;
					case 'd'
						delete(fullfile(save_dir,[filename '.tif']));
					otherwise
						response=[];
				end
			end
		end
	end	

	%print(fighandle,'-dtiffn','-r300',fullfile(save_dir,[filename '.tif']));

	if ~isempty(strfind(formats,'tiff')) || strcmp(formats,'all')
		print(fighandle,'-dtiff',renderer,res,fullfile(save_dir,[filename '.tiff']));
	end

	if ~isempty(strfind(formats,'pdf')) || strcmp(formats,'all')
		print(fighandle,'-dpdf',renderer,res,fullfile(save_dir,[filename '.pdf']));
	end

	if ~isempty(strfind(formats,'png')) || strcmp(formats,'all')
		print(fighandle,'-dpng',renderer,res,fullfile(save_dir,[filename '.png']));
	end

	if ~isempty(strfind(formats,'fig')) || strcmp(formats,'all')
		saveas(fighandle,fullfile(save_dir,[filename '.fig']));
	end


catch
	disp('Save did not work (running in terminal emulation?)...')
	disp('Trying simple file formats...')

	if ~isempty(strfind(formats,'eps')) || strcmp(formats,'all')
		print(fighandle,'-depsc2',renderer,'-r100',fullfile(save_dir,[filename '.eps']));
	end

	if ~isempty(strfind(formats,'png')) || strcmp(formats,'all')
		print(fighandle,'-dpng',renderer,'-r100',fullfile(save_dir,[filename '.png']));
	end

	if ~isempty(strfind(formats,'fig')) || strcmp(formats,'all')
		saveas(fighandle,fullfile(save_dir,[filename '.fig']));
	end
end

end
