---
name: Bug report
about: Create a report to help us fix and/or improve the testbenches
title: "[BUG]"
labels: bug
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Required information**
Steps to reproduce the behavior:
- Vivado tool version
- HDL Release version [e.g. hdl_2023_r2]
- Testbenches Release version [e.g. tb_2023_r2]
- Configuration used (parameter values if it's a custom configuration)
- system_project.log
- parameters.log
- test_program*.log if available
- Randomization value (In test_program*.log or TCL console in GUI mode look for: # random sv_seed = <value>)
- Randomization state (In test_program*.log or TCL console in GUI mode look for: [INFO] @ 0 ns: Randomization state: <value>)

**Additional context**
Add any other context about the problem here.