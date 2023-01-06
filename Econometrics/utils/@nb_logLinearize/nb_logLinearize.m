classdef nb_logLinearize
% Description:
%
% A class for doing symbolic log-linearization of a mathematical 
% expression.
%
% Constructor:
%
%   obj = nb_logLinearize(equations,variables,parameters,precision);
% 
%   Input:
%
%   - equations  : Name of the variable to take derivative respect to.
%
%   - variables  : The variables to do the log-linearization wrt. I.e.
%                  the rest are treated as parameters.
%
%   - parameters : You can hard code in the parameters, if you already
%                  know them, otherwise these will be parsed out. If given
%                  it must be a 1 x nParam cellstr.
%
%   - precision  : See the doc on the property precision.
%
%   Output:
% 
%   - obj       : An object of class nb_logLinearize.
%
%   Examples:
%
%   logLin   = nb_logLinearize({'x+y','z=x*y^alpha'},{'x','y','z'});
%   logLin   = logLinearize(logLin);
%   logLinEq = getLinearization(logLin);  
%
% See also:
% nb_mySD
%
% Written by Kenneth Sæterhagen Paulsen    
   
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The text that is used to enclose gap variables. Default 
        % is 'x_GAP'. Must be a 1x2 cellstr. The first element
        % is added before the variable, and the second after.
        gapIdentifier = {'gap(',')'};
        
        % The text that is used to enclose steady-state variables. Default 
        % is 'steady_state(x)'. Must be a 1x2 cellstr. The first element
        % is added before the variable, and the second after.
        ssIdentifier  = {'steady_state(',')'};
         
    end

    properties (SetAccess=protected)
        
        % A nb_mySD object storing the symbolic derivatives.
        deriv           = [];
        
        % Set to false to prevent using nb_term.split to simplify the
        % log-linearized equations. Default is false.
        doSimplify      = false;
        
        % Function handle representing the equations.
        eqFunc          = [];
        
        % The equation we start with. As a N x 1 cellstr. Include a
        % equality sign ('=') to indicate that is a equation and not only
        % a term to log linearize.
        equations       = {};
        
        % The log-linearized equation. As a N x 1 cellstr.
        logLinEq        = {};
        
        % A cellstr with the parameters. If not provided, they will be
        % parsed out automatically at a cost of speed!
        parameters      = {};

        % The precision on the converted numbers. See the nb_num2str 
        % function. Default is 14, i.e. use nb_num2str with the second 
        % input set to 14.
        precision       = 14;
        
        % Equations in steady-state. As a N x 1 cellstr.
        ssEq            = {};
        
        % A cellstr with the variables to log-linearize wrt.
        variables       = {};
        
    end
    
    properties (Access=protected)
        
        % Indicator of the equation is part of a full expression or not.
        eqFound         = [];
        
        % If equality sign is used the equation is split into two parts.
        % This property store information on how to match the equations
        % again.
        eqInd           = [];
        
        % If equality sign is used the equation is split into two parts.
        % This property store information on how to match the equations
        % again. Reverse of eqInd.
        eqRevInd        = [];
        
    end
    
    methods 
        
        function obj = nb_logLinearize(equations,variables,parameters,precision)
            
            if nargin > 3
                obj.precision = precision;
            end
            if nargin == 1
                error([mfilename ':: The number of input must be 0, 2 or 3.'])
            elseif nargin == 0
                equations = {'x + y','z-x*y^alpha'};
            end
            if ischar(equations)
                equations = cellstr(equations);
            elseif ~iscellstr(equations)
                error([mfilename ':: The equations input must be a cellstr.'])
            end
            obj.equations = equations(:);
            obj           = transLeadLag(obj);
            obj           = removeEqSign(obj);
            if nargin < 2
                variables = {'x','y','z'};
            end
            if isempty(variables)
                error([mfilename ':: The variables input cannot be empty.'])
            end
            if ischar(variables)
                variables = cellstr(variables);
            elseif ~iscellstr(variables) 
                error([mfilename ':: The variables input must be a cellstr.'])
            end
            obj.variables = nb_rowVector(variables);

            if nargin < 3
                parameters = {};
            end
            if ~isempty(parameters)
                if ischar(parameters)
                    parameters = cellstr(parameters);
                elseif ~iscellstr(parameters) 
                    error([mfilename ':: The parameters input must be a cellstr.'])
                end
                obj.parameters = nb_rowVector(parameters);
            end

        end
        
        function obj = set.doSimplify(obj,value)
           
            if ~nb_isScalarLogical(value)
                error([mfilename ':: The property doSimplify must be set to a scalar logical.'])
            end
            obj.doSimplify = value;
            
        end
        
        function obj = set.gapIdentifier(obj,value)
           
            if nb_sizeEqual(value,[1,2]) && iscellstr(value) %#ok<ISCLSTR>
                obj.gapIdentifier = value;
            else
                error([mfilename ':: The property gapIdentifier must be set to a 1x2 cellstr array.'])
            end
            
        end
        
        function obj = set.ssIdentifier(obj,value)
           
            if nb_sizeEqual(value,[1,2]) && iscellstr(value) %#ok<ISCLSTR>
                obj.ssIdentifier = value;
            else
                error([mfilename ':: The property ssIdentifier must be set to a 1x2 cellstr array.'])
            end
            
        end
        
        function disp(obj)
           
            if isempty(obj.logLinEq)
                disp('Call the logLinearize method to do the log linearization of the equations.')
                return
            end
            
            disp(nb_createLinkToClass(obj));
            for ii = 1:length(obj.equations)
                disp(' ')
                disp(['Equation ' int2str(ii) ':'])
                disp(obj.equations{ii})
                
                disp(' ')
                disp(['Log linearization of equation ' int2str(ii) ':'])
                disp(obj.logLinEq{ii})
                
                disp(' ')
                disp(['The steady-state of equation ' int2str(ii) ':'])
                disp(obj.ssEq{ii})
                
            end
            
        end
        
    end
    
    methods (Static=true)
       
    end
    
end
