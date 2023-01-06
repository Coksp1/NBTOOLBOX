function [betaD,sigmaD,R,ys,XX,posterior] = doBayesianMF(options,h,nLags,restrictions,y,X,freq,H,mixing,obsSVD)
% Syntax:
%
% [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.doBayesianMF(...
%       options,h,nLags,restrictions,y,X,freq,H,mixing)
% [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.doBayesianMF(...
%       options,h,nLags,restrictions,y,X,freq,H,mixing,obsSVD)
%
% Description:
%
% Estimate B-VAR model with a given prior.
% 
% See also:
% nb_bVarEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin > 9
        options.prior.obsSVD = obsSVD;
    end

    draws = options.draws;
    switch lower(options.prior.type)
        case 'glpmf'
            [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.glpMF(draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h,freq,H,mixing); 
        case 'minnesotamf'
            [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.minnesotaMF(draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h,freq,H,mixing);  
        case 'nwishartmf'
            [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.nwishartMF(draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h,H,mixing);     
        case 'inwishartmf'
            [betaD,sigmaD,R,ys,XX,posterior] = nb_bVarEstimator.inwishartMF(draws,y,X,nLags,options.constant,options.time_trend,options.prior,restrictions,h,H,mixing);       
        otherwise
            error([mfilename ':: Unsupported prior type ' options.prior.type])
    end

end
