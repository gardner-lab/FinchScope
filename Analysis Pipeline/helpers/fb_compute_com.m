function COM=fb_compute_com(DATA)
% computes the center of mass, DATA is samples x trials
%
%
%


[nsamples,ntrials]=size(DATA)

COM=zeros(1,ntrials);

ind=[1:nsamples]';

for i=1:ntrials
	COM(i)=sum(ind.*DATA(:,i))./sum(DATA(:,i));
end

