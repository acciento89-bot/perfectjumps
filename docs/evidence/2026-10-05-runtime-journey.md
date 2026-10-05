# Perfect Jump runtime journey acceptance - 2026-10-05

Fresh local Studio QA now exercises the complete server-side runtime journey on the same production launch/landing/retry paths:

- `journey_spawn_ready`: player has a character and the round is Ready.
- `journey_charge_release`: midpoint charge uses the production launch path and reaches Airborne with the expected velocity.
- `journey_landing_ready`: production landing path returns a Perfect landing and settles back to Ready.
- `journey_failure`: failure transitions to GameOver.
- `journey_retry_start`: Retry is accepted after the configured delay guard.
- `journey_retry_respawn`: a distinct replacement character appears, the round is Ready again, and the lane resets to platform 0.

The run then continued through the existing min/mid/max charge matrix, 100-release repeatability sample, landing-grade matrix, 60-land climb, PB/combo, cosmetics, Daily, failure/Retry, Revive and persistent-payload checks and ended with `[PerfectJumpQA] COMPLETE`.

No CreatorError, Script Error, attempt-to-call, or Infinite-yield match was returned by the filtered Perfect Jump runtime QA log.
