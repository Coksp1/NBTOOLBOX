function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    f = nb_guiFigure(gui.parent.parent,'Method Selection',[65   15  70   30],'modal','off');
    gui.figureHandle = f;

    % Panel with model selection list
    pwidth = 0.54;
    uip = uipanel(...
      'parent',   f,...
      'title',    'Select Methods',...
      'units',    'normalized',...
      'position', [0.04, 0.04, pwidth, 0.92]);
    
    % List of model types
    if isa(gui.parent.data,'nb_ts')
        methods = {'Add Postfix',...
                   'Add Prefix',...
                   'Append Dataset',...
                   'Arccosine',...
                   'Arccosecant',...
                   'Arccotangent',...
                   'Arcsecant',...
                   'Arcsine',...
                   'Arctangent',...
                   'Assign NaN Values',...
                   'Average (object selection)',...
                   'Average (series selection)',...
                   'Band-Pass Filter',...
                   'Convert',...
                   'Convert to Cell Object',...
                   'Cosine',...
                   'Cosecant',...
                   'Cotangent',...
                   'Create Dummy Variable',...
                   'Create Variable',...
                   'Delete Variables',...
                   'Detrend',...
                   'Divide',...
                   'Easter Dummy',...
                   'Estimate distribution',...
                   'Expand Window',...
                   'Expand By Periods',...
                   'Exponential',...
                   'Extrapolate',...
                   'Fill NaN',...
                   'Growth',...
                   'Growth (%)',...
                   'HP-Filter',...
                   'Interpolate',...
                   'Lag',...
                   'Lead',...
                   'Log',...
                   'Log Difference',...
                   'Log Difference (%)',...
                   'Max',...
                   'Median (object selection)',...
                   'Median (series selection)',...
                   'Merge',...
                   'Min',...
                   'Minus',...
                   'Mode (object selection)',...
                   'Mode (series selection)',...
                   'Moving Average',...
                   'Moving Standard Deviation',...
                   'Multiplication',...
                   'Permute',...
                   'Plus',...
                   'Power',...
                   'Rebase',...
                   'Rename Page',...
                   'Rename Variable',...
                   'Re-order Datasets',...
                   'Re-order Variables',...
                   'Round',...
                   'Secant',...
                   'Smoothened growth',...
                   'Shrink To Last Observations',...
                   'Shrink Sample',...
                   'Sine',...
                   'Sort Datasets',...
                   'Sort Variables',...
                   'Split Sample',...
                   'Split Series',...
                   'Standard deviation (series selection)',...
                   'Standardise',...
                   'Strip',...
                   'Strip but last',...
                   'Subperiod average',...
                   'Subperiod sum',...
                   'Tangent',...
                   'Unit Root',...
                   'Variance (series selection)',...
                   'Window',...
                   'x12 Census'};
    elseif isa(gui.parent.data,'nb_data')
        methods = {'Add Postfix',...
                   'Add Prefix',...
                   'Arccosine',...
                   'Arccosecant',...
                   'Arccotangent',...
                   'Arcsecant',...
                   'Arcsine',...
                   'Arctangent',...
                   'Assign NaN Values',...
                   'Average (object selection)',...
                   'Average (series selection)',...
                   'Band-Pass Filter',...
                   'Convert to Cell Object',...
                   'Cosine',...
                   'Cosecant',...
                   'Cotangent',...
                   'Create Dummy Variable',...
                   'Create Variable',...
                   'Delete Variables',...
                   'Detrend',...
                   'Divide',...
                   'Estimate distribution',...
                   'Expand Window',...
                   'Expand By Periods',...
                   'Exponential',...
                   'Growth',...
                   'Growth (%)',...
                   'HP-Filter',...
                   'Interpolate',...
                   'Lag',...
                   'Lead',...
                   'Log',...
                   'Log Difference',...
                   'Log Difference (%)',...
                   'Max',...
                   'Median (object selection)',...
                   'Median (series selection)',...
                   'Merge',...
                   'Min',...
                   'Minus',...
                   'Mode (object selection)',...
                   'Mode (series selection)',...
                   'Moving Average',...
                   'Moving Standard Deviation',...
                   'Multiplication',...
                   'Permute',...
                   'Plus',...
                   'Power',...
                   'Rebase',...
                   'Rename Page',...
                   'Rename Variable',...
                   'Re-order Datasets',...
                   'Re-order Variables',...
                   'Round',...
                   'Secant',...
                   'Shrink To Last Observations',...
                   'Sine',...
                   'Sort',...
                   'Sort Datasets',...
                   'Sort Variables',...
                   'Standard deviation (series selection)',...
                   'Strip',...
                   'Strip but last',...
                   'Tangent',...
                   'Variance (series selection)',...
                   'Window'};
    elseif isa(gui.parent.data,'nb_cs')
        methods = {'Arccosine',...
                   'Arccosecant',...
                   'Arccotangent',...
                   'Arcsecant',...
                   'Arcsine',...
                   'Arctangent',...
                   'Average (object selection)',...
                   'Average (series selection)',...
                   'Convert to Cell Object',...
                   'Cosine',...
                   'Cosecant',...
                   'Cotangent',...
                   'Create Variable',...
                   'Create Type',...
                   'Divide',...
                   'Delete Variables',...
                   'Delete Types',...
                   'Estimate distribution',...
                   'Exponential',...
                   'Log',...
                   'Max',...
                   'Median (object selection)',...
                   'Median (series selection)',...
                   'Merge',...
                   'Min',...
                   'Minus',...
                   'Mode (object selection)',...
                   'Mode (series selection)',...
                   'Multiplication',...
                   'Permute',...
                   'Plus',...
                   'Power',...
                   'Rename Page',...
                   'Rename Type',...
                   'Rename Variable',...
                   'Re-order Datasets',...
                   'Re-order Variables',...
                   'Re-order Types',...
                   'Round',...
                   'Secant',...
                   'Sine',...
                   'Sort',...
                   'Sort Datasets',...
                   'Sort Variables',...
                   'Sort Types',...
                   'Standard deviation (series selection)',...
                   'Tangent',...
                   'Transpose',...
                   'Variance (series selection)'};
    else
        methods = {'Add Column'...
                   'Add Row',...
                   'Transpose'}; 
    end
    
    gui.listbox = uicontrol(...
                     'units',       'normalized',...
                     'position',    [0.04, 0.02, 0.92, 0.96],...
                     'parent',      uip,...
                     'background',  [1 1 1],...
                     'style',       'listbox',...
                     'string',      methods,...
                     'max',         1); 
            
    % Create help button
    width  = 0.2;
    height = 0.06;
    uicontrol('units',              'normalized',...
              'position',           [(1 + pwidth - width)/2, 0.5, width, height],...
              'parent',             f,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'busyAction',         'cancel',...
              'string',             'Help',...
              'callback',           @gui.methodHelpCallback);              
                 
    % Create ok button
    width  = 0.2;
    height = 0.06;
    uicontrol('units',              'normalized',...
              'position',           [(1 + pwidth - width)/2, 0.4, width, height],...
              'parent',             f,...
              'style',              'pushbutton',...
              'Interruptible',      'off',...
              'busyAction',         'cancel',...
              'string',             'OK',...
              'callback',           @gui.methodSelectCallback); 
          
    % Make it visible
    set(f,'visible','on')

end
