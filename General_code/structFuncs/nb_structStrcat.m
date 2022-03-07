function [coeff_out] = nb_structStrcat(coeff_in, what, where)
% Syntax:
%
% [coeff_out] = nb_structStrcat(coeff_in, what, where)
%
% Description:
%
% Use this function to add letters in front or at the end of the 
% fieldnames of a struct. It adds 'coeff' at the front as default. 
% 
% Input:
% 
% - coeff_in : The struct in question.
%
% - what     : The letters to add. Default is to add 'coeff'. 
%
% - where    : Where to add the letters: 'front' or 'back'. Default is
%              'front'.
% 
% Output: 
% 
% coeff_out  :  A struct with the updated names. 
%
% Example: 
%
% coeff_out = nb_structStrcat(coeff_in,'letters','back')
%
% Written by Erling Motzfeldt Kravik

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        where='front';
        if nargin < 2
            what = 'coeff';
        end
    end

    fn = fieldnames(coeff_in);
    if strcmpi(where,'front')
        fn = strcat(what,fn);
    else
        fn = strcat(fn,what);
    end
    values    = struct2cell(coeff_in);
    coeff_out = cell2struct(values,fn);

end

  

