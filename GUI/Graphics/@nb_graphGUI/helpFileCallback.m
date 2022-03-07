function helpFileCallback(gui,~,~) %#ok<INUSD>
% Syntax:
%
% helpFile(gui,uiHandle,event)
%
% Description:
%
% Part of DAG
%
% Opens a nb_helpWindow with useful comments on the file menu.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

arrow = char(hex2dec('2192'));

nb_helpWindow...
    ({'Save and Save as',...
        sprintf(['These should be pretty self-explanatory and works as you would expect.\n',...
        'However, note that saving this graph only saves it in the session file. If you want \n',...
        'to keep the changes for later, remember to save the session file when you close it.']),...
      'Rename',...
        sprintf(['This option renames the figure, the name will be used in the Excel sheet when \n',...
        'exported. The option is not available for advanced graphs as you need to assign \n',...
        'both an English and a Norwegian name in this case. You can rename advanced graphs \n',...
        'under Advanced ', arrow ,' Figure Name.']),...
      'Export',...
        sprintf(['This function exports the graph by itself as opposed to exporting it as a \n',...
        'part of a graph package. Hover over the text to see explanations for the different. \n',...
        'options.']),...
      'Preview',...
      sprintf(['Previews the graph with all text elements displayed. You can also preview all \n',...
      'graphs in a graph package by using the Preview function in the graph package menu. \n',...
      'Only Advanced graphs can be previewed. Keep in mind that once you have opened the \n',...
      'preview, the preview and the underlying graph are comletely separated. You cannot \n',...
      'make permanent changes in the preview window. To get an updated view of the graph \n',...
      'after making changes, you have to close the preview and open a new one.']),...
      'Print, Redraw, Default Size, and Notes',...
        sprintf(['The print function opens the printing menu so that you can print your graph \n',...
        'directly. The redraw functions reloads the graph (you shouldn''t \n',...
        'need to be doing this as it is done automatically when making changes). The default \n',...
        'size function rescales the window back to normal such that the graph appears as it will \n',...
        'when printed. The notes option allows you to make graph-specific notes which you may \n',...
        'find helpful when working with others. These will not be exported.'])});
    
