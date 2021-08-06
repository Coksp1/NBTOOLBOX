function options = optimset(varargin)
% Syntax:
%
% options = nb_lasso.optimset(varargin)
%
% Description:
%
% Get optimization settings or help for use by the nb_lasso function.
% 
% Optional input:
% 
% - Run without inputs to get defaults.
%
% - Run with 'list' as the first input to get a cellstr with the supported
%   options.
%
% - Run with 'help' to get a char with help on each option.
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
% nb_lasso
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    input = '';
    if length(varargin) == 1
        input    = varargin{1};
        varargin = {};
    elseif length(varargin) == 2
        if strcmpi(varargin{1},'help')
            input    = varargin{2};
            varargin = {};
        end
    end

    % Parse inputs1
    displayer = nb_optimizerDisplayer(...
        'storeMax',     2,...
        'notifyStep',   10,...
        'type',         'command',...
        'includeStop',  false,...
        'includeTime',  false);
    
    default = {'display',           'off',                   {@nb_ismemberi,{'final','iter','off','notify'}};...
               'displayer',         displayer,               {@isa,'nb_optimizerDisplayer'};...
               'maxIter',           10000,                   @(x)nb_isScalarInteger(x,0);...
               'mode',              0,                       @(x)ismember(x,[0,1]);...
               ...'tolerance',         1e-5,                    @nb_isScalarPositiveNumber;...
               'threshold',         1e-4,                    @nb_isScalarPositiveNumber;...
               'beta0',             [],                      @(x)isnumeric(x);...
               };
    
    [options,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end       
          
    % Return wanted output 
    if strcmpi(input,'list')
        fields  = fieldnames(options);
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
        helpFunc = str2func(['nb_lasso.' fields{ind}]);
        helpText = helpFunc();
    else
        helpText    = '';
        helpOptions = '';
        fields      = sort(fields);
        for ii = 1:length(fields)
            helpFunc    = str2func(['nb_lasso.' fields{ii}]);
            helpTemp    = helpFunc();
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

%==========================================================================

        
