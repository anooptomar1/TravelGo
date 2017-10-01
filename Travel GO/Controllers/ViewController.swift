//
//  ViewController.swift
//  Travel GO
//
//  Created by Mai Anh Vu on 9/30/17.
//  Copyright © 2017 Mai Anh Vu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, CAAnimationDelegate {

    //-------------------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------------------
    @IBOutlet var sceneView: ARSCNView!

    //-------------------------------------------------------------------------
    // MARK: - Properties
    //-------------------------------------------------------------------------
    private let acmtBgSound = SCNAudioSource(fileNamed: "art.scnassets/achievement_background.wav")!
    private let acmtFgSound = SCNAudioSource(fileNamed: "art.scnassets/achievement_foreground.wav")!
    private let infoSound = SCNAudioSource(fileNamed: "art.scnassets/info.aif")!

    private var existingPlanes: [SCNNode] = []
    private var shrinkingPlane: SCNNode?

    //-------------------------------------------------------------------------
    // MARK: - Initialization
    //-------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene

        // Configure the scene view
        // sceneView.debugOptions = [.showWireframe]

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    //-------------------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------------------
    @IBAction func didTapInScene(using tapGestureRecognizer: UITapGestureRecognizer) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }

        let tapLocation = tapGestureRecognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, options: [SCNHitTestOption.firstFoundOnly: true])
        if let result = hitTestResults.first,
            let _ = result.node.geometry as? SCNPlane {

            addShrinkAnimation(to: result.node)
            shrinkingPlane = result.node
            return
        }


        let signboardPlane = SCNPlane(width: 0.13, height: 0.28)
        let signboardForegroundMaterial = SCNMaterial()

        signboardForegroundMaterial.diffuse.contents = #imageLiteral(resourceName: "eiffel_signboard")
        signboardForegroundMaterial.isDoubleSided = false
        signboardForegroundMaterial.lightingModel = .constant

        signboardPlane.materials = [signboardForegroundMaterial]
        let signboardNode = SCNNode(geometry: signboardPlane)
        sceneView.scene.rootNode.addChildNode(signboardNode)

        var tMatrix = matrix_identity_float4x4
        tMatrix.columns.3.z = -0.3
        signboardNode.simdTransform = matrix_multiply(currentFrame.camera.transform, tMatrix)

        // Add sound effects
        signboardNode.addAudioPlayer(SCNAudioPlayer(source: infoSound))
        // signboardNode.addAudioPlayer(SCNAudioPlayer(source: acmtBgSound))
        

        // Add animations
        let animation = CABasicAnimation(keyPath: #keyPath(SCNNode.scale))
        animation.fromValue = SCNVector3Make(1, 1, 1)
        animation.toValue   = SCNVector3Make(1.1, 1.1, 1)
        animation.autoreverses = true
        animation.isRemovedOnCompletion = true
        animation.duration = 0.1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        signboardNode.addAnimation(animation, forKey: "tada")
    }

    private func addShrinkAnimation(to node: SCNNode) {
        let popAnimation = CABasicAnimation(keyPath: #keyPath(SCNNode.scale))
        popAnimation.fromValue = SCNVector3Make(1, 1, 1)
        popAnimation.toValue   = SCNVector3Make(1.075, 1.075, 1)
        popAnimation.isRemovedOnCompletion = true
        popAnimation.duration = 0.1
        popAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)

        let shrinkAnimation = CABasicAnimation(keyPath: #keyPath(SCNNode.scale))
        shrinkAnimation.fromValue = popAnimation.toValue
        shrinkAnimation.toValue   = SCNVector3Make(0, 0, 0)
        shrinkAnimation.isRemovedOnCompletion = false
        shrinkAnimation.beginTime = popAnimation.duration
        shrinkAnimation.duration = 0.25
        shrinkAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        shrinkAnimation.delegate = self
        node.addAnimation(popAnimation, forKey: "pop")
        node.addAnimation(shrinkAnimation, forKey: "shrink")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag, let node = shrinkingPlane {
            node.removeFromParentNode()
        }
    }


    // MARK: - ARSCNViewDelegate

    // Override to create and configure nodes for anchors added to the view's session
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
