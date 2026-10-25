function State_Vec = Vehicle_UKF_Step(yMeas, u)
    %#codegen

    
    % 1. ukf object
    persistent ukf_obj isInitialized
    
    % 2. Initialize on the very first function call
    if isempty(isInitialized)
        % Call your custom initialization script/function
        ukf_obj = UKF_Init(); 
        
        % Set the flag so this block never runs again
        isInitialized = true; 
    end
    
    % 3. Run the filter
    % Pass the ukf object, the measurements, and the inputs
    %-------------------------------------------
    % Measurement vector 
    % - 1. GPS velocity [m/s]
    % - 4. IMU angular velocity on Z [rad/s]
    % - 5. IMU acceleration on X [m/s^2]
    % - 6. IMU acceleration on Y [m/s^2]
    % - 7. Front Left wheel speed [rad/s]    
    % - 8. Front Right wheel speed [rad/s]
    % -------------------------------------------
    % Input vector 
    % - 1. Steering wheel [rad]
    % - 2. Rear Left wheel speed [rad/s]
    % - 3. Rear Right wheel speed [rad/s]
    % -------------------------------------------
    % State Vector 
    % - 1. Velocity on X [m/s]
    % - 2. Side Slip angle [deg]
    % - 3. Rotation on Z [rad]
    % - 4. Angular velocity on Z [rad/s]
    % - 5. Acceleration on X [m/s^2]
    % - 6. Acceleration on Y [m/s^2]
    % - 7. Road friction coeff [~]
    % -------------------------------------------
    
    State_Vec = UKF(ukf_obj, yMeas, u);
    
end