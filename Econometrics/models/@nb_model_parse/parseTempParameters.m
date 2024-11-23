function out = parseTempParameters(eqs,verbose)
% Syntax:
%
% out = nb_model_parse.parseTempParameters(eqs,verbose)
%
% Description:
%
% Parse terms starting with #, and substitue out for where these terms are
% used.
% 
% Input:
%
% - eqs     : A N x 1 cellstr with the equations of the model.
%
% - verbose : Set to true to print resulting equations.
%
% Output:
%
% - out : A N x 1 cellstr with the parsed equations of the model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nEqs         = length(eqs);
    tempParamInd = false(nEqs,1);
    for ii = 1:length(eqs)
        if strncmp(eqs{ii},'#',1)
            tempParamInd(ii) = true;
        end
    end
    if ~any(tempParamInd)
        out = eqs;
        return
    end
    tempParamEqs = eqs(tempParamInd);
    nTempParams  = length(tempParamEqs);
    tempParams   = cell(1,nTempParams);
    tempValues   = cell(1,nTempParams);
    for ii = 1:nTempParams
        splitted = strtrim(split(tempParamEqs{ii},'='));
        if size(splitted,1) ~= 2
            error(['The temporary paramter defined after a # sign must ',...
                   'include an = sign; ' tempParamEqs{ii}])
        end
        tempVarName = strrep(splitted{1},'#','');
        if ~isvarname(tempVarName)
            error(['The name of temporary paramter defined by the following ',...
                   'equation is not a valid name; ' tempParamEqs{ii}])
        end
        tempParams{ii} = tempVarName;
        tempValues{ii} = splitted{2};
    end
    [tempParams,sortI] = sort(tempParams);
    tempValues         = tempValues(sortI);
    
    nNew          = size(tempValues,2);
    tempValuesOut = cell(nNew,1);
    matches       = regexp(tempValues,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    for ii = 1:length(tempValuesOut)
    
        eq       = tempValues{ii};
        matchesT = matches{ii};
        ind      = ismember(tempParams,matchesT);
        paramT   = strcat('(?<![A-Za-z_])',tempParams(ind),'(?![A-Za-z_0-9])');
        paramNT  = tempValues(ind);
        for pp = length(paramT):-1:1 
            eq = regexprep(eq,paramT{pp},paramNT{pp});
        end
        tempValuesOut{ii} = eq;
        
    end
    tempValues = tempValuesOut;
    
    eqsTrans = eqs(~tempParamInd);
    nNewEqs  = size(eqsTrans,1);
    out      = cell(nNewEqs,1);
    matches  = regexp(eqsTrans,'[A-Za-z_]{1}[A-Za-z_0-9]*(?!\()','match');
    for ii = 1:length(eqsTrans)
    
        eq       = eqsTrans{ii};
        matchesT = matches{ii};
        ind      = ismember(tempParams,matchesT);
        paramT   = strcat('(?<![A-Za-z_])',tempParams(ind),'(?![A-Za-z_0-9])');
        paramNT  = tempValues(ind);
        for pp = length(paramT):-1:1 
            eq = regexprep(eq,paramT{pp},paramNT{pp});
        end
        out{ii} = eq;
        
    end
    
    if verbose
       disp(out);
    end
    
end
