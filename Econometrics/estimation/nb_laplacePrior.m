function prior = nb_laplacePrior(varargin)
% Syntax:
%
% prior = nb_laplacePrior(varargin)
%
% Description:
%
% Uniform prior on constant:
%
% y(i) = I*betaC(i) + X*beta(i) + residual(i), residual(i) ~ N(0,sigma(i)) 
%
% Prior on betaC(i) : Diffuse prior
%
% Laplace prior on constant:
%
% y(i) = [I,X]*[betaC(i);beta(i)] + residual(i), residual(i) ~ N(0,sigma(i))
%
% Prior on betaC(i) : Laplace(0,2*sigma(i)^2/lambda)
%
% For both cases:
%
% Prior on beta(i)  : Laplace(0,2*sigma(i)^2/lambda)
% Prior on sigma(i) : Diffuse prior, which leads to a conditional 
%                     posterior that is InvGamma.
%
% If the prior on lambda is not set, we use a diffuse hyperprior, which
% leads to a conditional posterior that is InvGamma.
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
% nb_laplace
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
    default = {
        'draws',           1000, {@(x)nb_isScalarPositiveNumber(x),'||',@isempty};...
        'burn',            500,  {@(x)nb_isScalarInteger(x,0),'||',@isempty};...
        'lambda',          [],   {@(x)nb_isScalarPositiveNumber(x),'||',@isempty};...
        'constantDiffuse', true, @(x)nb_isScalarLogical(x);...
        'thin',            2,    {@(x)nb_isScalarInteger(x,0),'||',@isempty};...
        
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
        prior = getHelp();
    elseif isempty(varargin) && ~isempty(input)
        prior = getHelp(input); 
    end
    
end

%==========================================================================
function helpText = getHelp(input)

    if nargin < 1
        input = 'all';
    end
    helper   = nb_writeHelp('nb_laplacePrior',input,'','timeSeries');
    helper   = set(helper,'max',40);
    helpText = help(helper);
  
end
