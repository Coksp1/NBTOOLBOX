function xoutnan = nb_nanmavg(xin,backward,forward,flag)
% Syntax:
% 
% xoutnan = nb_nanmavg(xin,backward,forward,flag)
% 
% Description:
% 
% Smooths dataseries. Moving average. Handles leading and trailing nans. 
% 
% Input:
% 
% - xin      : The data series to smooth. As a double.
% 
% - backward : The number of elements backward to include in moving 
%              average.
% 
% - forward  : The number of elements forward to include in moving 
%              average.
% 
% Examples:
% 
% newseries = nb_nanmavg(x,9,0); % 10-element moving average
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        flag = false;
    end

    xoutnan   = nan(size(xin));
    isNaN     = isnan(xin);
    [~,s2,s3] = size(xin);
    for ii = 1:s2
        for jj = 1:s3            
            start  = find(~isNaN(:,ii,jj),1);
            finish = find(~isNaN(:,ii,jj),1,'last');
            xinvar = xin(start:finish,ii,jj);
            if ~isempty(xinvar)    
                xoutnan(start:finish,ii,jj) = nb_mavg(xinvar,backward,forward,flag);    
            end
        end
    end

end
