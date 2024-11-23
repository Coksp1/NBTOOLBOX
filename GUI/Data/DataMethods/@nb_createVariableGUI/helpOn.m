function help = helpOn(func)
% Syntax:
%
% help = helpOn(func)
%
% Description:
%
% Part of DAG.
% 
% Written by Andreas Haga Raavand  

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

switch lower(func)
    case '+'
        help = 'Plus. X + Y';
    case '-'
        help = 'Minus. X - Y ';
    case '*'
        help = 'Multiplication. X * Y or a * X';
    case '/'
        help = 'Division. X / Y or a / X';
    case '^'
        help =  'Power. X^a';
    case 'abs'
        help = 'Takes the absolute value of each data element. abs(X)';
    case 'acos'
        help = 'Inverse cosine of each data elememt, result in radians. acos(X)';
    case 'acosd'
        help = 'Inverse cosine of each data elememt, result in degrees. acosd(X)';
    case 'acosh'
        help = 'Inverse hyperbolic cosine of each data element. acosh(X)';
    case 'acot'
         help = 'Inverse cotangent of each data element, result in radians. acot(X)';
    case 'acotd'
         help = 'Inverse cotangent of each data element, result in degrees. acotd(X)';
    case 'acoth'
        help = 'Inverse hyperbolic cotangent of each data element. acoth(X)';
     case 'acsc'
        help = 'Inverse cosecant of each data element, result in radians. acsc(X)';
     case 'acscd'
        help = 'Inverse cosecant of each data element, result in degrees. acscd(X)';
     case 'acsch'
        help = 'Inverse hyperbolic cosecant of each data element. acsch(X)';  
     case 'asec'
        help = 'Inverse secant of each data element, result in radians. asec(X)';  
     case 'asecd'
        help = 'Inverse secant of each data element, result in degrees. asecd(X)';  
     case 'asech'
        help = 'Inverse hyperbolic secant of each data element. asech(X)';  
     case 'asin'
        help = 'Inverse sine of each data element, result in radians. asin(X)';  
     case 'asind'
        help = 'Inverse sine of each data element, result in degrees. asind(X)';  
     case 'asinh'
        help = 'Inverse hyperbolic sine of each data element. asinh(X)';  
     case 'atan'
        help = 'Inverse tangent of each data element, result in radians. atan(X)';  
     case 'atan2'
        help = 'Four quandrant inverse tangent, result in radians. atan2(X,Y) is the four quadrant arctangent of the elements of X and Y';  
     case 'atan2d'
        help = 'Four quandrant inverse tangent, result in degrees. atan2d(X,Y) is the four quadrant arctangent of the elements of X and Y';  
     case 'atand'
        help = 'Inverse tangent of each data element, result in degrees. atand(X)';  
     case 'atanh'
        help = 'Inverse hyperbolic tangent of each data element. atanh(X)';  
     case 'bkfilter'
        help = 'Band pass filter. bkfilter(X,pl,pu). Inputs: - X: series of data (T x 1). - pl: minimum period of oscillation of desired component. - pu: maximum period of oscillation of desired component';  
     case 'bkfilter1s'
        help = 'One sided band pass filter. bkfilter1s(X,pl,pu). Inputs: X: series of data (T x 1), pl: minimum period of oscillation of desired component, pu: maximum period of oscillation of desired component';  
     case 'ceil'
        help = 'Round towards plus infinity. ceil(X) rounds the elements of X to the nearest integers towards infinity';  
     case 'conj'
        help = 'Complex conjugate. conj(X)';  
     case 'cos'
        help = 'Cosine of argument in radians. cos(X)';  
     case 'cosd'
        help = 'Cosine of argument in degrees. cosd(X)';  
     case 'cosh'
        help = 'Hyperbolic cosine of argument. cosh(X)';  
     case 'cot'
        help = 'Cotangent of argument in radians. cot(X)';   
     case 'cotd'
        help = 'Cotangent of argument in degrees. cotd(X)';
     case 'coth'
        help = 'Hyperbolic cotangent of argument. cot(X)';  
     case 'csc'
        help = 'Cosecant of argument in radians. csc(X)';  
     case 'cscd'
        help = 'Cosecant of argument in degrees. cscd(X)';
     case 'csch'
        help = 'Hyperbolic cosecant of argument. csch(X)';
     case 'cumprod'
        help = ['Cumulative product of elements. For vectors, cumprod(X) is a vector containing the cumulative product',...
               'of the elements of X.  For matrices, cumprod(X) is a matrix the same',...
               'size as X containing the cumulative products over each column. For',...
               'N-D arrays, cumprod(X) operates along the first non-singleton dimension. ',...
               'cumprod(X,DIM) works along the dimension DIM'];
     case 'cumsum'
        help = ['Cumulative sum of elements. For vectors, cumsum(X) is a vector containing the cumulative sum',...
               'of the elements of X.  For matrices, cumsum(X) is a matrix the same',...
               'size as X containing the cumulative sum over each column. For',...
               'N-D arrays, cumsum(X) operates along the first non-singleton dimension. ',...
               'cumsum(X,DIM) works along the dimension DIM'];  
     case 'diff'
        help = 'Difference and approximate derivative. diff(X)';   
     case 'egrowth'
        help = 'Calculate exact growth, using the formula: (x(t) - x(t-1))/x(t-1) of all the timeseries of the nb_ts object. egrowth(X,lag)';  
     case 'epcn'
        help = 'Exact percentage growth. epcn(X,lag) where lag is the number of lags in the growth formula (default is 1)';  
     case 'exp'
        help = 'Exponential. exp(X) is the exponential of the elements of X, e to the X';  
     case 'expm1'
        help = 'Compute EXP(X)-1 accurately. expm1(X) computes EXP(X)-1, compensating for the roundoff in EXP(X)';  
     case 'filter'
        help = 'One-dimensional digital filter. filter(B,A,X) filters the data in vector X with the filter described by vectors A and B to create the filtered data';  
     case 'floor'
        help = 'Round towards minus infinity. floor(X) rounds the elements of X to the nearest integers towards minus infinity';  
     case 'growth'
        help = 'Calculate approx growth, using the formula: log(x(t))-log(x(t-1) of all the timeseries of the nb_ts object. growth(X,lag)';  
     case 'hpfilter'
        help = 'Hodrick-Prescott filter. hpfilter(X,lambda)';  
     case 'hpfilter1s'
        help = 'One-sided Hodrick-Prescott filter. hpfilter1s(X,lambda)';  
     case 'iegrowth'
        help = ['Construct indicies based on inital values and timeseries wich represent the series growth. Inverse of exact growth, i.e. the inverse method of the egrowth method of the nb_ts class.',...
                'Input: obj: An object of class nb_ts,',... 
                'InitialValues: A scalar or a double with the initial values of the indicies. Must be of the same size as the number of variables of the nb_ts object. If not provided 100 is default,',... 
                'periods: The number of periods the initial series has been taken growth over.',...
                'iegrowth(obj,initialValues,periods)'];
     case 'iepcn'
        help = ['Construct indicies based on inital values and timeseries wich represent the series growth. Inverse of exact percentage growth, i.e. the inverse method of the epcn method of the nb_ts class.',...
                'Input: obj: An object of class nb_ts,',... 
                'InitialValues: A scalar or a double with the initial values of the indicies. Must be of the same size as the number of variables of the nb_ts object. If not provided 100 is default,',... 
                'periods: The number of periods the initial series has been taken growth over.',...
                'iepcn(obj,initialValues,periods)'];
     case 'igrowth'
        help = ['Construct indicies based on inital values and timeseries wich represent the series growth. Inverse of log approx. growth, i.e. the inverse method of the growth method of the nb_ts class.',...
                'Input: obj: An object of class nb_ts,',... 
                'InitialValues: A scalar or a double with the initial values of the indicies. Must be of the same size as the number of variables of the nb_ts object. If not provided 100 is default,',... 
                'periods: The number of periods the initial series has been taken growth over.',...
                'igrowth(obj,initialValues,periods)'];
     case 'ipcn'
        help = ['Construct indicies based on inital values and timeseries wich represent the series growth. Inverse of percentage log approx. growth, i.e. the inverse method of the pcn method of the nb_ts class.',...
                'Input: obj: An object of class nb_ts,',... 
                'InitialValues: A scalar or a double with the initial values of the indicies. Must be of the same size as the number of variables of the nb_ts object. If not provided 100 is default,',... 
                'periods: The number of periods the initial series has been taken growth over.',...
                'ipcn(obj,initialValues,periods)'];
     case 'lag'
        help = 'Lag the data of the object. The input periods decides for how many periods. lag(X,periods)';  
     case 'lead'
        help = 'Lead the data of the object. The input periods decides for how many periods. lead(X,periods)';  
     case 'log'
        help = ' Natural logarithm. log(X) is the natural logarithm of the elements of X';  
     case 'log10'
        help = 'Common (base 10) logarithm. log10(X) is the base 10 logarithm of the elements of X';  
     case 'log1p'
        help = 'Compute LOG(1+X) accurately. log1p(X) computes LOG(1+X), without computing 1+X for small X';  
     case 'log2'
        help = 'Base 2 logarithm and dissect floating point number. log2(X) is the base 2 logarithm of the elements of X';  
     case 'mavg'
        help = ['Taking moving avarage of all the timeseries of the nb_ts object.',...
                'Input: obj: An object of class nb_ts',...
                'backward : Number of periods backward in time to calculate the moving average',...
                'forward  : Number of periods forward in time to calculate the moving average',...  
                'mavg(obj,backward,forward)'];
     case 'max'
        help = ['Largest component. For vectors, max(X) is the largest element in X. For matrices, max(X) is a row vector containing the maximum element from each',...
                'column. For N-D arrays, max(X) operates along the first non-singleton dimension']; 
     case 'mean'
        help = ['Average or mean value. For vectors, mean(X) is the mean value of the elements in X. For matrices, mean(X) is a row vector containing the mean value of',...
                'each column.  For N-D arrays, mean(X) is the mean value of the elements along the first non-singleton dimension of X'];
     case 'median'
        help = ['Median value. For vectors, median(X) is the median value of the elements in X. For matrices, median(X) is a row vector containing the median',...
                'value of each column.  For N-D arrays, median(X) is the median value of the elements along the first non-singleton dimension of X'];
     case 'min'
        help = ['Smallest component. For vectors, min(X) is the smallest element in X. For matrices, min(X) is a row vector containing the minimum element from each',...
                'column. For N-D arrays, min(X) operates along the first non-singleton dimension']; 
     case 'minus'
        help = 'Minus. X - Y subtracts matrix Y from X.  X and Y must have the same dimensions unless one is a scalar.  A scalar can be subtracted from anything';  
     case 'mstd'
        help = ['Taking moving standard deviation of all the timeseries of the nb_ts class.',...
                'Input: obj: An object of class nb_ts',...
                'backward: Number of periods backward in time to calculate the moving std',...
                'forward: Number of periods forward in time to calculate the moving std',...
                'mstd(obj,backward,forward)'];
     case 'pcn'
        help = 'Calculate log approximated percentage growth. Using the formula (log(t+lag) - log(t))*100. pcn(obj,lag)';  
     case 'plus'
        help = 'Plus. X + Y adds matrices X and Y.  X and Y must have the same dimensions unless one is a scalar (a 1-by-1 matrix). A scalar can be added to anything';  
     case 'pow2'
        help = 'Base 2 power and scale floating point number. pow2(Y) for each element of Y is 2 raised to the power Y.';  
     case 'power'
        help = '.^ Array power.  X.^Y denotes element-by-element powers.  X and Y must have the same dimensions unless one is a scalar. A scalar can operate into anything.';  
     case 'prod'
        help = ['Product of elements. For vectors, prod(X) is the product of the elements of X. For matrices, prod(X) is a row vector with the product over each column.',... 
                'For N-D arrays, prod(X) non-singleton dimension'];  
     case 'q2y'
        help = 'Will for each quarter calculate the cumulative sum over the last 4 quarter (Including the present). The frequency of the return object will be quarterly. q2y(obj)';  
     case 'real'
        help = 'Complex real part. real(X) is the real part of X';  
     case 'reallog'
        help = 'Real logarithm. reallog(X) is the natural logarithm of the elements of X';  
     case 'realpow'
        help = 'Real power. realpow(X,Y) denotes element-by-element powers.  X and Y must have the same dimensions unless one is a scalar. A scalar can operate into anything';  
     case 'realsqrt'
        help = 'Real square root. realsqrt(X) is the square root of the elements of X.  An error is produced if X is negative';  
     case 'ret'
        help = ['Calculate return, using the formula: x(t)/x(t-lag) of all the timeseries of the nb_ts object.',...
                'Input: obj: An object of class nb_ts',...
                'nlag: The number of lags in the return formula, default is 1.',...
                'skipNaN : - 1 : Skip nan while using the ret operator. (E.g. when dealing with working days.)',...
                '          - 0 : Do not skip nan values. Default.',...
                'ret(obj), ret(obj,nlag), ret(obj,nlag,skipNaN)'];
     case 'round'
        help = 'Round towards nearest integer. round(X) rounds the elements of X to the nearest integers';  
     case 'sec'
        help = 'Secant of argument in radians. sec(X)';  
     case 'secd'
        help = 'Secant of argument in degrees. secd(X)'; 
     case 'sech'
        help = 'Hyperbolic secant of argument. sech(X)'; 
     case 'sin'
        help = 'Sine of argument in radians. sin(X)';  
     case 'sind'
        help = 'Sine of argument in degrees. sind(X)';  
     case 'sinh'
        help = 'Hyperbolic sine of argument. sinh(X)';  
     case 'skewness'
        help = ['Skewness. S = skewness(X) returns the sample skewness of the values in X.  For a vector input, S is the third central moment of X, divided by the cube of its standard deviation.',...  
                'For a matrix input, S is a row vector containing the sample skewness of each column of X.  For N-D arrays, skewness operates along the first non-singleton dimension'];  
     case 'sort'
        help = ['Sort in ascending or descending order. For vectors, sort(X) sorts the elements of X in ascending order. For matrices, sort(X) sorts each column of X in ascending order.',...
                'For N-D arrays, sort(X) sorts the along the first non-singleton dimension of X. When X is a cell array of strings, sort(X) sorts the strings in ASCII dictionary order'];  
     case 'sqrt'
        help = 'Square root.sqrt(X) is the square root of the elements of X. Complex results are produced if X is not positive';  
     case 'std'
        help = ['Standard deviation. For vectors, Y = std(X) returns the standard deviation.  For matrices, Y is a row vector containing the standard deviation of each column.',...  
                'For N-D arrays, std operates along the first non-singleton dimension of X'];  
     case 'stdise'
        help = ['Standardise data of the object by subtracting mean and dividing by std deviation.',...
                'Input: obj: An object of class nb_ts',...
                'flag : - 0 : normalises by N-1 (Default)',...
                '       - 1 : normalises by N',....  
                'Where N is the sample length.',...
                'stdise(obj,flag)'];
     case 'sum'
        help = ['Sum of elements. S = sum(X) is the sum of the elements of the vector X. If X is a matrix, S is a row vector with the sum over each',...
                'column. For N-D arrays, sum(X) operates along the first non-singleton dimension'];  
     case 'sumoaf'
        help = ['Take the sum over a lower frequency. I.e. if frequency is quartely, this function can sum over all the quarters of a year. And it will return the sum over the year in',... 
                'all quarters of the that year',...
                'sumOAF(obj,sumFreq) where sumFreq is the frequency to sum over'];
     case 'tan'
        help = 'Tangent of argument in radians. tan(X)';  
     case 'tand'
        help = 'Tangent of argument in degrees. tand(X)';    
     case 'tanh'
        help = 'Hyperbolic tangent of argument. tanh(X)';    
     case 'times'
        help = '.*  Array multiply. X.*Y denotes element-by-element multiplication.  X and Y must have the same dimensions unless one is a scalar. A scalar can be multiplied into anything';  
     case 'uminus'
        help = '- Unary minus. -A negates the elements of A';   
     case 'uplus'
        help = '+ Unary plus. +A for numeric arrays is A';  
     case 'var'
        help = ['Variance. For vectors, Y = var(X) returns the variance of the values in X. For matrices, Y is a row vector containing the variance of each column of X.',...
                'For N-D arrays, var operates along the first non-singleton dimension of X'];  
    otherwise 
        error('Unsupported function')
end
