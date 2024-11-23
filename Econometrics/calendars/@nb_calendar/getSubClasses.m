function classes = getSubClasses()
% Syntax:
%
% classes = nb_calendar.getSubClasses()
%
% Description:
%
% Get all available subclasses of the nb_calendar for your version of 
% NB Toolbox.
% 
% Output:
% 
% - classes : A cellstr with the subclasses.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    classes = {'nb_allCalendar';'nb_currentCalendar';'nb_lastCalendar';...
               'nb_manualCalendar';'nb_numDaysCalendar'};
    
    try
        ret = nb_is();
    catch 
        ret = false;
    end
    if ret
        classes = [classes; {'nb_MPRCalendar';'nb_MPRCutoffCalendar'}];
    end       
    try
        ret = smart_is();
    catch 
        ret = false;
    end
    if ret
        classes = [classes; {'nb_SMARTVariableCalendar';'nb_SMARTDynamicCalendar'}];
    end

end
