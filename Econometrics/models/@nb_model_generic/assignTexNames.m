function obj = assignTexNames(obj,names,texNames)
% Syntax:
%
% obj = assignTexNames(obj,names,texNames)
%
% Description:
%
% Assign tex names to variables and parameters. Tex names should not
% include subscripts for any variable, as _{t} is automatically appended
% to each variable! Use superscripts instead.
% 
% Input:
% 
% - obj      : An object of class nb_model_generic.
%
% - names    : A Nx1 cellstr with the names of the variables and/or 
%              parameters of the model. 
% 
% - texNames : A Nx1 cellstr with the corresponding tex names of the
%              variables and/or parameters of the model. 
%
% Output:
% 
% - obj      : A nb_model_generic object where the dependent, endogenous,
%              exogenous, residuals or parameters properties has been set
%              some of it tex_name fields. (Also observables and 
%              observablesFast for factor model.)
%
% See also:
% nb_dsge.writeTex, nb_dsge.writePDF
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only handles a scalar nb_dsge object.'])
    end
    
    types = {'dependent', 'endogenous', 'exogenous', 'residuals'};
    if isa(obj,'nb_factor_model_generic')
        types = [types,{'observables'}];
    end
    if isa(obj,'nb_favar')
        types = [types,{'observablesFast'}];
    end
    if isa(obj,'nb_fmdyn')
        types = [types,{'factors'}];
    end
    
    if isa(obj,'nb_dsge')
       types = types(2:end); 
    end
    
    for ii = 1:length(types) 
        [obj,names,texNames] = setOneType(obj,types{ii},names,texNames);
    end
    
    if isa(obj,'nb_dsge')
        [obj,names,~] = setParameters(obj,names,texNames);
    end
    
    if ~isempty(names)
        warning('nb_model_generic:assignTexNames',[mfilename ': The following names were ',...
                'not found to be a variable or a parameter of the model; ' toString(names) '.'])
    end
    
    if isa(obj,'nb_dsge')
        % For nb_dsge objects the dependent and endogenous are equal! 
        obj.dependent = obj.endogenous;
    end
    
end

%==========================================================================
function [obj,names,texNames] = setOneType(obj,type,names,texNames)

    typeVal = obj.(type);
    if isempty(typeVal.tex_name) || length(typeVal.tex_name) ~= typeVal.number
        typeVal.tex_name = strrep(typeVal.name,'_','\_');
    end    
    typeNames             = typeVal.name; 
    [ind,loc]             = ismember(names,typeNames);
    loc                   = loc(ind);
    typeVal.tex_name(loc) = texNames(ind);
    
    if strcmpi(type,'residuals')
        obj.res_tex_names = typeVal.tex_name;
    elseif strcmpi(type,'factors')
        obj.factorNames = typeVal;
    else
        obj.(type) = typeVal;
    end
    names    = names(~ind);
    texNames = texNames(~ind);
    
end

%==========================================================================
function [obj,names,texNames] = setParameters(obj,names,texNames)

    create = false;
    if ~isfield(obj.estOptions.parser,'parameters_tex_name')
        create = true;
    elseif length(obj.estOptions.parser.parameters_tex_name) ~= length(obj.estOptions.parser.parameters)
        create = true;
    end
    if create
        obj.estOptions.parser.parameters_tex_name = strrep(obj.estOptions.parser.parameters,'_','\_');
    end    
    [ind,loc] = ismember(names,obj.estOptions.parser.parameters);
    loc       = loc(ind);
    obj.estOptions.parser.parameters_tex_name(loc) = texNames(ind);
    
    names    = names(~ind);
    texNames = texNames(~ind);
    
end
