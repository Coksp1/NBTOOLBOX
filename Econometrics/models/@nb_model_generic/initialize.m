function obj = initialize(objClass,template)
% Syntax:
%
% obj = initialize(template)
%
% Description:
%
% Intialize multiple model objects, see output from the template method
% of each subclass of the nb_model_generic class.
% 
% Input:
% 
% - objClass : The name of any of the subclasses of the nb_model_generic 
%              class. As a string.
%
% - template : The output from the template method of each subclass of the
%              nb_model_generic class. Multiple model objects will be
%              intialized if the num input that method is greater than one.
% 
% Output:
% 
% - obj      : An object which is of nb_model_generic
%
% Examples:
%
% template = nb_var.template(4);
% obj      = nb_model_generic.initialize('nb_var',template);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    sStruct = size(template);
    func    = str2func(objClass);
    try
        obj(sStruct(1),sStruct(2)) = func();
    catch 
        error([mfilename ':: The class ' objClass ' is not a subclass of the class nb_model_generic.'])
    end
    for ii = 1:sStruct(1)
        for jj = 1: sStruct(2)
            obj(ii,jj) = func(template(ii,jj));
        end
    end

end
