%% Get help on this example

nb_model_selection_group.help
help nb_model_selection_group.modelSelection

%% Model selction using real-time data

level              = true;
modelVarOfInterest = 'QSA_DPY_YMN';
variables          = {'QSA_DPY_YMN',...
                      'QSA_DPY_PCPIJAE',...
                      'QUA_RNFOLIO'};
if level
    data = nb_ts('realTime_level');
    data = rename(data,'variable','QUA_RFOLIO.NOM','QUA_RNFOLIO');         
    modelVarOfInterest = strcat(modelVarOfInterest,'_GAP');
    variables          = strcat(variables,'_GAP');
else
    data = nb_ts('realTime');         
end

modelGroup = nb_model_selection_group();
modelGroup = set(modelGroup,...
    'data',                 data,...
    'varOfInterest',        'QSA_DPY_YMN',...
    'modelVarOfInterest',   modelVarOfInterest,...
    'real_time_estim',      true,...
    'variables',            variables);
                         
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

if level
transformations = {% Name,  expression,  shift/trend,   description 
%'QSA_DPQ_YMN',        'pcn(QSA_YMN)',    {{'constant',0}},'GDP growth'
'QSA_DPY_YMN_GAP',    'growth(QSA_YMN,4)',    {'avg'}, 'GDP growth'
'QSA_DPY_PCPIJAE_GAP','growth(QSA_PCPIJAE,4)',{'avg'}, 'CPI-ATE inflation'
'QUA_RNFOLIO_GAP',    'QUA_RNFOLIO/100',      {'avg'}, 'Key policy rate'
};
modelGroup = createVariables(modelGroup,transformations,8);
end

%% Assign inverse transformations (shift/trend will be added automatically)
% We also want to forecast the level variables!

if level
reporting = {% Name,  expression,   description                                                                                                                                 'CPI adj. for tax changes and excl. temp. changes in energy prices'
'QSA_DPY_YMN',  'QSA_DPY_YMN_GAP',  'GDP growth'
};
modelGroup = set(modelGroup,'reporting',reporting);
modelGroup = checkReporting(modelGroup);                         
end                       

%% Do model selection

[modelGroups,p] = modelSelection(modelGroup);

% Plot histogram over most selected variables
nb_graphPagesGUI(p);

%% Model combination (point)

for ii = 1:numel(modelGroups)
    
    % Do the combination
    [modelGroups{ii},~,plotter] = combineForecast(modelGroups{ii},...
                            'allPeriods',   1,...
                            'fcstEval',     {'SE'});
                        
    % Plot weights
    nb_graphMultiGUI(plotter);

    % Plot the combined forecast as hairy plot
    plotter = plotForecast(modelGroups{ii},'hairyplot');
    nb_graphSubPlotGUI(plotter); 
    
    % Plot the combined forecast with history
    plotter = plotForecast(modelGroups{ii});
    nb_graphSubPlotGUI(plotter); 
    
    % See the individual forecast
    models  = [modelGroups{ii}.models{:}];
    plotter = plotForecast(models);
    nb_graphSubPlotGUI(plotter);
    
end
