// Derived from MIT licensced code:
// https://github.com/kodecocodes/swift-algorithm-club/blob/master/Octree/Octree.playground/Sources/Octree.swift
// accessed at https://github.com/kodecocodes/swift-algorithm-club/tree/master
public struct AABBox {
    public var boxMin: Vector
    public var boxMax: Vector

    public init(boxMin: Vector, boxMax: Vector) {
        self.boxMin = boxMin
        self.boxMax = boxMax
    }

    public var boxSize: Vector {
        boxMax - boxMin
    }

    var halfBoxSize: Vector {
        boxSize / 2
    }

    var frontLeftTop: AABBox {
        let boxMin = boxMin + Vector(0, halfBoxSize.y, halfBoxSize.z)
        let boxMax = boxMax - Vector(halfBoxSize.x, 0, 0)
        return AABBox(boxMin: boxMin, boxMax: boxMax)
    }

    var frontLeftBottom: AABBox {
        let boxMin = boxMin + Vector(0, 0, halfBoxSize.z)
        let boxMax = boxMax - Vector(halfBoxSize.x, halfBoxSize.y, 0)
        return AABBox(boxMin: boxMin, boxMax: boxMax)
    }

    var frontRightTop: AABBox {
        let boxMin = boxMin + Vector(halfBoxSize.x, halfBoxSize.y, halfBoxSize.z)
        let boxMax = boxMax - Vector(0, 0, 0)
        return AABBox(boxMin: boxMin, boxMax: boxMax)
    }

    var frontRightBottom: AABBox {
        let boxMin = boxMin + Vector(halfBoxSize.x, 0, halfBoxSize.z)
        let boxMax = boxMax - Vector(0, halfBoxSize.y, 0)
        return AABBox(boxMin: boxMin, boxMax: boxMax)
    }

    var backLeftTop: AABBox {
        let boxMin = boxMin + Vector(0, halfBoxSize.y, 0)
        let boxMax = boxMax - Vector(halfBoxSize.x, 0, halfBoxSize.z)
        return AABBox(boxMin: boxMin, boxMax: boxMax)
    }

    var backLeftBottom: AABBox {
        let boxMin = boxMin + Vector(0, 0, 0)
        let boxMax = boxMax - Vector(halfBoxSize.x, halfBoxSize.y, halfBoxSize.z)
        return AABBox(boxMin: boxMin, boxMax: boxMax)
    }

    var backRightTop: AABBox {
        let boxMin = boxMin + Vector(halfBoxSize.x, halfBoxSize.y, 0)
        let boxMax = boxMax - Vector(0, 0, halfBoxSize.z)
        return AABBox(boxMin: boxMin, boxMax: boxMax)
    }

    var backRightBottom: AABBox {
        let boxMin = boxMin + Vector(halfBoxSize.x, 0, 0)
        let boxMax = boxMax - Vector(0, halfBoxSize.y, halfBoxSize.z)
        return AABBox(boxMin: boxMin, boxMax: boxMax)
    }

    public func contains(_ point: Vector) -> Bool {
        (boxMin.x <= point.x && point.x <= boxMax.x) && (boxMin.y <= point.y && point.y <= boxMax.y) && (boxMin.z <= point.z && point.z <= boxMax.z)
    }

    public func contains(_ box: AABBox) -> Bool {
        boxMin.x <= box.boxMin.x &&
            boxMin.y <= box.boxMin.y &&
            boxMin.z <= box.boxMin.z &&
            boxMax.x >= box.boxMax.x &&
            boxMax.y >= box.boxMax.y &&
            boxMax.z >= box.boxMax.z
    }

    public func isContained(in box: AABBox) -> Bool {
        boxMin.x >= box.boxMin.x &&
            boxMin.y >= box.boxMin.y &&
            boxMin.z >= box.boxMin.z &&
            boxMax.x <= box.boxMax.x &&
            boxMax.y <= box.boxMax.y &&
            boxMax.z <= box.boxMax.z
    }

    /* This intersect function does not handle all possibilities such as two beams
     of different diameter crossing each other half way. But it does cover all cases
     needed for an octree as the bounding box has to contain the given intersect box */
    public func intersects(_ box: AABBox) -> Bool {
        let corners = [
            Vector(boxMin.x, boxMax.y, boxMax.z), // frontLeftTop
            Vector(boxMin.x, boxMin.y, boxMax.z), // frontLeftBottom
            Vector(boxMax.x, boxMax.y, boxMax.z), // frontRightTop
            Vector(boxMax.x, boxMin.y, boxMax.z), // frontRightBottom
            Vector(boxMin.x, boxMax.y, boxMin.z), // backLeftTop
            Vector(boxMin.x, boxMin.y, boxMin.z), // backLeftBottom
            Vector(boxMax.x, boxMax.y, boxMin.z), // backRightTop
            Vector(boxMax.x, boxMin.y, boxMin.z), // backRightBottom
        ]
        for corner in corners {
            if box.contains(corner) {
                return true
            }
        }
        return false
    }

    public var description: String {
        "Box from:\(boxMin) to:\(boxMax)"
    }
}
