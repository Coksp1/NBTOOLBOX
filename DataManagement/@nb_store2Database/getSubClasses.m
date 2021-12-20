function classes = getSubClasses()
% Syntax:
%
% classes = nb_store2Database.getSubClasses()
%
% Description:
%
% Get all available subclasses of the nb_store2Database for your version 
% of NB Toolbox.
% 
% Output:
% 
% - classes : A cellstr with the subclasses.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    classes = {'nb_store2DatabaseMAT'};
    try
        ret = nb_is();
    catch 
        ret = false;
    end
    if ret
        classes = [classes, 'nb_store2DatabaseFAME'];
    end
    try
        ret = smart_is();
    catch 
        ret = false;
    end
    if ret
        classes = [classes, 'nb_SMARTCalculator'];
    end

end
