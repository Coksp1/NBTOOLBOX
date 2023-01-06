function prior = nb_nwhishartPrior(varargin)
% Syntax:
%
% prior = nb_nwhishartPrior(varargin)
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
% Prior on beta  : N(A_prior,V_prior)
% Prior on sigma : IW(S_prior,v_prior) 
% 
% - A_prior : A scalar double (automatically expanded) or a double with 
%             size N x Q
% - V_prior : A scalar double (automatically expanded) or a double with 
%             size (N x Q) x 1 or (N x Q) x (N x Q).
% - S_prior : A scalar double (automatically expanded) or a double with 
%             size Q x 1.
% - v_prior : A scalar double.
%
% Optionsl input:
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
% nb_nwhishart
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
    default = {'A_prior',           [],       {@(x)isnumeric(x),'||',@isempty};...
               'V_prior',           [],       {@(x)isnumeric(x),'||',@isempty};...
               'S_prior',           [],       {@(x)isnumeric(x),'||',@isempty};...
               'v_prior',           [],       {@(x)isnumeric(x),'||',@isempty};...
               'draws',             [],       {@(x)nb_isScalarPositiveNumber(x),'||',@isempty};...
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
function help = A_prior() %#ok<DEFNU>
    help = 'Mean of the prior on beta, i.e. A_prior of the prior N(A_prior,V_prior). N is the normal distribution.';
end

%==========================================================================
function help = V_prior() %#ok<DEFNU>
    help = 'Covariance of the prior on beta, i.e. V_prior of the prior N(A_prior,V_prior). N is the normal distribution.';
end

%==========================================================================
function help = S_prior() %#ok<DEFNU>
    help = 'The main prior on sigma, i.e. S_prior of the prior IW(S_prior,v_prior). IW is the inverse whishart distribution.';
end

%==========================================================================
function help = v_prior() %#ok<DEFNU>
    help = 'The degree of freedom of the prior on sigma, i.e. v_prior of the prior IW(S_prior,v_prior). IW is the inverse whishart distribution.';
end

%==========================================================================
function help = draws() %#ok<DEFNU>
    help = 'Number of draws to simulate from the posterior distribution. If set to 1, the posterior mode is returned.';
end
