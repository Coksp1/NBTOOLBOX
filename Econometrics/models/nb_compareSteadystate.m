function out = nb_compareSteadystate(model1,model2,sort)
% Syntax: 
%
% out = nb_compareCoeffs(model1,model2,sort)
%
% Description:
%
% Use this function to compare steady state values between two models. Inputs are nb_dsge-model objects. 
% Only variables that are found in both models will be displayed.
%  
% Input:
% 
% - model1 : Model 1 (nb_dsge-model object)
%
% - model2 : Model 2 (nb_dsge-model object
% 
% - sort   : Sorts output by relative difference. Logical. (optional). Default
%            is false (no sorting). Only available fram MatLab 2017.
% 
% Output:
% 
% out      : Cell matrix that shows variable names, values and absolute 
%            and relative differences. 
%
% Examples: out = nb_compareSteadystate(m_old, m_new, TRUE)
%
% See also:
%
% Written by Erling M. Kravik

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        sort = false;
    end
    
    p1 = getSteadyState(model1,[],'struct');
    p2 = getSteadyState(model2,[],'struct');

    Fieldnames = fieldnames(p1);
    mult       = nb_contains(Fieldnames,'mult_');
    Fieldnames = Fieldnames(~mult);
    match      = isfield(p2,Fieldnames);
    Fieldnames = Fieldnames(match);
    

    num = length(Fieldnames);
    a   = zeros(num,1);
    b   = a;

    for ii = 1:num
        a(ii) = p1.(Fieldnames{ii});
        b(ii) = p2.(Fieldnames{ii});
    end

    diff = b-a;
    rel  = abs((b./a-1)*100);
    rel(isnan(rel)) = -inf;

    %Create table
    headlines = {'Vaiable name',inputname(1), inputname(2),strcat(inputname(2),' - ',inputname(1)),strcat('abs(',inputname(2),'/',inputname(1),' - 1)*100)')};
    table     = [Fieldnames num2cell(a) num2cell(b) num2cell(diff) num2cell(rel)];

    if sort == 1
        if verLessThan('matlab','9.3')
            warning('Sorting is only available in Matlab version 9.3 (2017) and later');
        else
        table = sortrows(table,5,'descend'); % Sort by absolute diff
        end
    end
    
    out = [headlines;table];


end
