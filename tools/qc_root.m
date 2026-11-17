function r = qc_root
%QC_ROOT  Root folder of the quarter car project 
%   Scripts use it to find results/, wherever MATLAB's current folder is.
here = fileparts(mfilename('fullpath'));
r = here;
while ~isfile(fullfile(r, 'new_model.prj'))
    up = fileparts(r);
    if strcmp(up, r), r = here; return; end   % reached the drive root: fall back
    r = up;
end
end
