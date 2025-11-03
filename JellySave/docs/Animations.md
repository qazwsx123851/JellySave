# Animation Components

## LottieView
Use `LottieView(name:loopMode:animationSpeed:)` to embed JSON animations shipped under `Resources/Lottie/`. The wrapper auto-plays and updates when the name changes.

```
LottieView(name: "celebration", loopMode: .playOnce)
    .frame(height: 200)
```

## SkeletonLoadingView
Wraps SkeletonView to expose a SwiftUI-friendly API.

```
SkeletonLoadingView(isAnimating: true)
    .frame(height: 80)
```

## CountingLabel
Animated numeric display supporting currency, percentage, and decimal formats.

```
CountingLabel(value: 0.72, style: .percentage(maximumFractionDigits: 1))
```

These components are designed to integrate with the shared theme colors and spacing constants.
