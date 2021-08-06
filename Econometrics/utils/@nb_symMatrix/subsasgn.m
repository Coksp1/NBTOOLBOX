function varargout = subsasgn(obj,s,b)
% Syntax:
%
% varargout = subsasgn(obj,s,b)
%
% Description:
%
% Makes it possible to do subscripted assignment an object of class
% nb_symMatrix.
%
% Input:
% 
% - obj    : An object of class nb_symMatrix.
% 
% - s      : The same input as when you do subscripted assignment 
%            one a double matrix
% 
% - b      : The assign data at the given index s. Either numeric or
%            an object of class nb_symMatrix.
% 
% Output:
%
% - obj    : An object of class nb_symMatrix.
% 
% Examples:
% 
% obj      = nb_symMatrix(2,2);
% obj(1,1) = nb_symMatrix('X',1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch s(1).type

        case '()'

            if isnumeric(s(1).subs{1}) || strcmp(s(1).subs{1},':')

                try 
                    index1 = s(1).subs{1};
                    try 
                        index2 = s(1).subs{2};
                    catch Err
                        switch Err.identifier
                            case 'MATLAB:badsubscript'
                                index2 = 1;
                            otherwise
                                rethrow(Err)
                        end
                    end
                    
                catch Err
                    switch Err.identifier
                        case 'MATLAB:badsubscript'
                            % If you write obj() you keep the size of
                            % the object.
                            index1 = 1:size(obj,1);
                            index2 = 1:size(obj,2);
                        otherwise
                            rethrow(Err)
                    end
                end
                if not(isnumeric(index2) || strcmp(index2,':'))
                    error([mfilename ':: Wrong asignment.'])
                end
                if isnumeric(b) || ischar(b) || iscellstr(b)
                    b = nb_symMatrix(b);
                elseif ~isa(b,'nb_symMatrix')
                    error([mfilename ':: Conversion to nb_symMatrix from ' class(b) ' is not possible.'])
                end
                obj.symbols(index1,index2) = b.symbols;
                varargout{1}               = obj;
                
            else
                error([mfilename ':: Wrong asignment.'])
            end

        otherwise

            % Makes it possible to asign properties 
            % of the object in the ordinary way.
            [varargout{1:nargout}]  = builtin('subsasgn', obj, s, b);

    end

end
