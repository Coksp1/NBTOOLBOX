function plotter = graphCorrelation(variable,movingVar,varargin)
% Syntax:
%
% plotter = nb_model_generic.graphCorrelation(variable,movingVar,...
%                   c,cEmp,ac1,ac1Emp,ac2,ac2Emp,...)
%
% Description:
%
% Graph model correlations against emprirical.
% 
% Input:
%
% - variable  : The main variable, as a string. 
%
% - movingVar : A cellstr or char with the variables to plot the 
%               covariance/correlations with the main variable.
%
% Optional input:
% 
% - 'fan' : true or false. Give true to make shaded areas between the 
%           
%
% - The first input must be the c output from
%   nb_model_generic.simulatedMoments (SIM) or 
%   nb_model_generic.theoreticalMoments (THEO), the second input must be 
%   the c output from nb_model_generic.empiricalMoments (EMP), the third 
%   input can be the ac1 output from SIM or THEO, the fourth input can be
%   the ac1 output from EMP, and so on.
%
%   Caution : The inputs must be given as nb_cs objects.
%
%   Caution : Inputs must come in pairs.
% 
% Output:
% 
% - plotter : An object of class nb_graph_cs. Use the graph method or the 
%             nb_graphPagesGUI class.
%
% See also:
% nb_model_generic.simulatedMoments, nb_model_generic.theoreticalMoments,
% nb_model_generic.empiricalMoments, nb_graphPagesGUI, nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        error([mfilename ':: The number of variable number of arguments in must at least be 2'])
    end
    if rem(nargin-2,2) ~= 0
        error([mfilename ':: The variable number of arguments in must come in pairs.'])
    end
    if any(~cellfun(@(x)isa(x,'nb_cs'),varargin))
        error([mfilename ':: All optional inputs must be nb_cs objects.'])
    end
    if ~nb_isOneLineChar(variable)
        error([mfilename ':: The variable input must be a one line char.'])
    end
    if ischar(movingVar)
        movingVar = cellstr(movingVar);
    elseif ~iscellstr(movingVar)
        error([mfilename ':: The movingVar input must either be a cellstr or char.'])
    end

    % Collect data for graphing
    numVars = length(movingVar);
    numLags = (nargin - 2)/2;
    numPerc = varargin{1}.numberOfDatasets + 1;
    cData   = nan(numLags*2-1,numPerc,numVars);
    for vv = 1:numVars
        % Lags and contemporary
        for ii = 1:numLags
            cData(numLags-ii+1,2:end,vv) = permute(getVariable(varargin{ii*2-1},movingVar{vv},variable),[2,3,1]);
            cData(numLags-ii+1,1,vv)     = permute(getVariable(varargin{ii*2},movingVar{vv},variable),[2,3,1]);
        end
        % Leads
        kk = numLags + 1;
        for ii = 2:numLags
            cData(kk,2:end,vv) = permute(getVariable(varargin{ii*2-1},variable,movingVar{vv}),[2,3,1]);
            cData(kk,1,vv)     = permute(getVariable(varargin{ii*2},variable,movingVar{vv}),[2,3,1]);
            kk                 = kk + 1;
        end
    end
    
    % Make the names of the types
    corrNames = cell(1,numLags*2 - 1);
    for ii = 1:numLags-1
        corrNames{numLags-ii} = ['-' int2str(ii)];
        corrNames{numLags+ii} = ['+' int2str(ii) ];
    end
    corrNames{numLags} = '0';
    
    % Mae it into a nb_cs object
    vars = [{'Empirical'},varargin{1}.dataNames];
    data = nb_cs(cData,movingVar,corrNames,vars);
    
    % Get colors
    colors          = cell(1,length(vars)*2);
    colors(1:2:end) = vars;
    colors{2}       = 'black';
    colors(4:2:end) = repmat({'blue'},[1,length(vars)-1]);
    
    % Line styles
    if rem(varargin{1}.numberOfDatasets,2) ~= 0
        numP                = floor(varargin{1}.numberOfDatasets/2);
        dashedVar           = [varargin{1}.dataNames(1:numP),varargin{1}.dataNames(numP+2:end)];
        lineStyles          = repmat({'--'},[1,length(dashedVar)*2]);
        lineStyles(1:2:end) = dashedVar;
    else
        lineStyles = {};
    end
    
    % Make nb_graph_cs object
    plotter = nb_graph_cs(data);
    plotter.set('colors',colors,'lineStyles',lineStyles,'noTitle',2,...
                'yLabel',variable);%strrep(variable,'_','\_')
    
    
end
