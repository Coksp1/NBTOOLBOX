function tempOpt = createEstOptionsStruct(obj)
% Syntax:
%
% tempOpt = createEstOptionsStruct(obj)
%
% Description:
%
% Combine the options and estOptions struct.
% 
% See also:
% nb_dsge.irf, nb_dsge.getEstimationOptions
%
% Written by Kenneth Sæterhagen Paulsen

    modOpt  = obj.estOptions;
    tempOpt = nb_rmfield(obj.options,{'data','estim_end_date','estim_start_date'});
    tempOpt = nb_structcat(modOpt,tempOpt,'first');
    if ~isfield(tempOpt,'estimType')
        tempOpt.estimType  = 'bayesian';
    end
    
end
