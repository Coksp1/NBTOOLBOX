classdef nb_param < nb_varOrPar
% Description:
%
% A class for storing a parameter. Can be used to calculate symbolic 
% derivatives of expressions with unassign parameters when combined with 
% nb_mySD. 
%
% Superclasses:
%
% nb_varOrPar, matlab.mixin.Heterogeneous
%
% Constructor:
%
%   obj = nb_param(parameters);
% 
%   Input:
%
%   - parameters : The parameter as a one line char or the parameters as 
%                  a cellstr.
%
%   - precision  : See help on the property precision.
% 
%   Output:
% 
%   - obj        : An object of class nb_param
%
%   Examples:
%
%   p    = nb_param({'x','y','z'});
%   expr = p(1)*p(2)
%
% Written by Kenneth Sæterhagen Paulsen    
   
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (SetAccess=protected)
        
        % The property storing the derivatives as a cellstr. Allways
        % {'0'}.
        derivatives = {'0'};
        
        % A one line char with the parameter or a expression involving the
        % parameter (and possobly others as well)
        parameter = '';
        
        % The precision on the converted numbers. See the nb_num2str 
        % function. Default is 14, i.e. use nb_num2str with the second 
        % input set to 14.
        precision   = 14;
        
    end
    
    methods 
        
        function obj = nb_param(parameters,precision)
            
            if nargin == 0
                return
            end 
            if nargin > 1
                obj.precision = precision;
            end
            if ischar(parameters)
                obj.parameter = parameters;
                return
            end
            parameters = parameters(:);
            nParam     = size(parameters,1);
            obj        = obj(ones(1,nParam),1);
            for ii = 1:nParam
                obj(ii).parameter = parameters{ii}; 
            end
            
        end
        
        function disp(obj)
            disp(nb_createLinkToClass(obj));
            disp(' ')
            disp({obj.parameter}');
        end
        
        function string = char(obj)
            string = obj.parameter;
        end

    end
    
end
