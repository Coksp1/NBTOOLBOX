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
% - obj : A vector of nb_model_estimate objects.
% 
% Output:
% 
% - printed : A char array with the estimation results.
%
% See also:
% nb_model_generic.print
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    printed = '';
    obj     = obj(:);
    nobj    = numel(obj);
    if nobj == 0
        error('Cannot print a empty vector of nb_model_estimate objects.')
    else
       
        for ii = 1:nobj
            
            res = obj(ii).results;
            opt = obj(ii).estOptions;
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
