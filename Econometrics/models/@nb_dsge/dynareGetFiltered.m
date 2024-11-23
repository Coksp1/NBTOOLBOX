function results = dynareGetFiltered(results,oo_)
% Syntax:
%
% results = nb_dsge.dynareGetFiltered(results,oo_)
%
% Description:
%
% Get filtered variables from dynare and add them to the struct results.
% 
% Input:
% 
% - results : A struct
%
% - oo_     : The dynare output oo_
% 
% Output:
% 
% - results : A struct with the stored filtered variables, if any
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Load the filtered variables from dynare
    if isfield(oo_,'FilteredVariables')
        variables = fieldnames(oo_.FilteredVariables);
        data      = [];
        for j = 1:length(variables)
            vj   = variables{j};
            temp = oo_.FilteredVariables.(vj);
            if size(temp,1) == 1 
                temp = temp';
            end
            data = cat(2,data,temp);
        end

        results.filtered.variables.data      = data;
        results.filtered.variables.variables = variables';
    end
    
    % Load the smoothed variables from dynare
    if isfield(oo_,'SmoothedVariables')
        variables = fieldnames(oo_.SmoothedVariables);
        data      = [];
        for j = 1:length(variables)
            vj   = variables{j};
            temp = oo_.SmoothedVariables.(vj);
            if size(temp,1) == 1 
                temp = temp';
            end
            data = cat(2,data,temp);
        end

        results.smoothed.variables.data      = data;
        results.smoothed.variables.variables = variables';
    end
    
    % Load the updated variables from dynare
    if isfield(oo_,'UpdatedVariables')
        variables = fieldnames(oo_.UpdatedVariables);
        data      = [];
        for j = 1:length(variables)
            vj   = variables{j};
            temp = oo_.UpdatedVariables.(vj);
            if size(temp,1) == 1 
                temp = temp';
            end
            data = cat(2,data,temp);
        end

        results.filtered.variables.data      = data;
        results.filtered.variables.variables = variables';
        
    end
    
    % Load the filtered variables from dynare
    if isfield(oo_,'FilteredShocks')
        variables = fieldnames(oo_.FilteredShocks);
        data      = [];
        for j = 1:length(variables)
            vj   = variables{j};
            temp = oo_.FilteredShocks.(vj);
            if size(temp,1) == 1 
                temp = temp';
            end
            data = cat(2,data,temp);
        end

        results.filtered.shocks.data      = data;
        results.filtered.shocks.variables = variables';
    end
    
    % Load the smoothed variables from dynare
    if isfield(oo_,'SmoothedShocks')
        variables = fieldnames(oo_.SmoothedShocks);
        data      = [];
        for j = 1:length(variables)
            vj   = variables{j};
            temp = oo_.SmoothedShocks.(vj);
            if size(temp,1) == 1 
                temp = temp';
            end
            data = cat(2,data,temp);
        end

        results.smoothed.shocks.data      = data;
        results.smoothed.shocks.variables = variables';
    end
    
    % Load the updated variables from dynare
    if isfield(oo_,'UpdatedShocks')
        variables = fieldnames(oo_.UpdatedShocks);
        data      = [];
        for j = 1:length(variables)
            vj   = variables{j};
            temp = oo_.UpdatedShocks.(vj);
            if size(temp,1) == 1 
                temp = temp';
            end
            data = cat(2,data,temp);
        end

        results.filtered.shocks.data      = data;
        results.filtered.shocks.variables = variables';
        
    end
    
    
end
