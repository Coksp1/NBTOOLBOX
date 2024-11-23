function y0 = drawNowcastFromKalmanFilter(yD,pD,draws)
% Syntax:
%
% y0 = nb_forecast.drawNowcastFromKalmanFilter(yD,pD,draws)
%
% Description:
%
% Produce density nowcast from kalman filter output.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Draw from the distribution of the endogenous variables
    treshold = eps(max(yD(:)))^0.7;
    y0       = yD(:,:,ones(1,draws));
    for ii = 1:size(pD,3)
        indR = ~all(abs(pD(:,:,ii)) < treshold,1);
        if any(indR)
            locR          = find(indR);
            y0(locR,ii,:) = yD(locR,ii,:) + nb_forecast.multvnrnd(pD(locR,locR,ii),1,draws);
        end
    end

end
