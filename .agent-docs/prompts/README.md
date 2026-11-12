# MATLAB prompts for the analytical vehicle model

Choose a prompt and give Codex the maneuver, simulation runs, or function you want it to work with. The paths in the prompts are relative to this repository.

## Programming — check model invariants

> Write reproducible MATLAB tests for the requested parameter calculation or model response in `analytical_models.slx`. Start with documented physics. For example, check that the two static axle loads sum to the vehicle weight. For response tests, state which model assumptions justify each expected result and when it applies. Exercise representative cases and valid boundaries. Use a fixed random seed for any sampled inputs, and report the failing input and tolerance.

Adapted from MathWorks' [Property-Based Testing](https://github.com/matlab/prompts/blob/main/prompts/programming/property-based-testing.md).

## Data visualization — compare 2-DOF and 3-DOF results

> Create a MATLAB figure comparing the 2-DOF and 3-DOF simulation results for the selected maneuver. Use `Data/Maneuvers_inputs/` to identify the matching inputs. Inspect the logged signals, units, and time vectors first. Use a tiled layout to compare shared signals such as speed, yaw rate, and lateral acceleration when available. Plot each run on its recorded time base. If computing a difference, align the runs over their shared time range and describe the interpolation. Label each panel with units and identify the maneuver and model variants.

Adapted from MathWorks' [Create Custom Multi-Panel Visualizations with Tiledlayout](https://github.com/matlab/prompts/blob/main/prompts/data-visualization/create-custom-tiledlayout.md).

## Data visualization — replay a maneuver

> Animate the vehicle trajectory for the selected double lane change, ramp steer, or skidpad run when position data is available. Use the recorded time vector for playback, label position axes with units, and keep the spatial scale equal across both axes. Create the path and vehicle marker once and update them during playback. If heading is available, show vehicle orientation using the recorded angle convention.

Adapted from MathWorks' [Create High-Performance Animated Plots](https://github.com/matlab/prompts/blob/main/prompts/data-visualization/create-animated-plots.md).

## App building — explore maneuver results

> Build a programmatic MATLAB app to compare saved runs of `analytical_models.slx`. Let the user select a maneuver and the available model variants. Show the selected results on labeled axes and report missing runs or signals in the app. Use `uifigure` and `uigridlayout`. Keep run loading and plotting logic separate from the UI callbacks so both can be reused outside the app.

Adapted from MathWorks' [Create Programmatic MATLAB App](https://github.com/matlab/prompts/blob/main/prompts/app-building/create-programmatic-app.md).

## Code generation — assess a MATLAB function for C/C++

> Assess the named MATLAB function for the specified C/C++ target. Identify its dependencies and unsupported operations, specify input sizes and types, and propose a parity check against MATLAB outputs on representative and boundary inputs. If the requested target is the `analytical_models.slx` model or a subsystem, assess it using the Simulink code generation workflow and identify the required products and target configuration.

Adapted from MathWorks' [Generate C Code from MATLAB](https://github.com/matlab/prompts/blob/main/prompts/code-generation/generate-c-code.md), which uses MATLAB Coder for MATLAB function entry points.

These templates adapt the [MathWorks MATLAB prompts](https://github.com/matlab/prompts) for this repository. The upstream material is licensed under [CC BY 4.0](https://github.com/matlab/prompts/blob/main/LICENSE.txt).
