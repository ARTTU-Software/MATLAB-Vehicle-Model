# Project instructions

When working on MATLAB code in this repository, read the applicable rules before making changes or reviewing code.

- For MATLAB code and code reviews, use [MATLAB Coding Standards](.agent-docs/rules/matlab-coding-standards.md).
- For plain-text MATLAB Live Scripts, also use [MATLAB Plain Text Live Script Generation](.agent-docs/rules/live-script-generation.md).
- For MATLAB performance work, also use [MATLAB Performance Optimization](.agent-docs/rules/matlab-performance-optimization.md).

The rules are from MathWorks' [MATLAB AI Coding Rules](https://github.com/matlab/rules) and are included under [CC BY 4.0](.agent-docs/rules/LICENSE.txt).

Use the [MATLAB prompt library](.agent-docs/prompts/README.md) as a reference when the user requests a matching task.

When asked to verify a Simulink implementation against supplied equations, use the MATLAB Agentic Toolkit's `matlab-use-symbolic-math` skill when available and helpful for deriving an independent reference. Map the equation terms to the existing blocks, signals, and parameters. Compare signs, units, and representative outputs under the same assumptions and initial conditions. Keep the model's current implementation form unless the user requests a change.
