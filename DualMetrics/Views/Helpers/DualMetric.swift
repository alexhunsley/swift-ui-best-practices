/// Convenience for having metrics with a default and a small option, to use with our dual-sized designs.
public struct DualMetric<T> {
    private let small: T
    private let `default`: T

    public init(small: T, default: T) {
        self.small = small
        self.default = `default`
    }

    // Ergonomics: allow dualetricInstance(true/false) to be called without using a func name
    public func callAsFunction(_ useDefaultDesign: Bool) -> T {
        useDefaultDesign ? `default` : small
    }
}
