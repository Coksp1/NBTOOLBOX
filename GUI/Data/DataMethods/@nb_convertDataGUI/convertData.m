function convertData(gui,hObject,~)
% Syntax:
%
% convertData(gui,hObject,event)
%
% Description:
%
% Part of DAG. Do the convertion
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get selected frequency
    string = get(gui.list1,'string');
    index  = get(gui.list1,'value');
    freq   = string{index};
    freq   = nb_date.getFrequencyAsInteger(freq);

    % Get selected method
    string = get(gui.list2,'string');
    index  = get(gui.list2,'value');
    method = string{index};

    if gui.data.frequency < freq

        switch method

            case 'Linear - match last'
                intDate = 'end';
                method  = 'linear';
            case 'Linear - match first'
                intDate = 'start';
                method  = 'linear';
            case 'Cubic - match last'
                intDate = 'end';
                method  = 'cubic';
            case 'Cubic - match first'
                intDate = 'start';
                method  = 'cubic';
            case 'None - match last'
                intDate = 'end';
                method  = 'none';
            case 'None - match first'
                intDate = 'start';
                method  = 'none';
            case 'Fill - match last'
                intDate = 'end';
                method  = 'fill';
            case 'Fill - match first'
                intDate = 'start';
                method  = 'fill';
            case 'Denton - match average'
                intDate = 'start';
                method  = 'daverage';
            case 'Denton - match sum'
                intDate = 'start';
                method  = 'dsum';    
        end
        inputs = {freq,method,'interpolateDate',intDate};

    else

        if strcmpi(method,'last')
            method = 'discrete';
        else
            method = lower(method);
        end
        inputs = {freq,method};

    end

    includeLast = get(gui.radio1,'value');
    if includeLast
        inputs = [inputs,'includeLast'];
    end

    rename = get(gui.radio2,'value');
    if rename
        inputs = [inputs,'rename'];
    end

    % Try to convert the frequency of the object
    try
        gui.data = gui.data.convert(inputs{:}); 
    catch Err
        close(get(hObject,'parent'))
        nb_errorWindow('Failed when trying to convert the frequency of the dataset.',Err)
        return
    end

    % Assign the converted object to its parent
    notify(gui,'methodFinished');

    % Close open window
    close(get(hObject,'parent'))

end
