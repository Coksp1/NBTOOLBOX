function varargout = subsasgn(obj,s,b)
% Syntax:
%
% varargout = subsasgn(obj,s,b)
%
% Description:
%
% Makes it possible to do subscripted assignment of the data of an
% object
%
% Input:
% 
% - obj    : An object of class nb_math_ts
% 
% - s      : The same input as when you do subscripted assignment 
%            one a double matrix
% 
% - b      : The assign data at the given index s, as a double or
%            nb_math_ts object (disregard time dimension in this case!).
% 
% Output:
%
% - obj    : The assign data property setted of the given object.
% 
% Examples:
% 
% obj        = nb_math_ts.rand('2012',10,3); 
% obj(1:3,1) = [1;2;3]
% obj = 
% 
%     'Time'    'Var1'
%     '2012'    [   1]
%     '2013'    [   2]
%     '2014'    [   3]
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

                    try 
                        index3 = s(1).subs{3};
                    catch Err
                        switch Err.identifier
                            case 'MATLAB:badsubscript'
                                index3 = 1;
                            otherwise
                                rethrow(Err)
                        end
                    end
                catch Err
                    switch Err.identifier
                        case 'MATLAB:badsubscript'
                            % If you write obj() you keep the size of
                            % the object.
                            index1 = 1:obj.dim1;
                            index2 = 1:obj.dim2;
                            index3 = 1:obj.dim3;
                        otherwise
                            rethrow(Err)
                    end
                end
                if isa(b,'nb_math_ts')
                    b = b.data;
                end
                obj.data(index1,index2,index3) = b;
                
            elseif isa(s(1).subs{1},'nb_math_ts')
                
                objInd = s(1).subs{1};
                if ~islogical(objInd.data)
                    error([mfilename ':: Wrong asignment.'])
                end
                obj.data(objInd.data) = b;
                
            else
                error([mfilename ':: Wrong asignment.'])
            end           
            varargout{1} = obj;

        otherwise

            % Makes it possible to asign properties 
            % of the object in the ordinary way.
            [varargout{1:nargout}]  = builtin('subsasgn', obj, s, b);

    end

end
