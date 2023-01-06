function setProperties(gui,hObject,~,type)
% Syntax:
%
% setProperties(gui,hObject,event,type)
%
% Description:
%
% Part of DAG. Callback function for setting the properties
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    plotterAdv = gui.plotter;
    if isa(plotterAdv.plotter,'nb_table_data_source')
        str = 'table';
    else
        str = 'figure';
    end

    switch lower(type)
        
        case 'letter'
            
            value             = get(hObject,'value');
            plotterAdv.letter = value;
            
        case 'letterrestart'
            
            if isprop(plotterAdv,'letterRestart')
                value                    = get(hObject,'value');
                plotterAdv.letterRestart = value;    
            end
            
        case 'jump'
            
            string = get(hObject,'string');
            if isempty(string)
                nb_errorWindow('The jump option cannot be set to empty.')
                return
            end
            
            value  = str2double(string);
            if isnan(value)
                nb_errorWindow(['The jump option must be set to a number. Is ' string '.'])
                return
            elseif value < 1
                nb_errorWindow(['The jump option must be set to a number greater then 1. Is ' string '.'])    
                return
            elseif ~nb_iswholenumber(value)
                nb_errorWindow('The jump option must be set to an integer.')
                return    
            end
            plotterAdv.jump = value;
            
        case 'counter'
            
            string = get(hObject,'string');
            if isempty(string)
                plotterAdv.counter = [];
                notify(gui,'changedGraph');
                return
            end
            
            value  = str2double(string);
            if isnan(value)
                nb_errorWindow(['The ' str ' number (1.X) option must be set to a number. Is ' string '.'])
                return
            elseif value < 1
                nb_errorWindow(['The ' str ' number (1.X) option must be set to a number greater then 1. Is ' string '.'])
                return
            elseif ~nb_iswholenumber(value)
                nb_errorWindow(['The ' str ' number (1.X) option must be set to an integer.'])
                return
            end
            plotterAdv.counter = value;
            
        case 'number'
            
            string = get(hObject,'string');
            if isempty(string)
                plotterAdv.number = [];
                notify(gui,'changedGraph');
                return
            end
            
            value  = str2double(string);
            if isnan(value)
                nb_errorWindow(['The ' str ' number (X) option must be set to a number. Is ' string '.'])
                return
            elseif value < 1
                nb_errorWindow(['The ' str ' number (X) option must be set to a number greater then 1. Is ' string '.']) 
                return
            elseif ~nb_iswholenumber(value)
                nb_errorWindow(['The ' str ' number (X) option must be set to an integer.'])
                return      
            end
            plotterAdv.number = value;
            
        case 'chapter'
            
            string = get(hObject,'string');
            if isempty(string)
                plotterAdv.chapter = [];
                notify(gui,'changedGraph');
                return
            end
            
            value = str2double(string);
            if isnan(value)
                nb_errorWindow(['The chapter option must be set to a number. Is ' string '.'])
                return
            elseif value < 1
                nb_errorWindow(['The chapter option must be set to a number greater then 1. Is ' string '.']) 
                return
            elseif ~nb_iswholenumber(value)
                nb_errorWindow('The chapter option must be set to an integer.')
                return       
            end
            plotterAdv.chapter = value;    
            
    end

    % Notify listeners
    notify(gui,'changedGraph');

end

