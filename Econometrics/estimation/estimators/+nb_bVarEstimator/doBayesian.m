function [betaD,sigmaD,XX,posterior,pY] = doBayesian(options,h,nLags,restrictions,y,X,yFull,XFull)
% Syntax:
%
% [betaD,sigmaD,XX,posterior,pY] = nb_bVarEstimator.doBayesian(...
%    options,h,nLags,restrictions,y,X)
%
% Description:
%
% Estimate B-VAR model with a given prior.
% 
% See also:
% nb_bVarEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    pY = [];

    [y,X,constant,options] = nb_bVarEstimator.applyDummyPrior(options,y,X,yFull,XFull);
    switch lower(options.prior.type)
        case 'glp'
            [betaD,sigmaD,XX,posterior,pY] = nb_bVarEstimator.glp(options.draws,y,X,nLags,options.constant,options.constantAR,options.time_trend,options.prior,restrictions,h);
        case 'jeffrey'
            [betaD,sigmaD,XX,posterior] = nb_bVarEstimator.jeffrey(options.draws,y,X,options.constant,options.time_trend,restrictions,h);
        case 'minnesota'
            [betaD,sigmaD,XX,posterior] = nb_bVarEstimator.minnesota(options.draws,y,X,nLags,options.constant,options.constantAR,options.time_trend,options.prior,restrictions,h);   
        case 'nwishart'
            [betaD,sigmaD,XX,posterior,pY] = nb_bVarEstimator.nwishart(options.draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h);
        case 'inwishart'
            [betaD,sigmaD,XX,posterior] = nb_bVarEstimator.inwishart(options.draws,y,X,options.constant,options.time_trend,options.prior,restrictions,h);
        otherwise
            error([mfilename ':: Unsupported prior type ' options.prior.type])
    end

    if options.prior.LR || options.prior.SC || options.prior.DIO
        options.constant = constant;
    end

end
