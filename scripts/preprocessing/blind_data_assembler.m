clc; clear all;

%% Define directories
% Get the current directory
current_directory = pwd;

% Define directory of the data
raw_data_directory = fullfile(current_directory, '..', '..', 'blind_data', 'raw');

% Define directory of the assembled data
assembled_data_directory = fullfile(current_directory, '..', '..', 'blind_data', 'assembled');

% List the samples that exists in the folder
samples = [1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14];

%% Data Stack
% Loop through all the folders
for n_sample = 1:length(samples)

    if n_sample == 1
        % If first sample, set the value to a variable

        % Load the displacement data
        displacement_data = load(fullfile(raw_data_directory, strcat('blind_u_sample_', int2str(samples(n_sample)), '.mat'))).um_ansys;

        % Add a dimension to the data so that it is a 3D matrix
        displacement_data = permute(displacement_data, [1, 3, 2]);

        % Move the shapes around such that the first dimension is the number of samples
        displacement_data = permute(displacement_data, [2, 3, 1]);

        % Load the void data
        void_data = load(fullfile(raw_data_directory, strcat('void_blind_sample_', int2str(samples(n_sample)), '.mat'))).Void_Data;

    else
        % Stack the displacement data

        % Load the displacement data
        additional_displacement_data = load(fullfile(raw_data_directory, strcat('blind_u_sample_', int2str(samples(n_sample)), '.mat'))).um_ansys;

        % Add a dimension to the data so that it is a 3D matrix
        additional_displacement_data = permute(additional_displacement_data, [1, 3, 2]);

        % Move the shapes around such that the first dimension is the number of samples
        additional_displacement_data = permute(additional_displacement_data, [2, 3, 1]);

        % Vertically stack the displacement Data
        displacement_data = cat(1, displacement_data, additional_displacement_data);

        % Load the void data
        additional_void_data = load(fullfile(raw_data_directory, strcat('void_blind_sample_', int2str(samples(n_sample)), '.mat'))).Void_Data;

        % Vertically stack the void Data
        void_data = cat(1, void_data, additional_void_data);

    end

end

%% Take every third timestep
displacement_data = displacement_data(:, 1:3:end, :);

%% Save the data
% Save the displacement data
save(fullfile(assembled_data_directory, 'blind_displacement_data.mat'), 'displacement_data');

% Save the void data
save(fullfile(assembled_data_directory, 'blind_void_data.mat'), 'void_data');