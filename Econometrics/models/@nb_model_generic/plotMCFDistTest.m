function plotter = plotMCFDistTest(paramD,params,values,test)
% Syntax:
%
% plotter = nb_model_generic.plotMCFDistTest(paramD,params,values,test)
%
% Description:
%
% Split parameter sets from monte carlo filtering into two pools of sets, 
% one for the parameter sets that lead to success, and the other for those 
% that did not. Then for each pool the CDF of each parameter is comapred in
% graph. In the title the p-value of the selected test is provided.
% 
% Input:
% 
% - paramD : A draws x N double with the parameter draws. E.g. use
%            paramD(success,:) from the output of the 
%            monteCarloFiltering method. N is the number of parameters.
% 
% - params : A 1 x N cellstr with the names of the parameters.
%
% - values : A draws x 1 double with the values of the monte carlo 
%            filtering.
%
% - test   : Name of the test to apply. Either 'smirnov' or 'cucconi' 
%            (default). Must be a one line char. 
%
% Output:
% 
% - plotter : A vector of nb_graph_data objects with size 1 x N. Use the 
%             graph method or the nb_graphMultiGUI class to produce the 
%             graphs.
%
% See also:
% nb_model_generic.monteCarloFiltering, nb_cucconiTest, nb_smirnovTest
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        test = 'Cucconi';
    end

    if ~islogical(values) || ~isvector(values)
        error('The values input must be logical array')
    end
    values = values(:);
    if size(values,1) ~= size(paramD,1)
        error('The values input must have as many elements as the paramD input has rows.');
    end
    if ~iscellstr(params)
        error('The params input must be a cellstr.')
    end
    params = nb_rowVector(params);
    if size(params,2) ~= size(paramD,2)
        error('The params input must have as many elements, as the paramD input has columns.')
    end
    if ~nb_isOneLineChar(test)
        error('The test input must be a one line char.')
    end
    
    numPar            = size(paramD,2);
    plotter(1,numPar) = nb_graph_data();
    for ii = 1:numPar
        
        % Classify the parameters into two groups, sucess and no sucess
        % groups
        successParam   = paramD(values,ii);
        distrSuccess   = nb_distribution.mle(successParam,'uniform');
        noSuccessParam = paramD(~values,ii);
        distrNoSuccess = nb_distribution.mle(noSuccessParam,'uniform');
        
        % Get the distributions
        data = asData([distrSuccess,distrNoSuccess],[], 'cdf');
        
        
        % Do the Cucconi
        if size(successParam,1) < 10 || size(noSuccessParam,1) < 10
            pValueStr = ' Not valid'; 
        else
            if strcmpi(test,'cucconi')
                [~,pValue] = nb_cucconiTest(successParam,noSuccessParam);
                pValueStr  = num2str(pValue);
            elseif strcmpi(test,'smirnov')
                F_1        = double(window(data,'','',{distrNoSuccess.name}));
                F_2        = double(window(data,'','',{distrSuccess.name}));
                [~,pValue] = nb_smirnovTest(F_1,F_2,size(noSuccessParam,1),size(successParam,1));
                pValueStr  = num2str(pValue);
            else
                error(['The test input cannot be set to ''' test '''.'])
            end
        end
        
        % Plot the two distributions
        data        = rename(data,'variable',distrNoSuccess.name,'No success');
        data        = rename(data,'variable',distrSuccess.name,'Success');
        vars        = data.variables;
        ind         = strcmp(vars,'domain');
        vars        = vars(~ind);
        plotter(ii) = nb_graph_data(data);
        plotter(ii).set(...
            'title',[test, ' p-value: ' pValueStr],...
            'variableToPlotX','domain',...
            'variablesToPlot',vars);

    end
        
    
end
