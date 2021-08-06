function obj = convert(obj,freq,method,varargin)
% Syntax:
%
% obj = convert(obj,freq,method,varargin)
%
% Description:
%
% Convert all the nb_ts object of the object. I.e. use their 
% convert method with the same inputs as given to this method.
% 
% Input:
% 
% - obj    : An object of class nb_DataCollection
% 
% - freq   : The new freqency of the data. As an integer:
% 
%            - 1   : yearly
%            - 4   : quarterly
%            - 12  : monthly
%            - 365 : daily
% 
% - method : The method to use. Either:
% 
%            From a high frequency to a low:
% 
%            - 'avarage'  : Takes averages over the subperiods 
%            - 'sum'      : Takes sums over the subperiods 
%            - 'discrete' : Takes last observation in each 
%                           subperiod (Default)
% 
%            From a low frequency to a high:
% 
%            - 'linear'   : linear interpolation
%                           (Default) 
%            - 'cubic'    : shape-preserving piecewise cubic 
%                           interpolation 
%            - 'spline'   : piecewise cubic spline interpolation  
%            - 'none'     : no interpolation. All data in between 
%                           is given by nans (missing values)
% 
%            Caution: This input must be given if you provide some 
%                     of the optional inputs.
% 
% Optional input:
% 
% - 'includeLast' : Give this string as input if you want to 
%                   include the last period, even if it is not 
%                   finished. Only when converting to lower 
%                   frequencies
% 
%                   E.g: obj = obj.convert(1,'average',...
%                   'includeLast');
% 
% - 'rename'      : Changes the postfixes of the variables names.
% 
%                   E.g. If you covert from the frequency 12 to 4 
%                        the prefixes of the variable names changes 
%                       from 'MUA' to 'QUA', if the postfix exist.
% 
%                   E.g: obj = obj.convert('yearly','average',...
%                                          'rename');
% 
% 
% Optional input obj.convert(...,'inputName','inputValue',...):
% 
% - 'interpolateDate' : The input after this input must either be
%                       'start' or 'end'.
% 
%                       Date of interpolation. Where 'start' means 
%                       to interpolate the start date of the 
%                       periods of the old frequency, while 'end' 
%                       uses the end date of the periods.
% 
%                       Default is 'start'.
% 
%                       Caution : Only when converting to higher
%                       frequency.
% 
%                       E.g: obj = obj.convert(365,'linear',...
%                       'interpolateDate','end');
% 
% Output:
% 
% - obj    : An object of class nb_DataCollection with all the 
%            stored nb_ts object converted to the new freqency.
%         
% Examples:
% 
% obj = obj.convert(4,'average'); 
% obj = obj.convert(365,'linear','interpolateDate','end');
% obj = obj.convert(1,'average','includeLast');  
% obj = obj.convert(1,'average','rename');
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    temp = obj.list.getFirst();
    for ii = 1:size(obj.objectsID,2)

        dataSet = temp.getElement();
        if isa(dataSet,'nb_ts')
            try
                dataSet = dataSet.convert(freq,method,varargin{:});
            catch Err
                error([mfilename ':: Could not convert the object stored with id ' obj.objectsID{ii} '. '...
                                 'MATLAB error message: ' Err.message])
            end
            temp.setElement(dataSet);
        end
        temp = temp.getNext();

    end 

end
