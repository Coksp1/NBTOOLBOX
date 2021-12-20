function obj = addBreakPoint(obj,parameters,values,date,varargin)
% Syntax:
%
% obj = addBreakPoint(obj,parameters,values,date)
% obj = addBreakPoint(obj,parameters,values,date,varargin)
%
% Description:
%
% To add a break in the structural parameters of the model.
% 
% Caution: To assign the parameter values the at or after the break you 
%          can also use use the nb_model_generic.assignParameters. Append 
%          the original parameter with the a subscript followed by a the 
%          date of the breakpoint, e.g. 'paramName_2012Q1'
%
% If the 'expectedDate' option is used the model is solved with the 
% algorithm of Kulish and Pagan (2017), Estimation ans Solution of Models 
% with Expectations and Structural Changes.
%
% Input:
% 
% - obj        : An object of class nb_dsge.
% 
% - parameters : A cellstr with the parameters that you want to add an
%                unexpected breakpoint to.
%
% - values     : A double with the same size as parameters with the value
%                of the parameters at and after the break. Can be empty, if
%                you want to use the nb_model_generic.assignParameters
%                method to assign the values instead.
%
% - date       : Either a date string or an object of subclass of the
%                nb_date class. This will be the date of the breakpoint.
%
% Optional input:
%
% - 'steady_state_exo' : A struct with the permanent shock associated with
%                        the given break point. Use 
%                        nb_dsge.help('steady_state_exo') to get more help
%                        on this input. When this is added the new 
%                        steady-state will be solved using numerical
%                        methods. 
%
% - 'expectedDate'     : Either a date string or an object of subclass of 
%                        the nb_date class. This will be the date from 
%                        where the break is expected. 
%
% Optional inputs given to the nb_dsge.set method.
% Output:
% 
% - obj : An object of class nb_dsge.
%
% See also:
% nb_dsge.parse, nb_dsge.set
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nb_isempty(obj.estOptions.parser)
        error([mfilename ':: This DSGE model is not formulated.'])
    end
    
    if isempty(parameters)
        parameters = {};
    else
        if ischar(parameters)
            parameters = cellstr(parameters);
        elseif ~iscellstr(parameters)
            error([mfilename ':: The parameters input must be a cellstr'])
        end
        parameters = parameters(:);
    end
    
    if isempty(values)
        values = nan(size(parameters));
    end
    
    if isnumeric(values)
        values = values(:);
    else
        error([mfilename ':: The values input must be a double vector'])
    end

    if size(parameters,1) ~= size(values,1)
        error([mfilename ':: The values (' int2str(size(values,1)) ') input and the parameters ('...
            int2str(size(parameters,1)) ') input must match in size.'])
    end

    if ischar(date)
        date = nb_date.date2freq(date);
    elseif ~isa(date,'nb_date')
        error([mfilename ':: The date input must be a string date or a nb_date object.'])
    end
    
    test = ismember(parameters,obj.parser.parameters);
    if any(~test)
        error([mfilename ':: The following parameters are not defined in the model, and can therefore ',...
                         'not be added a break point: ' toString(parameters(~test))])
    end
    
    % Do we also have permanent shock to some exogenous variables?
    [steady_state_exo,varargin] = nb_parseOneOptional('steady_state_exo',[],varargin{:});
    [expectedDate,varargin]     = nb_parseOneOptional('expectedDate','',varargin{:});
    if ~isempty(expectedDate)
        if ischar(expectedDate)
            expectedDate = nb_date.date2freq(expectedDate);
        elseif ~isa(expectedDate,'nb_date')
            error([mfilename ':: The ''expectedDate'' input must be a string date or a nb_date object.'])
        end
        obj.parser.hasExpectedBreakPoints = true;
    end
    
    % Assign break point for later
    newBreak                  = nb_dsge.createDefaultBreakPointStruct();
    newBreak.parameters       = parameters;
    newBreak.values           = values;
    newBreak.date             = date;
    newBreak.steady_state_exo = steady_state_exo;
    newBreak.expectedDate     = expectedDate;
    
    if obj.estOptions.parser.nBreaks > 0
        
        % Check that the break dates are unique 
        dates = {obj.estOptions.parser.breakPoints.date};
        dates = cellfun(@toString,dates,'uniformOutput',false);
        ind   = strcmp(toString(date),dates);
        if any(ind)
           error([mfilename ':: The added break point cannot happend on the same time as another break (' toString(date) ').'])
        end
        
        % Append
        obj.estOptions.parser.breakPoints = [obj.estOptions.parser.breakPoints,newBreak];
        
    else
        obj.estOptions.parser.breakPoints = newBreak;
    end
    obj.estOptions.parser.nBreaks = obj.estOptions.parser.nBreaks + 1;
    
    % Sort break-points
    if obj.estOptions.parser.nBreaks > 1
        dates       = {obj.estOptions.parser.breakPoints.date};
        dates       = cellfun(@toString,dates,'uniformOutput',false);
        [~,sortInd] = sort(dates);
        obj.estOptions.parser.breakPoints = obj.estOptions.parser.breakPoints(sortInd);
    end
    
    % Optional inputs given to the set method.
    obj = set(obj,varargin{:});
    
    % Indicate the model need to be resolved
    obj = indicateResolve(obj);
    
end
