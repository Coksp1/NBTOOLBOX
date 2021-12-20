function ret = handleMissing(obj) 
% Syntax:
%
% ret = handleMissing(obj)
%
% Description:
%
% Check if a nb_model_estimate object handle missing observations. 
% 
% Input:
% 
% - obj : A scalar nb_model_etimate object.
% 
% Output:
% 
% - ret : true or false. true if the estimation settings is so that the
%         model handle missing data.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = false;
    if isempty(obj.options.prior)
        if strcmpi(obj.options.estim_method,'ml')
            ret = true;
        elseif ~isempty(obj.options.missingMethod)
            ret = true;
        end
    else
        if any(strcmpi(obj.options.prior.type,nb_var.mfPriors()))
            ret = true;
        end
    end
    
end
