//
//  TGGroundTracker.swift
//  Travel GO
//
//  Created by Mai Anh Vu on 9/30/17.
//  Copyright © 2017 Mai Anh Vu. All rights reserved.
//

import UIKit
import ARKit

class TGGroundTracker: NSObject {

    //-------------------------------------------------------------------------
    // MARK: - Properties
    //-------------------------------------------------------------------------
    private var anchorToPlaneMap = [ARPlaneAnchor:SCNNode]()

    private let shouldDebugPlanes: Bool = false

    //-------------------------------------------------------------------------
    // MARK: - Public Interface
    //-------------------------------------------------------------------------
    func handleRenderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let planeGeometry = SCNPlane(width:  CGFloat(planeAnchor.extent.x),
                                         height: CGFloat(planeAnchor.extent.y))
            if shouldDebugPlanes {
                let planeMaterial = SCNMaterial()
                planeMaterial.diffuse.contents = UIColor.green
                planeMaterial.lightingModel = .phong
                planeGeometry.materials = [planeMaterial]
            }

            let planeNode = SCNNode(geometry: planeGeometry)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.y)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            node.addChildNode(planeNode)
            anchorToPlaneMap[planeAnchor] = planeNode
        }
    }

    func handleRenderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = anchorToPlaneMap[planeAnchor],
            let planeGeometry = planeNode.geometry as? SCNPlane {

            planeGeometry.width = CGFloat(planeAnchor.extent.x)
            planeGeometry.height = CGFloat(planeAnchor.extent.z)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.y)
        }
    }

    func handleRenderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            anchorToPlaneMap[planeAnchor]?.removeFromParentNode()
            anchorToPlaneMap.removeValue(forKey: planeAnchor)
        }
    }
}
