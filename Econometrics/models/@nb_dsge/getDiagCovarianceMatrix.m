function vcv = getDiagCovarianceMatrix(obj)
% Syntax:
%
% vcv = getDiagCovarianceMatrix(obj)
%
% Description:
%
% Get diagonal covariance matrix of the DSGE model. For RISE it is assumed 
% that the shock standard deviations are parameters starting with 'std_'.
% 
% Input:
% 
% - obj : An object of class nb_dsge 
% 
% Output:
% 
% - vcv : A nShock x 1 double
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if obj.isRise 
        
        exo_names     = cellstr(obj.solution.res);
        exo_nbr       = length(exo_names);
        vcv           = zeros(exo_nbr,1);
        std_exo_names = strcat('std_',exo_names);
        param_names   = obj.estOptions.rise_obj.parameters.name;
        param_values  = obj.estOptions.rise_obj.parameter_values;
        for ii = 1:exo_nbr
            ind     = strcmp(std_exo_names{ii},param_names);
            vcv(ii) = param_values(ind,1);     
        end
        
    elseif obj.isNB
        
        exo_names     = cellstr(obj.solution.res);
        exo_nbr       = length(exo_names);
        vcv           = zeros(exo_nbr,1);
        std_exo_names = strcat('std_',exo_names);
        param_names   = obj.parameters.name;
        param_values  = obj.parameters.value;
        for ii = 1:exo_nbr
            ind     = strcmp(std_exo_names{ii},param_names);
            vcv(ii) = param_values(ind,1);     
        end
        
    else
        vcv = sqrt(diag(obj.estOptions.M_.Sigma_e));
    end
           
end
