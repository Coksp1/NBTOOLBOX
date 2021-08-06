function save2Separate(gui,~,~,language,format,includeFigureNumber,singleFolder)
% Syntax:
%
% save2Separate(gui,hObject,event,language,format,includeFigureNumber)
%
% Description:
%
% Part of DAG. Save package to PDF
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 7
        singleFolder = false;
    end

    if isempty(gui.package.graphs)
        nb_errorWindow(['The graph package is empty and cannot be saved to ' upper(format) 's.'])
        return
    end
    
     % Get the file name
    pathname = uigetdir(nb_getLastFolder(gui));
    
    if isscalar(pathname)
        nb_errorWindow('Invalid save name selected.')
        return
    end
    nb_setLastFolder(gui,pathname);
    
    % Select the graphs to export in a GUI
    makeGUI(gui,pathname,language,format,includeFigureNumber,singleFolder);

end

%==========================================================================
function makeGUI(gui,pathname,language,format,includeFigureNumber,singleFolder)

    % Create the main window
    name  = 'Select graphs';
    fig   = nb_guiFigure(gui.parent,name,[40   15  85.5   31.5],'modal');  
    grid  = nb_gridcontainer(fig,'gridSize',[2,1],'verticalWeight',[0.9,0.1]);
    vals  = 1:size(gui.package.identifiers,2);
    pop   = uicontrol(grid,nb_constant.LISTBOX,...
              'string',   gui.package.identifiers,...
              'value',    vals,...
              'max',      2); 
    gridB = nb_gridcontainer(grid,'gridSize',[1,2]);
    uicontrol(gridB,nb_constant.BUTTON,...
              'string',   'Select all',...
              'callback', @(h,e)selectAll(h,e,pop,vals)); 
    uicontrol(gridB,nb_constant.BUTTON,...
              'string',   ['Write ' upper(format) 's'],...
              'callback', @(h,e)writeFiles(h,e,gui,pathname,language,format,includeFigureNumber,singleFolder,pop));
          
    % Make GUI visible 
    set(fig,'visible','on');
          
end

%==========================================================================
function selectAll(~,~,pop,vals)
    set(pop,'value',vals);
end

%==========================================================================
function writeFiles(hObject,~,gui,pathname,language,format,includeFigureNumber,singleFolder,pop)
% Write the package to files

    % Write files
    ind        = get(pop,'value');
    index      = false(1,size(gui.package.identifiers,2));
    index(ind) = true;

    % Delete selection GUI
    delete(nb_getParentRecursively(hObject));

    try
        if strcmpi(format,'txt')
            gui.package.writeText(pathname,language,index,includeFigureNumber,singleFolder);
        elseif strcmpi(format,'pdfext')
             gui.package.writeSeparateExtended(pathname,language,'pdf',index,1,includeFigureNumber);
        else
            % In this case, we want to force the user to choose the template to use for writing.
            f = @()gui.package.writeSeparate(pathname,language,format,index,1,gui.template,includeFigureNumber);
            chooseTemplateWindow(gui,f);
        end
    catch Err
       nb_errorWindow(['Could not write ' upper(format) 's.'], Err) 
    end

end

