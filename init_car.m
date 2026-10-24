%% Quarter Car Model - Initialization Script 
clear; clc;


excel_file = 'Vehicle_Parameters_QuarterCar.xlsx';
cache_file = 'cached_params.m';


if ~isfile(excel_file)
    error('The Excel file was not found in the current folder!');
end


excel_info = dir(excel_file);
excel_date = excel_info.datenum;


needs_update = true;

if isfile(cache_file)
    cache_info = dir(cache_file);
    if cache_info.datenum > excel_date
        needs_update = false;
    end
end

%% Generate Cache File if the excel file was modified 
if needs_update
    disp('Modifications detected in Excel. Reading data and generating new cache...');

   
    T = readtable(excel_file, 'Sheet', 'Parameters');

%cache file
    fid = fopen(cache_file, 'w');
    fprintf(fid, '%% Auto-generated file from Excel. DO NOT EDIT MANUALLY!\n\n');

    
    for i = 1:height(T)
        category = char(T.Category{i});
        param = char(T.Parameter{i});
        val_x = T.Value_X(i);
        val_y = T.Value_Y(i);
        val_z = T.Value_Z(i);
        unit = char(T.Unit{i});

     
        if ~isnan(val_y) && ~isnan(val_z)
            fprintf(fid, '%s.%s.value = [%g, %g, %g];\n', category, param, val_x, val_y, val_z);
        else
          
            fprintf(fid, '%s.%s.value = %g;\n', category, param, val_x);
        end
       
        fprintf(fid, '%s.%s.unit = ''%s'';\n', category, param, unit);
    end

 
    fprintf(fid, '\n%% Automatic Calculations for Simscape\n');
    fprintf(fid, 'Hardpoints.hp_pushrod_in.value = Hardpoints.hp_bcr_pushrod.value;\n');
    fprintf(fid, 'Hardpoints.pushrod_length.value = norm(Hardpoints.hp_pushrod_out.value - Hardpoints.hp_pushrod_in.value);\n');

    fclose(fid);
    disp('Cache generated successfully!');
else
    disp('No changes detected in Excel. Loading parameters from cache...');
end

%% Load Data into Workspace
run(cache_file);

disp('>>> init_car script loaded successfully!');