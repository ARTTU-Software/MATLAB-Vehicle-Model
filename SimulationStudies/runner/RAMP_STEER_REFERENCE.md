# Earlier Ramp Steer setup examples

Reference commands from the retired runner examples. Verify the current model hyperlink before adapting them for a new study. Full legacy runners were not runtime-validated and are no longer maintained as duplicate per-scenario scripts.

```matlab
MDatabase.Ramp_Steer.FSAE_Achilles = sm_car_maneuverdata_ramp_steer( ...
    row.Speed_kmh, row.SpeedTime_s, row.SpeedDistance_m, row.Steer_deg, ...
    row.Rise_s, row.Start_s, row.Duration_s);
assignin('base', 'MDatabase', MDatabase);
sm_car_config_maneuver(cfg.model, 'ramp steer');
```

The old comparison used Default and FLC_DYC_V3 at 20/30/40 degrees, 10 km/h, target-speed time 8 s, unused target distance NaN, steering rise 0.1 s, start 10 s, final duration 8 s and 19 s full limit. The simple example selected World.vx and converted m/s to km/h. The third generator argument is target distance, not turning radius; the generator holds the final steering angle. Reuse the shared Skidpad archive for preview layout only.
