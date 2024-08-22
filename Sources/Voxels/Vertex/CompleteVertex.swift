public struct CompleteVertex: Hashable, Sendable {
    var position: SIMD3<Float>
    var normal: SIMD3<Float>
    var uv: SIMD2<Float>

    public init(position: SIMD3<Float>, normal: SIMD3<Float>? = nil, uv: SIMD2<Float>? = nil) {
        self.position = position
        if let normal {
            self.normal = normal.normalized()
        } else {
            self.normal = .zero
        }
        if let uv {
            self.uv = uv
        } else {
            self.uv = .zero
        }
    }

    /// Creates a new vertex with normal vector you provide.
    /// - Parameter normal: The normal to apply to the vertex.
    public func withNormal(_ normal: Vector) -> CompleteVertex {
        CompleteVertex(position: position, normal: normal, uv: uv)
    }

    /// Creates a new vertex with the value for the normal inverted.
    ///
    /// Call to flip the orientation of the face of the polygon.
    public func invertedNormal() -> CompleteVertex {
        CompleteVertex(position: position, normal: -normal, uv: uv)
    }

    /// Linearly interpolate between two vertices.
    ///
    /// Interpolation is applied to the position, texture coordinate and normal.
    public func lerp(_ other: CompleteVertex, _ t: Float) -> CompleteVertex {
        CompleteVertex(
            position: position.lerp(other.position, t),
            normal: normal.lerp(other.normal, t),
            uv: uv.lerp(other.uv, t)
        )
    }
}
