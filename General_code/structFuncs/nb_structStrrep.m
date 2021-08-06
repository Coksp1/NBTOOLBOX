function [coeff_out] = nb_structStrrep(coeff_in, old, new)
% Syntax:
%
% [coeff_out] = nb_structStrrep(coeff_in, old, new)
%
% Description:
%
% Use this function to remove certain letters in the fieldnames of a 
% struct. It removes 'coeff' as default. 
% 
% Input:
% 
% - coeff_in : The struct in question.
%
% - old      : The letters to remove. Default is 'coeff'. 
%
% - new      : The letters to add. Default is ''.
% 
%
% Output: 
% 
% coeff_out  :  A struct with the updated names. 
%
% Example: 
%
% coeff_out = nb_structStrcat(coeff_in,'LAMBDA','rho')
%
% Written by Erling M. Kravik

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 1
        old = 'coeff';
        new = '';
    end

    fn        = fieldnames(coeff_in);
    fn        = strrep(fn,old,new);
    values    = struct2cell(coeff_in);
    coeff_out = cell2struct(values,fn);

end

  

