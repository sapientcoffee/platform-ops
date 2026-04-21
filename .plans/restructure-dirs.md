# Directory Restructuring Plan

## Objective
Reorganize the project repository to logically group all Cloud Workstation images under a new `cloudworkstations` directory and GCE configurations under a new `gce` directory.

## Key Files & Context
- Current Cloud Workstation directories: `CloudWorkstations`, `CloudWorkstations-Jupyter`, `CloudWorkstations-Sway`
- Current GCE directory: `antigravity-remote-desktop-gce`
- Test configurations: `test-base-inspect.yaml`, `test-jupyter.yaml`
- Documentation: `README.md` (needs updating to reflect new paths)

## Proposed Changes

1.  **Create New Directories:**
    -   `mkdir cloudworkstations`
    -   `mkdir gce`
2.  **Move and Rename Workstation Images:**
    -   Move `CloudWorkstations` to `cloudworkstations/base`
    -   Move `CloudWorkstations-Jupyter` to `cloudworkstations/jupyter`
    -   Move `CloudWorkstations-Sway` to `cloudworkstations/sway`
3.  **Move Test Files:**
    -   Move `test-base-inspect.yaml` to `cloudworkstations/base/`
    -   Move `test-jupyter.yaml` to `cloudworkstations/jupyter/`
4.  **Move GCE Configurations:**
    -   Move `antigravity-remote-desktop-gce` to `gce/antigravity-remote-desktop`
5.  **Update Documentation:**
    -   Update links in `README.md` to point to the new directory structure (e.g., updating the link for the base Cloud Workstations folder).

## Verification & Testing
- Run `ls -l` to verify the new structure.
- Check `git status` to ensure files were moved using `git mv` (to preserve history).
- Verify `README.md` links are correct.