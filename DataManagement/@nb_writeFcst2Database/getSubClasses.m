function classes = getSubClasses()
% Syntax:
%
% classes = nb_writeFcst2Database.getSubClasses()
%
% Description:
%
% Get all available subclasses of the nb_writeFcst2Database for your  
% version of NB Toolbox.
% 
% Output:
% 
% - classes : A cellstr with the subclasses.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    classes = {'nb_writeFcst2DatabaseMAT'};
    try
        ret = smart_is();
    catch 
        ret = fals;
    end
    if ret
        classes = [classes, 'nb_SMARTModel'];
    end

end
