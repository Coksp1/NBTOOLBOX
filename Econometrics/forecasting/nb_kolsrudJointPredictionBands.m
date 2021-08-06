function KJPB = nb_kolsrudJointPredictionBands(fcst,percUL)
% Syntax:
%
% KJPB = nb_kolsrudJointPredictionBands(fcst,percUL)
%
% Description:
%
% Calculate joint prediction bands due to Dag Kolsrud (2015): 
% "A time-simultaneous prediction box for a multivariate time 
% series", Journal of Forecasting. 
%
% Input:
% 
% - fcst   : A nHor x nVar x nDraws double
%
% - percUL : A 1 x nPerc double with the percentiles to calculate.
%
%            E.g. [5,15,25,35,65,75,85,95]
% 
% Output:
% 
% - KJPB   : A nHor x nVar x nDraws double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    maxDist = chebyshevDistance(fcst);
    [~,i]   = sort(maxDist);
    KJPB    = findBounds(fcst,percUL,i);
    
end

function JPB = findBounds(fcst,percUL,i)

    [nSteps,nVars,nDraws] = size(fcst);

    % Find the bounds
    nPerc   = size(percUL,1);
    percInd = ceil(percUL*nDraws/100);
    low     = percInd(1:nPerc/2);
    up      = flipud(percInd(nPerc/2+1:end));
    JPBU    = nan(nSteps,nVars,nPerc/2);
    JPBL    = nan(nSteps,nVars,nPerc/2);
    JPB     = nan(nSteps,nVars,nPerc);
    for ii = 1:nPerc/2   
        succes             = i(low(ii):up(ii));
        sData              = fcst(:,:,succes);
        JPBU(:,:,end-ii+1) = max(sData,[],3);
        JPBL(:,:,ii)       = min(sData,[],3);
    end
    JPB(:,:,1:nPerc/2)     = JPBL;
    JPB(:,:,nPerc/2+1:end) = JPBU;

end

function maxDist = chebyshevDistance(x)
% Calculate chebyshev distance

    dist    = stdDistance(x);
    maxDist = max(dist,[],1);
    maxDist = max(maxDist,[],2);
    maxDist = maxDist(:);

end

function y = stdDistance(x)
% Calculate standardized distance

    y = bsxfun(@rdivide,abs(bsxfun(@minus,x,mean(x,3))),std(x,0,3));

end
