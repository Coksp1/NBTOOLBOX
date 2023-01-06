function setXTickFrequency(gui,hObject,~)
% Syntax:
%
% setXTickFrequency(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

   % Get the value selected
    index   = get(hObject,'value');
    strs    = get(hObject,'string');
    freq    = strs{index};

    % Set the plotter object
    oldFreq = gui.plotter.xTickFrequency;
    
    % Convert x-tick start date if given
    if ~isempty(gui.plotter.xTickStart)
        
        if isempty(oldFreq)
            oldFreq = gui.plotter.DB.frequency;
        else
            oldFreq = nb_date.getFrequencyAsInteger(oldFreq);
        end
        if ischar(gui.plotter.xTickStart)
            [~,~,oldDate] = nb_interpretDateObsTypeInputGUI(plotter,gui.plotter.xTickStart,oldFreq);
        else
            oldDate = gui.plotter.xTickStart;
        end
        freqT                  = nb_date.getFrequencyAsInteger(freq);
        gui.plotter.xTickStart = convert(oldDate,freqT);
        set(gui.xTickStart,'string',toString(gui.plotter.xTickStart));
        
    end
        
    gui.plotter.xTickFrequency = freq;
    
    % Udate the graph
    notify(gui,'changedGraph');

end
