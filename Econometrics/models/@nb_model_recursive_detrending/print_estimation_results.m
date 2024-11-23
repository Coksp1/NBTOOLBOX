function printed = print_estimation_results(obj)
% Syntax:
%
% printed = print_estimation_results(obj)
%
% Description:
%
% Get the estimation result printed to a char array.
% 
% Input:
% 
% - obj : A vector of nb_model_recursive_detrending objects.
% 
% Output:
% 
% - printed : A char array with the estimation results.
%
% See also:
% nb_model_recursive_detrending.print
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    printed = '';
    obj     = obj(:);
    nobj    = numel(obj);
    if nobj == 0
        error('Cannot print a empty vector of nb_model_recursive_detrending objects.')
    else
       
        for ii = 1:nobj
            
            [res,opt] = getEstResults(obj(ii));
            if nb_isempty(res) || ~isfield(opt(end),'estimator')
                printed = char(printed,'');
                printed = char(printed,['No estimation result for model ' int2str(ii)]);
                printed = char(printed,'');
            else
                
                if strcmpi(opt(end).estimator,'nb_osr')
                    printed    = char(printed,'');
                    printed    = char(printed,['Model: ' int2str(ii)]);
                    opt        = obj(ii).options;
                    opt.parser = obj(ii).parser;
                    printed    = char(printed,nb_dsge.printOSR(res,opt));
                    printed    = char(printed,'');
                else
                    printed = char(printed,'');
                    printed = char(printed,['Model: ' int2str(ii)]);
                    printed = char(printed,nb_estimator.print(res,opt));
                    printed = char(printed,'');
                end
                
            end
            
        end
        
    end

end

function [res,opt] = getEstResults(obj)

    if isempty(obj.modelIter)
        % Trigger no estimation result print
        res = struct();
        opt = struct();
        return
    end

    % Get estimation options
    opt = obj.modelIter(end).estOptions;
    
    % Correct it so it is comunicated as recursive estimation
    opt.recursive_estim = true;
    if obj.model.options.data.numberOfDatasets > 1 % Real-time data
        opt.real_time_estim = true;
    end
    opt.recursive_estim_start_ind = obj.modelIter(1).estOptions.estim_end_ind;
    
    % Get results from object
    res = obj.results;
    
end
