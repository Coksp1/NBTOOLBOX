%% Get help on this example

nb_model_selection_group.help
help nb_model_selection_group.modelSelection

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [0.5;0.5;0.5];  
sim     = nb_ts.simulate('1990Q1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);
data    = igrowth(sim/100 + 0.01,ones(1,3)*100);

%nb_graphSubPlotGUI(data);

%% Add trailing NaNs

data = data.setValue('VAR2',nan,data.endDate,data.endDate);

%% Model selection (point)

modelGroup = nb_model_selection_group();
modelGroup = set(modelGroup,...
    'data',                 data,...
    'missingMethod',        'forecast',...
    'varOfInterest',        'G_VAR1',...
    'modelVarOfInterest',   'G_VAR1_GAP',...
    'variables',            {'G_VAR2_GAP',...
                             'G_VAR3_GAP'});

%% Do transformations (To store shift/trend)
%
% When producing point forecast transformations of variables may be done
% after the forecast has been produced, but for density forecast it is
% important to do the transformation before for example calculating
% percentiles (for non-linear expressions)
%
% If the forecast should be evaluated based on some transformation
% of variables it is also important to do them in code, at least it is 
% much easier then write your own code for it! (Both point and density)

transformations = {% Name,  expression,  shift/trend,   description 
'G_VAR1_GAP',    'pcn(VAR1)',    {'avg'}, '% growth gap'
'G_VAR2_GAP',    'pcn(VAR2)',    {'avg'}, '% growth gap'
'G_VAR3_GAP',    'pcn(VAR3)',    {'avg'}, '% growth gap'
};

modelGroup = createVariables(modelGroup,transformations,8);

%% Assign inverse transformations (shift/trend will be added automatically)
% We also want to forecast the level variables!

reporting = {% Name,  expression,   description                                                                                                                                 'CPI adj. for tax changes and excl. temp. changes in energy prices'
'G_VAR1',  'G_VAR1_GAP', '% growth'
};
modelGroup = set(modelGroup,'reporting',reporting);
modelGroup = checkReporting(modelGroup);

%% Do model selection

[modelGroups,p] = modelSelection(modelGroup);

% Plot histogram over most selected variables
nb_graphPagesGUI(p);

%% Model combination (point)

for ii = 1:numel(modelGroups)
    
    % Do the combination
    [modelGroups{ii},~,plotter] = combineForecast(modelGroups{ii},...
                            'allPeriods',   1,...
                            'fcstEval',     {'SE'},...
                            'varOfInterest','G_VAR1');
    % Plot weights
    nb_graphMultiGUI(plotter);

    % Plot the combined forecast with history
    plotter = plotForecast(modelGroups{ii});
    nb_graphSubPlotGUI(plotter); 
    
    % See the individual forecast
    models  = [modelGroups{ii}.models{:}];
    plotter = plotForecast(models);
    nb_graphSubPlotGUI(plotter);
    
end
