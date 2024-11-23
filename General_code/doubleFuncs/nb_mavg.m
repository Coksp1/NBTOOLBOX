function xout = nb_mavg(xin,backward,forward,flag)
% Syntax:
% 
% xout = nb_mavg(xin,backward,forward,flag)
% 
% Description:
% 
% Smooths dataseries. Moving average
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
% - flag     : If set to true the periods that does not have enough
%              observations forward or backward should be set to nan.
%              Default is false.
%
% Examples:
% 
% newseries = nb_mavg(x,9,0); % 10-element moving average
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        flag = false;
    end
    
    [s1,s2,s3] = size(xin);

    xfor       = nan(s1,s2,s3,forward);
    xfor_nzero = ones(s1,s2,s3,forward);
    for cc = 1:forward
        if cc <= s1
            xfor(:,:,:,cc)                  = [xin(cc+1:end,:,:);zeros(cc,s2,s3)];
            xfor_nzero(end-cc+1:end,:,:,cc) = zeros;
        end
    end
    xfor_nzero(isnan(xfor)) = zeros;

    xback       = nan(s1,s2,s3,backward);
    xback_nzero = ones(s1,s2,s3,backward);
    for mm = 1:backward
        if mm <= s1
            xback(:,:,:,mm)          = [zeros(mm,s2,s3);xin(1:end-mm,:,:)];
            xback_nzero(1:mm,:,:,mm) = zeros;
        end
    end
    xback_nzero(isnan(xback)) = zeros;
    
    xout = (sum(xback,4,'omitnan') + xin + sum(xfor,4,'omitnan'))./(sum(xback_nzero,4) + sum(xfor_nzero,4) + 1); 

    if flag
        xout(1:backward,:,:)        = nan;
        xout(end-forward+1:end,:,:) = nan;
    end
    
end
