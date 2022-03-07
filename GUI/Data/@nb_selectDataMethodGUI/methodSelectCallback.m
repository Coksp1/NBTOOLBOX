function methodSelectCallback(gui,hObject,~)
% Syntax:
%
% methodSelectCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the method selected
    index  = get(gui.listbox,'Value');
    string = get(gui.listbox,'String');
    method = string{index};
    
    % Close selection window
    close(get(hObject,'parent'));
    
    % Make method GUI
    switch method
        
        case 'Add Column'
            
            methodgui = nb_addToCellGUI(gui.parent.parent,gui.parent.data,'column');
        
        case 'Add Postfix'
            
            methodgui = nb_addStringGUI(gui.parent.parent,gui.parent.data,'postfix');
            
        case 'Add Prefix'
            
            methodgui = nb_addStringGUI(gui.parent.parent,gui.parent.data,'prefix');
            
        case 'Add Row'
            
            methodgui = nb_addToCellGUI(gui.parent.parent,gui.parent.data,'row');    
            
        case 'Append Dataset'
            
            if isempty(gui.parent.dataName)
                name = 'Existing';
            else
                name = gui.parent.dataName;
            end
            
            methodgui = nb_appendDataGUI(gui.parent.parent,gui.parent.data,name);
            
        case 'Arccosine'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'acos');
            
        case 'Arccosecant'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'acsc');
        
        case 'Arccotangent'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'acot');
            
        case 'Arcsecant'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'asec');
        
        case 'Arcsine'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'asin');
        
        case 'Arctangent'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'atan');
            
        case 'Assign NaN Values'
            
            methodgui = nb_nan2varGUI(gui.parent.parent,gui.parent.data);
            
        case 'Average (object selection)'
            
            methodgui = nb_meanGUI(gui.parent.parent,gui.parent.data);
            
        case 'Average (series selection)'
            
            methodgui = nb_statOperatorsGUI(gui.parent.parent,gui.parent.data,'mean');
            
        case 'Band-Pass Filter'
            
            methodgui = nb_bkfilterGUI(gui.parent.parent,gui.parent.data);
            
        case 'Convert'
        
            methodgui = nb_convertDataGUI(gui.parent.parent,gui.parent.data);
            
        case 'Convert to Cell Object'
            
            methodgui = nb_toCellGUI(gui.parent.parent,gui.parent.data);
            
        case 'Cosine'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'cos');
            
        case 'Cosecant'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'csc');
            
        case 'Cotangent'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'cot');
            
        case 'Create Dummy Variable'
            
            methodgui = nb_createDummyGUI(gui.parent.parent,gui.parent.data);
            
        case 'Create Variable'
            
            methodgui = nb_createVariableGUI(gui.parent.parent,gui.parent.data,'variable');
            
        case 'Create Type'
            
            methodgui = nb_createVariableGUI(gui.parent.parent,gui.parent.data,'type');
            
        case 'Delete Variables'
            
            methodgui = nb_deleteVariablesGUI(gui.parent.parent,gui.parent.data,'variables');
           
        case 'Delete Types'
            
            methodgui = nb_deleteVariablesGUI(gui.parent.parent,gui.parent.data,'types');
            
        case 'Detrend'
            
            methodgui = nb_detrendGUI(gui.parent.parent,gui.parent.data);
            
        case 'Divide' 
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'mrdivide');    
            
        case 'Easter Dummy'
              
            methodgui = nb_easterDummyGUI(gui.parent.parent,gui.parent.data);
            
        case 'Estimate distribution'
            
            methodgui = nb_estimateDistGUI(gui.parent.parent,gui.parent.data);  
            
        case 'Expand Window'
            
            methodgui = nb_expandGUI(gui.parent.parent,gui.parent.data);
            
        case 'Expand By Periods'
            
            methodgui = nb_expandPeriodsGUI(gui.parent.parent,gui.parent.data);
        
        case 'Exponential'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'exp');
            
        case 'Extrapolate'    
            
            methodgui = nb_extrapolateGUI(gui.parent.parent,gui.parent.data);
            
        case 'Fill NaN'
            
            methodgui = nb_fillNaNGUI(gui.parent.parent,gui.parent.data);
            
        case 'Growth'
            
            methodgui = nb_growthOperatorsGUI(gui.parent.parent,gui.parent.data,'egrowth');
            
        case 'Growth (%)'
            
            methodgui = nb_growthOperatorsGUI(gui.parent.parent,gui.parent.data,'epcn');     
            
        case 'HP-Filter'
            
            methodgui = nb_hpfilterGUI(gui.parent.parent,gui.parent.data);
            
        case 'Interpolate'
            
            methodgui = nb_interpolateGUI(gui.parent.parent,gui.parent.data);
            
        case 'Lag'
            
            methodgui = nb_timingOperatorsGUI(gui.parent.parent,gui.parent.data,'lag');
            
        case 'Lead'
            
            methodgui = nb_timingOperatorsGUI(gui.parent.parent,gui.parent.data,'lead');
            
        case 'Log'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'log');
            
        case 'Log Difference'
            
            methodgui = nb_growthOperatorsGUI(gui.parent.parent,gui.parent.data,'growth');
            
        case 'Log Difference (%)'
            
            methodgui = nb_growthOperatorsGUI(gui.parent.parent,gui.parent.data,'pcn');    
            
        case 'Max'
            
            methodgui = nb_statOperatorsGUI(gui.parent.parent,gui.parent.data,'max');    
            
        case 'Median (object selection)'
            
            methodgui = nb_meanGUI(gui.parent.parent,gui.parent.data,'median');    
            
        case 'Median (series selection)'
            
            methodgui = nb_statOperatorsGUI(gui.parent.parent,gui.parent.data,'median');    
            
        case 'Merge'
            
            methodgui = nb_mergeDataGUI(gui.parent.parent,gui.parent.data,[],gui.parent.dataName,'');
            
        case 'Min'
            
            methodgui = nb_statOperatorsGUI(gui.parent.parent,gui.parent.data,'min');    
            
        case 'Minus' 
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'minus');    
            
        case 'Mode (object selection)'
            
            methodgui = nb_meanGUI(gui.parent.parent,gui.parent.data,'mode');    
            
        case 'Mode (series selection)'
            
            methodgui = nb_statOperatorsGUI(gui.parent.parent,gui.parent.data,'mode');    
            
        case 'Moving Average'
            
            methodgui = nb_movingOperatorsGUI(gui.parent.parent,gui.parent.data,'mavg'); 
            
        case 'Moving Standard Deviation'
            
            methodgui = nb_movingOperatorsGUI(gui.parent.parent,gui.parent.data,'mstd'); 
            
        case 'Multiplication' 
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'mtimes');
           
        case 'Permute'
            
            methodgui = nb_permuteGUI(gui.parent.parent,gui.parent.data);
            
        case 'Plus' 
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'plus');    
            
        case 'Power' 
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'mpower');
            
        case 'Rebase'
            
            methodgui = nb_reIndexGUI(gui.parent.parent,gui.parent.data); 
            
        case 'Rename Page'
            
            methodgui = nb_renameGUI(gui.parent.parent,gui.parent.data,'dataset');
            
        case 'Rename Type'
            
            methodgui = nb_renameGUI(gui.parent.parent,gui.parent.data,'type');
            
        case 'Re-order Datasets'
                 
            methodgui = nb_reorderPropertyGUI(gui.parent.parent,gui.parent.data,'datasets');
        
        case 'Re-order Variables'
                   
            methodgui = nb_reorderPropertyGUI(gui.parent.parent,gui.parent.data,'variables');
            
        case 'Re-order Types'  
            
            methodgui = nb_reorderPropertyGUI(gui.parent.parent,gui.parent.data,'types');
            
        case 'Round'
            
            methodgui = nb_roundGUI(gui.parent.parent,gui.parent.data);
            
        case 'Rename Variable'
            
            methodgui = nb_renameGUI(gui.parent.parent,gui.parent.data,'variable');
        
        case 'Secant'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'sec');
            
        case 'Smoothened growth'
            
            methodgui = nb_growthOperatorsGUI(gui.parent.parent,gui.parent.data,'sgrowth');
            
        case 'Shrink To Last Observations'
            
            methodgui = nb_lastObservationGUI(gui.parent.parent, gui.parent.data);
          
        case 'Shrink Sample'
            
            methodgui = nb_shrinkSampleGUI(gui.parent.parent, gui.parent.data);    
            
        case 'Sine'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'sin');
            
        case 'Sort'
            
            methodgui = nb_sortGUI(gui.parent.parent,gui.parent.data);    
            
        case 'Sort Datasets'
                 
            methodgui = nb_sortPropertyGUI(gui.parent.parent,gui.parent.data,'datasets');
        
        case 'Sort Variables'
                   
            methodgui = nb_sortPropertyGUI(gui.parent.parent,gui.parent.data,'variables');
            
        case 'Sort Types'  
            
            methodgui = nb_sortPropertyGUI(gui.parent.parent,gui.parent.data,'types');    
            
        case 'Split Sample'
            
            methodgui = nb_splitSampleGUI(gui.parent.parent,gui.parent.data); 
        
        case 'Split Series'
            
            methodgui = nb_splitSeriesGUI(gui.parent.parent,gui.parent.data); 
            
        case 'Standard deviation (series selection)'
            
            methodgui = nb_statOperatorsGUI(gui.parent.parent,gui.parent.data,'std');    
            
        case 'Standardise'
            
            methodgui = nb_stdiseGUI(gui.parent.parent,gui.parent.data);
            
        case 'Strip'
            
            methodgui = nb_stripGUI(gui.parent.parent,gui.parent.data,'strip');
            
        case 'Strip but last'
            
            methodgui = nb_stripGUI(gui.parent.parent,gui.parent.data,'stripButLast');
            
        case 'Subperiod average'
            
            methodgui = nb_subOperatorsGUI(gui.parent.parent,gui.parent.data,'subAvg');
            
        case 'Subperiod sum'
            
            methodgui = nb_subOperatorsGUI(gui.parent.parent,gui.parent.data,'subSum');
            
        case 'Tangent'
            
            methodgui = nb_mathOperatorsGUI(gui.parent.parent,gui.parent.data,'tan');
            
        case 'Transpose'
            
            methodgui = nb_transposeGUI(gui.parent.parent,gui.parent.data);
            
        case 'Unit Root'
            
            methodgui = nb_unitRootGUI(gui.parent.parent,gui.parent.data);
            
        case 'Variance (series selection)'
            
            methodgui = nb_statOperatorsGUI(gui.parent.parent,gui.parent.data,'var');    
            
        case 'Window'
            
            methodgui = nb_windowGUI(gui.parent.parent,gui.parent.data);
            
        case 'x12 Census'
            
            methodgui = nb_x12CensusGUI(gui.parent.parent,gui.parent.data);
            
    end
    
    % Add a listener to the nb_methodGUI object, will update the data
    % of the spreadsheet and create a backup
    spreadsheetgui = gui.parent;
    addlistener(methodgui,'methodFinished',@spreadsheetgui.updateDataCallback);
    
end
