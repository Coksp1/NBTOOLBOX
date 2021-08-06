function options = optimset(varargin)
% Syntax:
%
% options = nb_abcSolve.optimset(varargin)
%
% Description:
%
% Get solving settings or help.
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
% nb_abcSolve.options
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
        'formatDone',   'Quit solving: f(x): %1$20.6f   num: %3$4d\n',...
        'formatIter',   'Iter: %1$13d  f(x): %2$20.6f   num: %4$4d\n',...
        'storeMax',     2,...
        'notifyStep',   10,...
        'type',         'command',...
        'includeStop',  true,...
        'includeTime',  true);
    
    default = {'cutLimit',          20,                      @(x)nb_isScalarInteger(x,0);...
               'display',           'iter',                  {@nb_ismemberi,{'final','iter','off','notify'}};...
               'displayer',         displayer,               {@isa,'nb_optimizerDisplayer'};...
               'employedShare',     0.33,                    {@nb_isScalarNumber,'&&',{@ge,0.1},'&&',{@le,0.9}};...
               'fitnessFunc',       @nb_fitness.standard,    @(x)isa(x,'function_handle');...
               'fitnessScale',      1,                       @nb_isScalarPositiveNumber;...
               'jacobianFunction',  [],                      @(x)isa(x,'function_handle');...
               'local',             false,                   @nb_isScalarLogical;... 
               'maxFunEvals',       inf,                     @(x)nb_isScalarInteger(x,0);...
               'maxIter',           inf,                     @(x)nb_isScalarInteger(x,0);...
               'maxNodes',          20,                      @(x)nb_isScalarInteger(x,0);...
               'maxSolutions',      20,                      @(x)nb_isScalarInteger(x,0);...
               'maxTime',           60,                      @nb_isScalarPositiveNumber;...
               'maxTimeSinceUpdate',inf,                     @nb_isScalarPositiveNumber;...   
               'maxTrials',         100,                     @(x)nb_isScalarInteger(x,0);...
               'meritFunction',     @(x)norm(x,2),           @(x)isa(x,'function_handle');...
               'minSolutions',      1,                       @(x)nb_isScalarInteger(x,0);...
               'newtonShare',       0.1                      {@nb_isScalarNumber,'&&',{@ge,0},'&&',{@le,1}};...
               'newtonStop',        false,                   @nb_isScalarLogical;...
               'numWorkers',        [],                      {@nb_isScalarPositiveNumber,'||',@isempty};...
               'objectiveLimit',    1e9,                     @nb_isScalarNumber;...
               'tolerance',         1e-7,                    @nb_isScalarPositiveNumber;...
               'toleranceX',        1e-3,                    @nb_isScalarPositiveNumber;...
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
        helpText = help(['nb_abcSolve.' fields{ind}]);
    else
        helpText    = '';
        helpOptions = '';
        fields      = sort(fields);
        for ii = 1:length(fields)
            helpTemp    = help(['nb_abcSolve.' fields{ii}]);
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
        
