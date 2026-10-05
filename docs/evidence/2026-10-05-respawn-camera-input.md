# Perfect Jump respawn camera/input runtime acceptance - 2026-10-05

A Studio-only client QA controller now validates the actual client state after the server's Retry respawn.

Runtime evidence after the replacement character appeared:

- `respawn_camera_reset`: pass
  - camera is Scriptable;
  - CameraSubject is the new current Humanoid;
  - camera controller is snapped to the new character;
  - current-platform and target-platform positions are loaded.
- `respawn_input_reset`: pass
  - `Charging == false`;
  - phase is `Ready`;
  - no UI modal is left open.
- Client QA emitted `[PerfectJumpClientQA] COMPLETE`.
- Server QA independently emitted `journey_retry_respawn` pass and later `[PerfectJumpQA] COMPLETE`.

The client QA controller is guarded by `RunService:IsStudio()` and `RuntimeQaConfig.EnabledInStudio`; the committed runtime-QA flag remains disabled.
