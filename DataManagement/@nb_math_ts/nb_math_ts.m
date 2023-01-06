classdef nb_math_ts
% Description:
%
% A class representing timeseries data. 
%    
% The differense between this and the nb_ts class is that all 
% reference to the varibales are removed. This makes some operators 
% work as normal matrices. (Matrix multiplication, matrix division 
% and matrix power of two object of class nb_math_ts is for example
% undefined for this class.) 
%
% That the object of this class has no reference to the object 
% makes it easier to do datatransformations. E.g.
%
% var1 = nb_math_ts([2;2;2;2],'2012Q1');
% var2 = nb_math_ts([2;2;2;2],'2012Q1');
% var3 = var1./var2;
% var3 = 
% 
%     '2012Q1'    [1]
%     '2012Q2'    [1]
%     '2012Q3'    [1]
%     '2012Q4'    [1]
%     
% Caution : nb_ts and this class has not the same methods.
% 
% Constructor:      
%
%   obj = nb_math_ts(data,startDate)
% 
%   Input:
% 
%   - data      : 
%
%       > A double with the data.
%
%       > An object of class nb_ts
%
%       > An object of class tseries (Needs the IRIS package)
%         
%   - startDate :
% 
%       The start date of the data. Only needed when you give 
%       numerical data as one element of the input datasets (also  
%       when numerical data is given through a struct).
%         
%       Must be a string on the date format given below or an 
%       object which is of a subclass of the nb_date class.
%
%       Dating convention:
%         > Yearly      : 'yyyy'.           E.g. '2011'
%         > Semiannualy : 'yyyySs'          E.g. '2011S1'
%         > Quarterly   : 'yyyyQq'.         E.g. '2011Q1'
%         > Monthly     : 'yyyyMm(m)'.      E.g. '2011M1', 
%                                                '2011M11'
%         > Daily       : 'yyyyMm(m)Dd(d)'  E.g. '2011M1D1', 
%                                                '2011M11D11'
%
%       Caution: Must not be provided when the data input is of 
%                class nb_ts or tseries.
%
%   Output:
% 
%   - obj      : An object of class nb_math_ts.
% 
%   Examples:
% 
%   obj = nb_math_ts([2,2;2,2],'2012Q1');
% 
% See also: 
% nb_ts
% 
% Written by Kenneth Sæterhagen Paulsen   

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties (Dependent=true)

        % The size of the first dimension of the data property. As a double.
        dim1;
        
        % The size of the second dimension of the data property. As a double.
        dim2;
        
        % The size of the third dimension of the data property. As a double.
        dim3;         
        
    end
        
    properties
        
        % The data of the object. As a double or logical
        data      = [];         
        
        % The end date of data. Given as an object which is 
        % of a subclass of the nb_date class. Either: nb_day, 
        % nb_month, nb_quarter, nb_semiAnnual or nb_year
        endDate   = nb_date();
        
        % The start date of the data. Given as an object which is 
        % of a subclass of the nb_date class. Either: nb_day, 
        % nb_month, nb_quarter, nb_semiAnnual or nb_year.             
        startDate = nb_date();
        
    end
    
    methods
        
        function obj = nb_math_ts(data,startDate)      
        
            if nargin == 1
                
                if isa(data,'nb_ts')
                    
                    obj.data      = data.data;
                    obj.startDate = data.startDate;
                    obj.endDate   = data.endDate;
                    
                elseif isa(data,'tseries')
                    
                    obj.data      = double(data);
                    startD        = dat2str(get(data,'start'));
                    obj.startDate = startD{1};
                    endD          = dat2str(get(data,'end'));
                    obj.endDate   = endD{1};
                    
                else
                    error([mfilename ':: When you give 1 input to the constructor of the nb_math_ts class it must be of class nb_ts or tseries.'])
                end
                
            elseif nargin == 2
            
                if ~isnumeric(data) && ~islogical(data)
                    error([mfilename ':: The input ''data'' must be a number when you give two inputs to the constructor of the nb_math_ts class.'])
                end
                
                if ischar(startDate)

                    startDate = nb_date.date2freq(startDate);

                elseif isa(startDate,'nb_date')

                    % Do nothing

                elseif isnumeric(startDate)

                    startDate = nb_year(startDate);

                else 
                    error([mfilename ':: the ''startDate'' input must either be a string or an integer.'])
                end

                % Assign properties
                periods       = size(data,1);
                obj.endDate   = startDate + periods - 1;
                obj.startDate = startDate;
                obj.data      = data;
                
            end
            
        end
        
        function value = get.dim1(obj)
            value = size(obj.data,1);
        end
        function value = get.dim2(obj)
            value = size(obj.data,2);
        end
        function value = get.dim3(obj)
            value = size(obj.data,3);
        end
        
        function varargout = size(obj,varargin)
            [varargout{1:nargout}] = size(obj.data, varargin{:});
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        function [startDateWin,endDateWin,startInd,endInd,pages] = getWindow(obj,startDateWin,endDateWin,pages)
            
             % Which dates to keep
            startDateWin = nb_date.toDate(startDateWin,obj.startDate.frequency);
            endDateWin   = nb_date.toDate(endDateWin,  obj.startDate.frequency);

            if ~isempty(startDateWin)

                startInd = (startDateWin - obj.startDate) + 1;
                if startInd < 1
                    error([mfilename ':: beginning of window (''' startDateWin.toString ''') starts before the start date (''' obj.startDate.toString() ''') '...
                                     'or starts after the end date (''' obj.endDate.toString ''') of the data '])
                end

            else
                startInd     = 1;
                startDateWin = obj.startDate;
            end

            if ~isempty(endDateWin)

                endInd      = (endDateWin - obj.startDate) + 1;
                if endInd > obj.dim1
                    error([mfilename ':: end of window (''' endDateWin.toString ''') ends after the end date (''' obj.endDate.toString ''') or '...
                                     'ends before the start date (''' obj.startDate.toString() ''') of the data '])
                end

            else
                endInd     = obj.dim1;
                endDateWin = obj.endDate;
            end

            % Which pages to keep
            if isempty(pages)
                pages = 1:obj.dim3;
            else
                if isnumeric(pages)
                    m = max(pages);
                    if m > obj.dim3
                        error([mfilename ':: The object consist only of ' int2str(obj.dim3) ' pages. You are trying to reach the page ' int2str(m) ', which is not possible.'])
                    end
                else
                    pages = 1:obj.dim3;
                end
            end
            
        end
        
        function [a,b] = checkConformity(a,b)
        % Syntax:
        %
        % [a,b] = checkConformity(a,b)
        %
        % Description:
        %
        % Static method
        % 
        % Checks if the the two objects have the same dimension
        % 
        % Input:
        %
        % Output:
        %
        % Examples:
        % 
        % Written by Kenneth S. Paulsen


            if a.dim1 ~= b.dim1
                error([mfilename ':: The data of the two objects has not the same number of rows.'])
            end

            if a.dim2 ~= b.dim2

                if a.dim2 == 1
                    a.data = repmat(a.data,[1,b.dim2,1]);
                elseif b.dim2 == 1
                    b.data = repmat(b.data,[1,a.dim2,1]);
                else
                    error([mfilename ':: The data of the two objects has not the same number of columns or neither of them has only one column.'])
                end

            end

            if a.dim3 ~= b.dim3
                error([mfilename ':: The data of the two objects has not the same number of pages.'])
            end

        end
             
    end
    
    %======================================================================
    % Hidden methods
    %======================================================================
    methods (Access=public,Hidden=true)
    
        function n = numArgumentsFromSubscript(obj,~,~)
            n = numel(obj);
        end
        
        function ind = end(obj,k,~)    
            switch k
                case 1
                    ind = obj.dim1;
                case 2
                    ind = obj.dim2;
                case 3
                    ind = obj.dim3;
            end
        end
        
    end
    
    %======================================================================
    % Static methods
    %======================================================================
    methods (Static=true)
        
        varargout = nan(varargin)
        varargout = rand(varargin)
        
    end
    
end
