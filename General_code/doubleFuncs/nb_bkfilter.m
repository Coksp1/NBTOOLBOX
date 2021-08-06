function x = nb_bkfilter(y,low,high)
% Syntax:
%
% x = nb_bkfilter(y,low,high)
%
% Description:
%
% Implements the approximation to the band pass filter found in 
% "The Band Pass Filter" by Lawrence J.Christiano and Terry J. 
% Fitzgerald (1999).
%
% Inputs:
%
% - y    : A timeseries, as a nobs x nvars x npage double.
%
% - low  : Lowest frequency. > 2
%
% - high : Highest frequency. > low
%   
% Output:
%
% - x    : double (nobs x 1 x npage) containing filtered data. 
%   
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if high <= low
        error([mfilename ':: the lowest frequency cannot be be higher than the highest frequency.'])
    end
    if low < 2
        error([mfilename ':: the lowest frequency cannot be be less than 2.'])
    end
    
    % Check for nan
    [nobs,nvars,npage] = size(y);
    isNaN              = ~isfinite(y);
    if any(isNaN(:))
        x = y;
        for cc = 1:nvars
            for pp = 1:npage
                good          = ~isnan(y(:,cc,pp));
                x(good,cc,pp) = nb_bkfilter(y(good,cc,pp),low,high);
            end
        end
        return
    end
    
    % Run filter
    t  = 1:nobs;
    b  = 2*pi/low;
    a  = 2*pi/high;
    B0 = (b-a)/pi;
    B  = [B0,(sin(t(1:end-1)*b) - sin(t(1:end-1)*a))./(t(1:end-1)*pi)]'; 
    A  = zeros(nobs,nobs);
    for ii = 1:nobs
        A(ii,ii:nobs) = B(1:end-ii+1)';
        A(ii:nobs,ii) = B(1:end-ii+1);
    end
    A(1,1)       = B0/2;
    A(nobs,nobs) = B0/2;

    for ii = 1:nobs-1
        A(ii+1,1)       = A(ii,1) - B(ii,1);
        A(nobs-ii,nobs) = A(ii,1) - B(ii,1);
    end
    
    t_1    = t' - 1;
    t_1    = t_1(:,ones(1,nvars),ones(1,npage));
    lambda = (y(nobs,:,:) - y(1,:,:))/(nobs-1); % This is the mean drift
    lambda = lambda(ones(1,nobs),:,:);
    Xun    = y - t_1.*lambda;
    x      = Xun;
    for pp = 1:npage
        x(:,:,pp) = A*Xun(:,:,pp) ;
    end  
    
end
