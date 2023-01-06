function options = optimset(varargin)
% Syntax:
%
% options = nb_solve.optimset(varargin)
%
% Description:
%
% Get solution options or help.
% 
% Optional input:
% 
% - Run without inputs to get defaults.
%
% - Run with 'list' as the first input to get a cellstr with the supported
%   options.
%
% - Run with 'help' to get a struct with help on each option.
%
% - Run with 'optionName' to get help on a particular option, i.e. only 
%   one input. 
%
% - Use 'optionName', optionValue pairs to set options of the returned
%   struct.
% 
% Output:
% 
% - Depends on the input.
%
% See also:
% nb_abc.options
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    input = '';
    if length(varargin) == 1
        input    = varargin{1};
        varargin = {};
    elseif length(varargin) == 2
        if strcmpi(varargin{1},'help')
            input = varargin{2};
        end
        varargin = {};
    end

    % Parse inputs1
    displayer = nb_optimizerDisplayer(...
        'storeMax',     2,...
        'notifyStep',   10,...
        'type',         'command',...
        'includeStop',  true,...
        'includeTime',  true);
    
    default = {'alphaMethod',       2,                       @(x)nb_isScalarInteger(x,0);...
               'criteria',          'function',              {@nb_ismemberi,{'function','stepsize'}};...
               'display',           'iter',                  {@nb_ismemberi,{'final','iter','off','notify'}};...
               'displayer',         displayer,               {@isa,'nb_optimizerDisplayer'};...
               'gamma',             1e-4,                    @nb_isScalarPositiveNumber;...
               'memory',            10,                      @(x)nb_isScalarInteger(x,0);...
               'maxFunEvals',       inf,                     @nb_isScalarPositiveNumber;...
               'maxIter',           10000,                   @nb_isScalarPositiveNumber;...
               'maxIterSinceUpdate',500,                     @nb_isScalarPositiveNumber;...
               'maxTime',           inf,                     @nb_isScalarPositiveNumber;...   
               'meritFunction',     @(x)norm(x,1),           @(x)isa(x,'function_handle');...
               'method',            'broyden',               {@nb_ismemberi,nb_solve.getMethods()};...    
               'numWorkers',        [],                      {@nb_isScalarPositiveNumber,'||',@isempty};...
               'stepLength'         1e-7,                    @nb_isScalarPositiveNumber;...
               'tolerance',         1e-7,                    @nb_isScalarPositiveNumber;...
               'useParallel',       false,                   {{@ismember,[true,false]}}};
    
    [options,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end       
          
    % Return wanted output
    fields = fieldnames(options);
    if strcmpi(input,'list')
        options = fields;
    elseif strcmpi(input,'help')
        options = getHelp(options);
    elseif isempty(varargin) && ~isempty(input)
        options = getHelp(options,input); 
    end
    
end

%==========================================================================
function helpText = getHelp(options,input)

    fields = fieldnames(options);
    if nargin == 2
        ind      = strcmpi(input,fields);
        helpText = help(['nb_abc.' fields{ind}]);
    else
        helpText    = '';
        helpOptions = '';
        fields      = sort(fields);
        for ii = 1:length(fields)
            helpTemp    = help(['nb_solve.' fields{ii}]);
            helpTemp    = regexprep(helpTemp,'[\n\r]','');
            helpTemp    = nb_wrapped(helpTemp,40);
            nLines      = size(helpTemp,1);
            extra       = repmat({''},nLines,1); 
            helpText    = char(helpText,helpTemp{:},'');
            helpOptions = char(helpOptions,['- ' fields{ii}],extra{:});
        end
        colon    = ' : ';
        colon    = colon(ones(1,size(helpText,1)),:);
        helpText = [helpOptions,colon,helpText];
    end
    
end
