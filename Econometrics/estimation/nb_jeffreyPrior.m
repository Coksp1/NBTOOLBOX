function prior = nb_jeffreyPrior(varargin)
% Syntax:
%
% prior = nb_jeffreyPrior(varargin)
%
% Description:
%
% Set the priors of the type:
% 
% y = X*beta + residual, residual ~ N(0,sigma) (1)
%
% y has size T x Q
% X has size T x N
%
% Prior on beta  : Diffuse
% Prior on sigma : Diffuse
%
% Optional input:
% 
% - Run without inputs to get default priors.
%
% - Run with 'list' as the first input to get a cellstr with the supported
%   prior options.
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
% nb_jeffrey
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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

    % Parse inputs
    default = {'draws',             [],       {@(x)nb_isScalarPositiveNumber(x),'||',@isempty};...
               };
    
    [prior,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end       
          
    % Return wanted output
    fields = fieldnames(prior);
    if strcmpi(input,'list')
        prior = fields;
    elseif strcmpi(input,'help')
        prior = getHelp(prior);
    elseif isempty(varargin) && ~isempty(input)
        prior = getHelp(prior,input); 
    end
    
end

%==========================================================================
function helpText = getHelp(options,input)

    fields = fieldnames(options);
    if nargin == 2
        ind      = strcmpi(input,fields);
        helpFunc = str2func(fields{ind});
        helpText = helpFunc();
    else
        helpText    = '';
        helpOptions = '';
        fields      = sort(fields);
        for ii = 1:length(fields)
            helpFunc    = str2func(fields{ii});
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
function help = draws() %#ok<DEFNU>
    help = 'Number of draws to simulate from the posterior distribution. If set to 1, the posterior mode is returned.';
end
