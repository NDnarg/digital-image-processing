function [e]=getEntropy(pmf)
pmf = pmf(find(pmf>0));
e = -1*sum(pmf.*log(pmf));
return; 
