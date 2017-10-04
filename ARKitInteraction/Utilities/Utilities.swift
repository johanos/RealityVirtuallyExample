/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions and type extensions used throughout the projects.
*/

import Foundation
import ARKit

extension float3 {
    static func lerp(a: float3, b: float3, t: Float) -> float3 {
        let xLerp = lerpf(a: a.x, b: b.x, t: t)
        let yLerp = lerpf(a: a.y, b: b.y, t: t)
        let zLerp = lerpf(a: a.z, b: b.z, t: t)
        
        return float3(x: xLerp, y: yLerp, z: zLerp)
    }
    
    static func lerp(a: Double, b: Double, t: Double) -> Double {
        return a + (b - a) * t
    }
    
    static func lerpf(a: Float, b: Float, t: Float) -> Float {
        return a + (b - a) * t
    }
    
    mutating func normalize() {
        self = self.normalized()
    }

    
    func normalized() -> float3 {
        if self.length() == 0 {
            return self
        }
        
        return self / self.length()
    }
    
    func length() -> Float {
        return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    }

}

extension RangeReplaceableCollection where IndexDistance == Int {
    mutating func keepLast(_ elementsToKeep: Int) {
        if count > elementsToKeep {
            self.removeFirst(count - elementsToKeep)
        }
    }
}

extension Array where Iterator.Element == CGFloat {
    var average: CGFloat? {
        guard !isEmpty else {
            return nil
        }
        
        var ret = self.reduce(CGFloat(0)) { (cur, next) -> CGFloat in
            var cur = cur
            cur += next
            return cur
        }
        let fcount = CGFloat(count)
        ret /= fcount
        return ret
    }
}

extension Array where Iterator.Element == SCNVector3 {
    var average: SCNVector3? {
        guard !isEmpty else {
            return nil
        }
        
        var ret = self.reduce(SCNVector3Zero) { (cur, next) -> SCNVector3 in
            var cur = cur
            cur.x += next.x
            cur.y += next.y
            cur.z += next.z
            return cur
        }
        let fcount = Float(count)
        ret.x /= fcount
        ret.y /= fcount
        ret.z /= fcount
        
        return ret
    }
}

extension Array where Iterator.Element == float3 {
    var average: float3? {
        guard !isEmpty else {
            return nil
        }
        
        var ret = self.reduce(float3(0.0, 0.0, 0.0)) { (cur, next) -> float3 in
            var cur = cur
            cur.x += next.x
            cur.y += next.y
            cur.z += next.z
            return cur
        }
        let fcount = Float(count)
        ret.x /= fcount
        ret.y /= fcount
        ret.z /= fcount
        
        return ret
    }
}

// MARK: - float4x4 extensions

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
    */
    var translation: float3 {
        let translation = columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}


// MARK: - CGPoint extensions

extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
	init(_ vector: SCNVector3) {
		x = CGFloat(vector.x)
		y = CGFloat(vector.y)
	}

    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
		return sqrt(x * x + y * y)
	}
}
