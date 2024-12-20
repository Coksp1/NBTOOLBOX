function helpAdvancedMenuCallback(~,~) 
% Syntax:
%
% nb_graph_adv.helpAdvancedMenuCallback(uiHandle,event)
%
% Description:
%
% Part of DAG
%
% Opens a nb_helpWindow with useful comments on the advanced graph menu.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    arrow = char(hex2dec('2192'));

    nb_helpWindow...
        ({'Figure Name, Figure Title, and Footer',...
        sprintf(['The figure name setting sets the Norwegian and the English name for the figure. \n',...
        'These will be used in the Excel data sheet when exported. The figure title sets the English \n',...
        'and Norwegian title. Use the wrap option if you want DAG to take care of when to start a \n',...
        'new line. This can also be done manually by ending the current line and starting to write a \n',...
        'new one. Figure numbering at the start of the title is taken care of automatically and does \n',...
        'not need to be done in the title/name. If you do want to make changes to the numbering \n',...
        'you can do so in the Advanced ',arrow,' Numbering menu (graph specific) or under the \n',...
        'Properties menu of a graph package. The footer option operates like the figure title menu \n',...
        'with the wrap option and so forth.']),...
        'Excel Footer',...
        sprintf(['The excel footer sets the "footer" to be used in the Excel data sheet. You may want to \n',...
        'do this if your original footer directly comments on the graph, which would not make \n',...
        'sense without the graph in front of you. If the excel footer is left empty, the (regular) \n',...
        'footer will be used in the Excel data sheet as well.']),...
        'Remove',...
        sprintf(['The remove option allow you to exclude variables from the exported Excel sheet. \n',...
        'This is typically done when there are sensitive data series used to make the graph which \n',...
        'cannot be published.']),...
        'Numbering',...
        sprintf(['Numbering sets different properties for how the graph should be counted when included \n',...
        'in a graph package. Hover over the text to see a tooltip with short explanations for the \n',...
        'different options available.']),...
        'Round-off',...
        sprintf(['The round-off option allow you to set graph-specific instructions for how to round off \n',...
        'the data in the exported Excel sheet. If this is left empty, the data will be rounded \n',...
        'according to the round-off setting in the graph package. If you open a graph package this \n',...
        'setting is under the Properties menu.']),...
        'Forecast date',...
        sprintf(['This will color the cells in the Excel data sheet blue after (and including) the date indicated \n',...
        'in the settings. Usually used for visually separating historical data from projections.']),...
        'Default figure numbering',...
        sprintf(['When checked, the graph title will have the "Chart 1.1" prefix in the previewer, uncheck to \n',...
        'remove it. When the graph is included in a graph package, the correct numbering will \n',...
        'in any case be used in addition in the previewer. This option is not used for changing the \n',...
        'numbering of the graph in exported PDF. If you want to do that, use the numbering setting \n',...
        'above or the numbering settings in the graph package.'])});

end
