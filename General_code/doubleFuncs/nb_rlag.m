function xout = nb_rlag(xin,t,len)
% Syntax:
%
% xout = nb_rlag(xin,t,len)
%
% Description:
%
% Rolling lag operator  
% 
% Input:
% 
% - xin  : A double
%
% - t    : The number of lags
% 
% - len  : The number of periods of the output
% 
% Output: 
% 
% - xout : A double
% 
% Examples:
%
% xout = nb_rlag([1,2,1,2],4,12)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [~,s2,s3] = size(xin);
    xout      = zeros(len,s2,s3);
    for ii=1:t
        xout(ii,:,:)=xin(end-t+ii,:,:);
    end

    for ii=t+1:len
        xout(ii,:,:)=xout(ii-t,:,:);
    end
    
end
