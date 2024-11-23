function out = interpretSteadyStateInput(parser,inputValue,inParsing,propertyName)
% Syntax:
%
% out = nb_dsge.interpretSteadyStateInput(parser,inputValue,...
%                       inParsing,propertyName)
%
% Description:
%
% Interpret and check the steady_state_init option/initval block.
% 
% See also:
% nb_model_estimate.set, nb_dsge.parse
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(inputValue)
        out = inputValue;
        return
    end

    if inParsing
        switch lower(propertyName)
            case 'steady_state_init'
                str = 'initval block';
            case 'steady_state_fixed'
                str = 'fixed_block';
        end
    else
        str = ['''' propertyName ''' option'];
    end

    if ~inParsing
    
        if nb_isempty(parser)
            error([mfilename ':: Cannot set the ''' propertyName ''' options before a model file is parsed.'])
        end

        if isstruct(inputValue)
            inputValue = [fieldnames(inputValue),struct2cell(inputValue)];
        else
            if ~iscell(inputValue)
                error([mfilename ':: The ''' propertyName ''' options must have size N x 2 if given as a cell.'])
            end
            if size(inputValue,2) ~= 2
                error([mfilename ':: The ''' propertyName ''' options must have size N x 2 if given as a cell.'])
            end
        end
        
    end
    
    switch lower(propertyName)
        case 'steady_state_init'
            allowed = parser.endogenous;
            extra   = '';
        case 'steady_state_fixed'
            allowed = [parser.endogenous,parser.parameters];
            extra   = 'or parameters ';
    end
    
    names = inputValue(:,1);
    test  = ismember(names,allowed);
    if any(~test)
        error(['The ' str ' provided some endogenous variables ' extra 'that are not part of the model; '...
               toString(names(~test)) '.'])
    end
    
    if ~inParsing
        
        if ~iscell(names)
            error([mfilename ':: The first column of the ''' propertyName ''' options must be a N x 1 cellstr.'])
        end

        try
            cell2mat(inputValue(:,2));
        catch
            error([mfilename ':: The second column of the ''' propertyName ''' options must be a N x 1 cell with scalar numbers.'])
        end
        
    end
    
    out = cell2struct(inputValue(:,2),inputValue(:,1));
    
end
