function code = writeTex(obj,filename,type)
% Syntax:
%
% code = writeTex(obj)
% code = writeTex(obj,filename,type)
% writeTex(obj,filename,type)
%
% Description:
%
% Write latex code of model equations.
% 
% Input:
% 
% - obj      : An object of class nb_dsge.
% 
% - filename : Give the name of the written .tex file. If not given or
%              empty no file will be written. Extension is ignored.
%
% - type     : Either 'names' or 'values'. Default is 'names'. If 'values'
%              is given the parameters will be substituted with their
%              values instead of their name.
%
% Output:
% 
% - code : A cellstr with the latex code of the model equations.
%
% See also:
% nb_dsge.writePDF, nb_model_generic.assignTexNames
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'names';
        if nargin < 2
            filename = '';
        end
    end

    if numel(obj) > 1
        error([mfilename ':: This method only handles a scalar nb_dsge object.'])
    end
    
    if ~isNB(obj)
        error([mfilename ':: This method is only supported if model is parsed with NB toolbox.'])
    end
    
    if strcmpi(type,'values')
        paramTex = strtrim(cellstr(num2str(obj.results.beta)))';
    else
        paramTex = obj.parameters.tex_name';
    end
        
    eqs         = obj.parser.equations;
    eqs         = nb_dsge.transLeadLag(eqs);
    eqs         = strcat(eqs,'==0'); 
    latexVars   = [strcat(obj.endogenous.tex_name,'_{t-1}'),strcat(obj.endogenous.tex_name,'_{t}'),...
                   strcat(obj.endogenous.tex_name,'_{t+1}'),strcat(obj.exogenous.tex_name,'_{t}'),...
                   paramTex];
    vars        = [strcat(obj.endogenous.name,'_lag'),obj.endogenous.name,...
                   strcat(obj.endogenous.name,'_lead'),obj.exogenous.name,...
                   obj.parameters.name'];
    eqsLatexObj = nb_eq2Latex.parse(eqs,...
        'latexVars',latexVars,...
        'vars',vars);
    code = writeTex(eqsLatexObj,filename);
    
end
