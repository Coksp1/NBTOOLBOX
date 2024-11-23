function xout = nb_mstd(xin,backward,forward,flag)
% Syntax:
% 
% xout = nb_mstd(xin,backward,forward,flag)
% 
% Description:
% 
% Moving standard deviation.
% 
% Input:
% 
% - xin      : The data series to smooth. As a double.
% 
% - backward : The number of elements backward to include in moving 
%              standard deviation.
% 
% - forward  : The number of elements forward to include in moving 
%              standard deviation.
% 
% - flag     : If set to true the periods that does not have enough
%              observations forward or backward should be set to nan.
%              Default is false.
%
% Examples:
% 
% newseries = nb_mstd(x,9,0); % 10-element moving standard deviation
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        flag = false;
    end
    
    xout = nan(size(xin));
    if ~flag
        for ii = 1:min(backward,size(xin,1) - forward)   
            xout(ii,:,:) = std(xin(1:ii + forward,:,:),0);
        end
    end
    if size(xin,1) > backward
        for ii = 1 + backward: size(xin,1) - forward     
            xout(ii,:,:) = std(xin(ii - backward:ii + forward,:,:),0);
        end 
    end
    if ~flag
        for ii = size(xin,1) - forward + 1:size(xin,1)   
            xout(ii,:,:) = std(xin(ii:end,:,:),0);
        end
    end

    if flag
        xout(1:backward,:,:)        = nan;
        xout(end-forward+1:end,:,:) = nan;
    end
    
end
