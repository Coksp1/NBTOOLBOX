function out = nb_compareCoeffs(model1,model2,sort)
% Syntax: 
%
% out = nb_compareCoeffs(model1,model2,sort)
%
% Description:
%
% Use this function to compare parameters between two models. Inputs can be
% coefficient files (structs) or nb_dsge-model objects. Only parameters that
% are found in both models will be displayed.
%  
% Input:
% 
% - model1 : Model 1 (coefficient file (struct) or nb_dsge-model object)
%
% - model2 : Model 2 (coefficient file (struct) or nb_dsge-model object
% 
% - sort   : Sorts output by relative difference. Logical. (optional). Default
%            is false (no sorting).
% 
% Output:
% 
% out      : Cell matrix that shows paramter names, values and absolute 
%            and relative differences. 
%
% Examples: out = nb_compareCoeffs(m_old, m_new, TRUE)
%
% See also:
%
% Written by Erling M. Kravik

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        sort = false;
    end

    if isstruct(model1) == 1
        p1 = model1;
    else
        p1 = getParameters(model1,'struct');
    end

    if isstruct(model2) == 1
        p2 = model2;
    else
        p2 = getParameters(model2,'struct');
    end

    Fieldnames = fieldnames(p1);
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
    headlines = {'PARAMETER NAME',inputname(1), inputname(2),strcat(inputname(2),' - ',inputname(1)),strcat('abs(',inputname(2),'/',inputname(1),' - 1)*100)')};
    table     = [Fieldnames num2cell(a) num2cell(b) num2cell(diff) num2cell(rel)];

    if sort == 1
        if verLessThan('matlab','9.3')
            disp('Sorting is only available in Matlab version 9.3 (2017) and later');
        else
        table = sortrows(table,5,'descend');
        end
    end
    
    out = [headlines;table];


end
