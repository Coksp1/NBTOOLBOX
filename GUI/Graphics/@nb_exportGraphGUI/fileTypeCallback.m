function fileTypeCallback(gui,hObject,~)
% Syntax:
%
% fileTypeCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected file type
    string   = get(hObject,'string');
    index    = get(hObject,'value');
    selected = string{index};
    
    switch selected
        
        case 'Portable document format (*.pdf)'
            newExt = '.pdf';
        case 'Enhanced metafile (*.emf)'
            newExt = '.emf';
        case 'Portable network format (*.png)'
            newExt = '.png';
        case 'Encapsulated postscript (*.eps)'
            newExt = '.eps';
        case 'Joint Photographic Group (*.jpg)'
            newExt = '.jpg';
        case 'Scalable Vector Graphics (*.svg)'
            newExt = '.svg';
        case 'MATLAB Object (*.mat)'
            newExt = '.mat';
        case 'MATLAB Script (*.m)'
            newExt = '.m';
        case 'MATLAB fig file (*.fig)'
            newExt = '.fig';
        otherwise
            error([mfilename ':: It should be impossible to select a non-existing file type.'])
    end
    
    % Get the selected file name
    string = get(gui.edit1,'string');
    if ~isempty(string)
        [~, ~, ext] = fileparts(string);
        if ~isempty(ext)
            string = strrep(string,ext,newExt);
            set(gui.edit1,'string',string);
        end
    end
    
    % Enable/disable options dependent on file type (crop and 
    % append)
    if strcmpi(newExt,'.pdf')
        set(gui.rb2,'enable','on');
        set(gui.rb3,'enable','on');
        set(gui.rb4,'enable','on');
    else
        set(gui.rb2,'enable','off');
        set(gui.rb3,'enable','off');
        set(gui.rb4,'enable','off');
    end
    if strcmpi(newExt,'.emf')
        set(gui.rb5,'enable','on');
    else
        set(gui.rb5,'enable','off');
    end
    
end
