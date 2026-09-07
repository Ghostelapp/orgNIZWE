import Foundation
import HealthKit

@MainActor
final class HealthKitService: ObservableObject {
    @Published var isAuthorized: Bool = false
    
    private let healthStore = HKHealthStore()
    
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ].compactMap { $0 as HKObjectType? }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            isAuthorized = true
            return true
        } catch {
            isAuthorized = false
            return false
        }
    }
    
    func fetchTodayStepCount() async -> Double? {
        guard isAuthorized, isAvailable else { return nil }
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return nil }
        
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, _ in
                let value = result?.sumQuantity()?.doubleValue(for: .count())
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
    
    func fetchLastNightSleep() async -> Double? {
        guard isAuthorized, isAvailable else { return nil }
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        
        let calendar = Calendar.current
        let end = calendar.startOfDay(for: Date())
        guard let start = calendar.date(byAdding: .day, value: -1, to: end) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                let total = samples?.compactMap { $0 as? HKCategorySample }
                    .reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) } ?? 0
                continuation.resume(returning: total / 3600.0)
            }
            healthStore.execute(query)
        }
    }
}
