import Foundation
import MetricKit
import os
import Darwin
import QuartzCore

@available(iOS 13.0, *)
final class PerformanceMonitor: NSObject {
    static let shared = PerformanceMonitor()

    private let logger = Logger(subsystem: "com.jellysave", category: "performance")
    private let metricManager = MXMetricManager.shared
    private var launchStart: TimeInterval?
    private var memorySamples: [Double] = []
    private var memoryTimer: Timer?
    private let syncQueue = DispatchQueue(label: "com.jellysave.performance.queue", qos: .utility)

    private override init() {
        super.init()
    }

    func start() {
        metricManager.add(self)
        startMemoryTracking()
    }

    func stop() {
        metricManager.remove(self)
        stopMemoryTracking()
    }

    func markLaunchStart() {
        launchStart = CACurrentMediaTime()
    }

    func markLaunchEnd() {
        guard let start = launchStart else { return }
        let duration = CACurrentMediaTime() - start
        logger.info("App launch completed in \(duration, format: .fixed(precision: 3)) seconds")
        launchStart = nil
    }

    func measure<T>(operation name: String, execute work: () throws -> T) rethrows -> T {
        let start = CFAbsoluteTimeGetCurrent()
        let result = try work()
        let duration = CFAbsoluteTimeGetCurrent() - start
        logQueryDuration(name: name, duration: duration)
        return result
    }

    private func logQueryDuration(name: String, duration: CFTimeInterval) {
        syncQueue.async { [logger] in
            if duration > 0.2 {
                logger.warning("Query \(name, privacy: .public) took \(duration, format: .fixed(precision: 3))s")
            } else {
                logger.debug("Query \(name, privacy: .public) took \(duration, format: .fixed(precision: 3))s")
            }
        }
    }

    // MARK: - Memory Tracking

    private func startMemoryTracking() {
        guard memoryTimer == nil else { return }
        memoryTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.sampleMemory()
        }
    }

    private func stopMemoryTracking() {
        memoryTimer?.invalidate()
        memoryTimer = nil
        memorySamples.removeAll()
    }

    private func sampleMemory() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { pointer in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), pointer, &count)
            }
        }

        guard kerr == KERN_SUCCESS else { return }
        let usedMB = Double(info.resident_size) / (1024 * 1024)
        memorySamples.append(usedMB)
        if memorySamples.count > 50 { memorySamples.removeFirst() }
        logger.debug("Memory usage: \(usedMB, format: .fixed(precision: 2)) MB")
    }
}

@available(iOS 13.0, *)
extension PerformanceMonitor: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        payloads.forEach { payload in
            if let histogram = payload.applicationLaunchMetrics?.histogrammedTimeToFirstDraw,
               let launch = averageDuration(from: histogram) {
                logger.info("MetricKit launch average: \(launch, format: .fixed(precision: 3))s")
            }
            if let hitchRatio = payload.animationMetrics?.scrollHitchTimeRatio {
                let value = hitchRatio.value
                logger.info("Animation hitch ratio: \(value, format: .fixed(precision: 3))")
            }
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {}

    private func averageDuration(from histogram: MXHistogram<UnitDuration>) -> Double? {
        var total: Double = 0
        var count: Double = 0
        histogram.bucketEnumerator.forEach { bucket in
            guard let bucket = bucket as? MXHistogramBucket<UnitDuration> else { return }
            let start = bucket.bucketStart.converted(to: UnitDuration.seconds).value
            let end = bucket.bucketEnd.converted(to: UnitDuration.seconds).value
            let midPoint = (start + end) / 2
            let bucketCount = Double(bucket.bucketCount)
            total += midPoint * bucketCount
            count += bucketCount
        }
        return count > 0 ? total / count : nil
    }
}
