function u = getMeasurementEqRes(options,sq,sp,beta,y,z,x)
% Syntax:
%
% u = nb_arimaEstimator.getMeasurementEqRes(options,sq,sp,beta,y,z,x)
%
% Description:
%
% Get residual from the measurement equation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    numDyn  = options.AR + options.MA + sq + sp;
    numExoT = size(x,2);
    ind     = options.constant + numDyn + numExoT + 1;
    G       = [beta(logical(options.constant));beta(ind:end)]';
    if isempty(G)
        u = y;
    else
        if options.constant
            z = [ones(size(z,1),1),z];
        end
        u = y - (G*z')';
    end
    
end
