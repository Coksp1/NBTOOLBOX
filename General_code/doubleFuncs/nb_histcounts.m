function [index,centered] = nb_histcounts(x,interval,centered)
% Syntax:
%
% [index,centered] = nb_histcounts(x,interval,centered)
%
% Description:
%
% Order the observation (dim1) into bins using the specified interval
% 
% Input:
% 
% - obj      : An object of class double
%
% - interval : A 1 x nBins double
%
% - centered : A 1 x nBins double with the centered bins value.
% 
% Output:
% 
% - index    : Number of counts in each bin. As a 1 x nBins double.
%
% - centered : The centered location of the bins of the elements in index.  
%              As a 1 x nBins double.
%
% Examples:
%
% obj  = nb_data.rand(1,100,4,2);
% ind1 = nb_histcounts(obj.data,0.1:0.1:1)
% ind2 = nb_histcounts(obj.data,0.1:0.1:1,0.05:0.1:1)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        centered = [];
    end
    
    [s1,s2,s3] = size(x);
    intervalT  = interval';
    nBins      = length(intervalT);
    index      = zeros(nBins,s2,s3);
    for ii = 2:nBins
        index(ii,:,:) = sum(x < intervalT(ii-1),1);
    end
    index(1:end-1,:,:) = diff(index);
    
    for ii = 1:s3
        for jj = 1:s2
            index(end,jj,ii) = s1 - sum(isnan(x(:,jj,ii))) - sum(index(1:end-1,jj,ii));
        end
    end
    
    if isempty(centered)
        d        = intervalT(2) - intervalT(1);
        centered = intervalT(1) - d/2:d:intervalT(end);
    end
    if size(centered,2) > 1
        centered = centered';
    end

end
