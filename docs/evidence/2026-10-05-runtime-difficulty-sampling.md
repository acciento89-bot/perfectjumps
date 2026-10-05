# Perfect Jump runtime difficulty sampling - 2026-10-05

Fresh Studio QA sampled the actual generated lane at three progression points and validated each target through the same production `ReachabilityRules`.

- Early sample: current platform 0 → target 1, width `10`, horizontal distance `12.57395`, vertical delta `1.35`, landing radius `4.45`.
- Mid sample: current platform 20 → target 21, width `8`, horizontal distance `17.82782`, vertical delta `1.35`, landing radius `3.45`.
- Late sample: current platform 50 → target 51, width `5`, horizontal distance `17.41246`, vertical delta `1.35`, landing radius `1.95`.

All three targets passed production reachability. The progression check also verified target IDs `1/21/51` and the intended width pressure `10 > 8 > 5`.

The same Studio run completed the full PerfectJump QA harness and ended with `[PerfectJumpQA] COMPLETE`, with no filtered CreatorError/Script Error/attempt-to-call/Infinite-yield match.
