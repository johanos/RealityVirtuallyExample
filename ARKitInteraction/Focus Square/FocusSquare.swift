//
//  FocusSquare.swift
//  ARKitInteraction
//
//  Created by Johan Ospina on 10/2/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import ARKit

private let focusSquarePositionAvgCount = 10

class FocusSquare: SCNNode {
// 1
    enum State {
        case initializing
        case featuresDetected(anchorPosition: float3, camera: ARCamera?)
        case planeDetected(anchorPosition: float3, planeAnchor: ARPlaneAnchor, camera: ARCamera?)
    }
    
    /// The most recent position of the focus square based on the current state.
    var lastPosition: float3? {
        switch state {
        case .initializing: return nil
        case .featuresDetected(let anchorPosition, _): return anchorPosition
        case .planeDetected(let anchorPosition, _, _): return anchorPosition
        }
    }
    
    /// Called when a surface has been detected.
    private func displayAsConstant(at position: float3, camera: ARCamera?) {
        recentFocusSquarePositions.append(position)
        updateTransform(for: position, camera: camera)
        self.planeNode.childNodes[0].geometry?.firstMaterial?.setValue(0, forKeyPath: "shouldPulse")
    }
    
    /// Called when a plane has been detected.
    private func displayAsPulsing(at position: float3, planeAnchor: ARPlaneAnchor, camera: ARCamera?) {
        anchorsOfVisitedPlanes.insert(planeAnchor)
        recentFocusSquarePositions.append(position)
        updateTransform(for: position, camera: camera)
        self.planeNode.childNodes[0].geometry?.firstMaterial?.setValue(1, forKeyPath: "shouldPulse")
    }
    
    private func displayAsBillboard(){
        //Todo: make it face the user!
    }
    
    var state: State = .initializing {
        didSet {
            guard state != oldValue else { return }
            
            switch state {
            case .initializing:
                displayAsBillboard()
                
            case .featuresDetected(let anchorPosition, let camera):
                displayAsConstant(at: anchorPosition, camera: camera)
                
            case .planeDetected(let anchorPosition, let planeAnchor, let camera):
                displayAsPulsing(at: anchorPosition, planeAnchor: planeAnchor, camera: camera)
            }
        }
    }
// 1

// 2
    private var planeNode: SCNNode
    
    // Indicates the last position of grid on the plane.
    var lastPositionOnPlane: float3?
    
    // MARK: - Object Lifecycle
    
    init(planeNode: SCNNode) {
        self.planeNode = planeNode
        super.init()
        self.opacity = 0.0
        self.addChildNode(self.planeNode)
        lastPositionOnPlane = nil
        recentFocusSquarePositions = []
        anchorsOfVisitedPlanes = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func hide() {
        self.opacity = 0.0
    }
    
    func unhide() {
        self.opacity = 1.0
    }
 
// 2
    
// 3

    // use average of recent positions to avoid jitter
    private var recentFocusSquarePositions = [float3]()
    
    private var anchorsOfVisitedPlanes: Set<ARAnchor> = []
    
    private func updateTransform(for position: float3, camera: ARCamera?) {
        recentFocusSquarePositions.append(position)
        recentFocusSquarePositions.keepLast(focusSquarePositionAvgCount)
        
        // move to lerp of recent positions to avoid jitter
        if let avgPosition = self.recentFocusSquarePositions.average {
            var newPosition = float3.lerp(a: float3(self.position), b: avgPosition, t: 0.2)
            if newPosition.x.isNaN || newPosition.y.isNaN || newPosition.z.isNaN {
                newPosition = avgPosition
            }
            self.position = SCNVector3(newPosition)
        }
    }
 // 3
}


extension FocusSquare.State: Equatable {
    static func ==(lhs: FocusSquare.State, rhs: FocusSquare.State) -> Bool {
        switch (lhs, rhs) {
        case (.initializing, .initializing):
            return true
            
        case (.featuresDetected(let lhsPosition, let lhsCamera),
              .featuresDetected(let rhsPosition, let rhsCamera)):
            return lhsPosition == rhsPosition && lhsCamera == rhsCamera
            
        case (.planeDetected(let lhsPosition, let lhsPlaneAnchor, let lhsCamera),
              .planeDetected(let rhsPosition, let rhsPlaneAnchor, let rhsCamera)):
            return lhsPosition == rhsPosition
                && lhsPlaneAnchor == rhsPlaneAnchor
                && lhsCamera == rhsCamera
            
        default:
            return false
        }
    }
}


