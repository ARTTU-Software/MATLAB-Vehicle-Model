function write_study_plan(studyFolder, cfg, stamp)
%write_study_plan - Write the Constant Steer plan for user review
%   write_study_plan(studyFolder, CFG, STAMP) writes study_plan.md at
%   the prepared study root studyFolder. CFG is the expanded study
%   configuration and STAMP is its local preparation timestamp text.
%   The plan records cases, maneuver commands, outputs and pending
%   approvals. Existing plan text at that destination is replaced.
%   It has no return value and never opens a model or simulates.
%
%   Example: called by prepare_study after saving the baseline
%       write_study_plan(studyFolder, cfg, stamp);
%
%   See also prepare_study, study_config

runLines = strings(height(cfg.runs), 1);
for k = 1:height(cfg.runs)
    row = cfg.runs(k, :);
    runLines(k) = sprintf('| %s | %s | %g | %g |', ...
        row.ID, row.Controller, row.Steer_deg, row.Stop_s);
end
plan = [
    "# " + string(cfg.name)
    ""
    "Prepared " + string(stamp) + " (" + string(cfg.timezone) + "), " + string(computer) + "."
    "Inputs: `study_inputs.json`; every angle is combined with every controller."
    "Execution: sequential, using isolated copies of the saved baseline."
    ""
    "## Review and approvals"
    "Show historical Skidpad previews and obtain approval for short validation."
    "Validation is 1 s per case: check applied inputs and early logging only."
    "It does not test the later steering response."
    "Present validation findings and obtain a separate approval for the full study."
    "An exception requires an explicit waiver for this new request."
    ""
    "## Run list"
    "| ID | Controller | Steering wheel (deg) | Full time limit (s) |"
    "| --- | --- | --- | --- |"
    runLines
    ""
    "## Maneuver and temporary changes"
    "Change only the nonzero angles in `MDatabase.Turn.FSAE_Achilles`."
    "Then run the full hyperlink: `sm_car_config_maneuver('sm_car','turn');`."
    "Keep native throttle/braking: steer 5-5.2 s, throttle release 10-10.1 s, brake 11-11.2 s."
    "Select the requested controller temporarily; verify its active choice after initialization."
    "For V3, verify the saved estimator is enabled; do not override its UKF settings."
    "Any ModelStop is completed. Only label excessive roll or lateral-deviation stop flags."
    "Other normal early endings need no reason label; retain their actual stop time."
    "Errors, manual stops, timeouts and pauses remain incomplete."
    ""
    "## Outputs"
    "Use VehBus.Chassis.Body.CG: nYaw (rad/s to deg/s), gy (m/s^2), aSideSlip (rad to deg)."
    "Save selected MAT signals with native timestamps, three PNG comparisons and a CSV peak table."
    "Extrema use the full recorded interval; peak magnitude in g uses 9.80665 m/s^2."
    "Compare actual recording windows. Do not rank configurations or create a narrative report."
    "Keep JSON, code, state and baseline provenance. Remove validation data after full export."
    "Shared inventory: `../../inventory/saved/`; shared guide: `../../MODEL_WORKSPACE.md`."
    "Missing saved definitions remain explicit; runtime availability awaits validation."
];
writelines(plan, fullfile(studyFolder, 'study_plan.md'));

end
