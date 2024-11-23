function makeGUI(gui)
% Syntax:
%
% makeGUI(gui)
%
% Description:
%
% Part of DAG. Make GUI window  
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    f = nb_guiFigure(gui.parent,'Convert Frequency',[65   15  70   25],'modal','off');
    
    xSpace  = 0.08;
    widthT  = 1 - xSpace*2;
    heightT = 0.07;
    height  = 0.09;

    uicontrol('units',                  'normalized',...
              'position',               [xSpace, 0.9, widthT, heightT],...
              'parent',                 f,...
              'style',                  'text',...
              'string',                 'Select Frequency',...
              'horizontalAlignment',    'left'); 

    if ~isempty(gui.forceFreq)

        switch gui.forceFreq
            case 1
                frequencies = {'Yearly'};
            case 2
                frequencies = {'Semiannually'};
            case 4
                frequencies = {'Quarterly'};
            case 12
                frequencies = {'Monthly'};
            case 52
                frequencies = {'Weekly'};
            case 365
                frequencies = {'Daily'};
        end

    else
        frequencies = {'Yearly','Semiannually','Quarterly','Monthly','Weekly','Daily'};
    end

    gui.list1 = uicontrol('units',       'normalized',...
                         'position',    [xSpace, 0.82, widthT, height],...
                         'parent',      f,...
                         'background',  [1 1 1],...
                         'style',       'popupmenu',...
                         'string',      frequencies,...
                         'max',         1,...
                         'callback',    @gui.selectFrequency);        

    uicontrol('units',                  'normalized',...
              'position',               [xSpace, 0.7, widthT, heightT],...
              'parent',                 f,...
              'style',                  'text',...
              'string',                 'Method',...
              'horizontalAlignment',    'left');


    methods = {'Average',...
               'Sum',...
               'Last',...
               'First',...
               'Min',...
               'Max'};

    gui.list2 = uicontrol('units',       'normalized',...
                         'position',    [xSpace, 0.62, widthT, height],...
                         'parent',      f,...
                         'background',  [1 1 1],...
                         'style',       'popupmenu',...
                         'string',      methods,...
                         'enable',      'on');           

    gui.radio1 = uicontrol('units',       'normalized',...
                           'position',    [xSpace, 0.48, widthT, height],...
                           'parent',      f,...
                           'string',      'Include Partial Periods',...
                           'style',       'radiobutton',...
                           'value',       0,...
                           'enable',      'on'); 

    gui.radio2 = uicontrol('units',       'normalized',...
                           'position',    [xSpace, 0.30, widthT, height],...
                           'parent',      f,...
                           'string',      'Rename Prefix (E.g. QSA to MSA)',...
                           'style',       'radiobutton',...
                           'value',       1,...
                           'enable',      'on'); 

    widthB  = 0.2;
    heightB = 0.07;                   
    gui.button = uicontrol('units',       'normalized',...
                           'position',    [(1 - widthB)/2, (0.26 - heightB)/2, widthB, heightB],...
                           'parent',      f,...
                           'string',      'Convert',...
                           'style',       'pushbutton',...
                           'enable',      'on',...
                           'callback',    @gui.convertData);                   

    % If the forceFreq property is given the user cannot
    % choose the frequency.
    if ~isempty(gui.forceFreq)

        set(gui.list1,'enable','off');

        if gui.data.frequency < gui.forceFreq

            methods = {'Linear - match last',...
                       'Linear - match first',...
                       'Cubic - match last',...
                       'Cubic - match first',...
                       'None - match last',...
                       'None - match first',...
                       'Fill - match last',...
                       'Fill - match first'};
        else

            methods = {'Average',...
                       'Sum',...
                       'Last',...
                       'First',...
                       'Min',...
                       'Max'};

        end

        set(gui.list2,'string',methods);

    end    

    % Make it visible
    set(f,'visible','on')

end
