function [NBLANKS FORMATSTRING]=progressbar(NITERATIONS)
%
%
%

% returns formatstring for a simple progressbar

% taken from http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/ Hnans Geerligs 8/2007

NBLANKS=ceil(log10(NITERATIONS)+1);

backspace_string='';

for i=1:NBLANKS
	backspace_string=strcat(backspace_string,'\b');
end

FORMATSTRING= [ backspace_string '%-' num2str(NBLANKS) 'd' ];
