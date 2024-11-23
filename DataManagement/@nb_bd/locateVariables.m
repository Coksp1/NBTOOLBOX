function locations = locateVariables(variables,state,logic,silent)
% Syntax: 
%
% locations = nb_bd.locatevariables(variables,state,logic,silent)
% 
% Description:
%
% A static method of the nb_bd class
%
% Finds the location of the variables given in the cell variables 
% in the cell of variables state.
% 
% Input:
% 
% - variables         : A cellstr
%  
% - state             : A cellstr
% 
% - logic             : 1 if you want the output to be a logical
%                       array with same size as the input 
%                       state. Each element will be 1 if the
%                       found to be in the variables input,  
%                       otherwise 0.
% 
% - silent            : If you do not want this method to give an 
%                       error message if one of the strings in the
%                       variables input is not found to be in the 
%                       state input. Will the return a empty for
%                       the variables not found.
% 
% Output:
% 
% - locations         :
%
%       > logic == 0 : A double vector with the locations of all 
%                      the strings located in the variables input
%                      in the cellstr state.
%
%                      If silent is set to 1, the string not found 
%                      will return a empty double.
%
%       > logic == 1 : A logical array with same size as the input 
%                      state. Each element will be 1 if the found
%                      to be in the variables input, otherwise 0.
%                       
% Examples:
%
% locations = nb_bd.locateVariables({'Var1','Var2','Var3'},...
%             {'Var1','Var3','Var1'},0);
%
% Will return [1,3,2]
%
% locations = nb_bd.locateVariables({'Var1','Var2'},...
%             {'Var1','Var3','Var2'},1);
% 
% Will return [1,0,1]
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin<4
        silent = false; % if true no error on variables not found
        if nargin < 3
            logic = 0;
        end
    end

    if isempty(variables)
        nvar = 0;
    elseif iscellstr(variables) %#ok<ISCLSTR>
        nvar = numel(variables);
    else
        error([mfilename ':: Input variables is not a cellstr.'])
    end

    variables = strtrim(variables);
    state     = strtrim(state);

    if ~logic

        locations = nan(nvar,1);
        for j = 1:nvar

            vj    = variables{j};
            vj_id = find(strcmp(vj,state));

            if isempty(vj_id)

                if silent
                    continue
                else
                    error([mfilename,':: variable ',vj,' not found'])
                end

            elseif numel(vj_id)>1

                error('nb_bd:locateVariables:DeclaredMoreThanOnce',[mfilename,':: variable ',vj,' declared more than once'])

            end

            locations(j) = vj_id;

        end

    else

        vj_id = zeros(size(state));

        for j = 1:nvar

            vj    = variables{j};
            vj_id = vj_id + strcmp(vj,state);

        end

        locations = logical(vj_id);

    end
    
end
