function selectFrequency(gui,hObject,~)
% Syntax:
%
% selectFrequency(gui,hObject,event)
%
% Description:
%
% Part of DAG. Update the options given the choosen frequency
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get selected frequency
    string = get(hObject,'string');
    index  = get(hObject,'value');
    freq   = string{index};
    freq   = nb_date.getFrequencyAsInteger(freq);

    if gui.data.frequency < freq

        methods = {'Linear - match last',...
                   'Linear - match first',...
                   'Cubic - match last',...
                   'Cubic - match first',...
                   'None - match last',...
                   'None - match first',...
                   'Fill - match last',...
                   'Fill - match first'};
        if any(freq == [4,12])
            methods = [methods,{'Denton - match average','Denton - match sum'}];
        end
        
    else

        methods = {'Average',...
                   'Sum',...
                   'Last',...
                   'First',...
                   'Min',...
                   'Max'};

    end

    set(gui.list2,'string',methods,'value',1);

end
