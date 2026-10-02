# Stanley reference geometry

`sm_car/Driver/Closed Loop/Driver/Lateral Driver/Stanley/Stanley_Local_Reference`
uses the `sm_car_stanley_reference` MATLAB System class (code-generation mode).

The block projects the front axle onto the nominal `Maneuver.Trajectory`
polyline for forward driving, or the rear axle for reverse driving. It
interpolates the supplied path yaw between the selected samples with angular
wrap handling. Duplicate consecutive position samples are skipped.

The current pose entering this subsystem describes the vehicle body reference
frame (`VehBus.World`). The block transforms it to the rear axle using
`Vehicle.Chassis.Body.sAxle2.Value`, as required by the MathWorks controller.
Front-axle projection uses `sAxle1.Value`. These are planar yaw transforms,
consistent with the Stanley bicycle-model geometry.

The existing radian-to-degree adapters and steering output conversion remain
in place. Steering ratio, gains, steering limits, startup velocity treatment,
longitudinal control, and speed profile were not changed.

## Plotting

- `StanleyLocalRefPose_rad`: actual local steering target `[x y yaw]`.
- `StanleyRearAxlePose_rad`: rear-axle current pose `[x y yaw]`.
- `DrvBus.Reference.ayaw`: still the original **preview** heading used by the
  visualization, not Stanley's local yaw target.

Both new signals are logged; positions are metres and yaw is radians.
Changing `Maneuver.xPreview` no longer advances Stanley's steering target.

## Scope and limitations

This adapter uses the nominal maneuver trajectory, not the optional runtime
obstacle-avoidance trajectory overrides. If obstacle avoidance is enabled,
the adapter must first be supplied with that same active trajectory.
Nearest-point selection is geometric; at intersecting or overlapping path
branches it does not maintain route-progress memory. Closed trajectories
must contain their closing segment in the supplied samples.

Compilation and geometry checks do not establish full-lap stability. Steering
calibration and vehicle-limit validation remain separate tasks.

## Validation on 2026-09-17

- Full model diagram update passed.
- Forward/reverse projection, rear-axle offset, duplicate samples, and heading
  wrap checks passed.
- Replaying the recorded position near 3.4 s gives a local yaw target of about
  -1.6 degrees, replacing the prematurely advanced preview target near 31 degrees.
- A requested 5 s run stopped on its 120 s execution timeout at 4.21 s.
  Peak logged lateral deviation was about 0.60 m, but absolute roll reached
  59 degrees and tyre validity-limit warnings occurred. Stability is NOT
  validated; no steering tuning or speed reduction was applied.
- The two new signal logging flags were verified enabled after that run;
  those signals will appear in the next simulation, not in the validation
  dataset already returned.
