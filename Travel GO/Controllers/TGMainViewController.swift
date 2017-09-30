//
//  TGGroundPlaneTrackingViewController.swift
//  Travel GO
//
//  Created by Mai Anh Vu on 9/30/17.
//  Copyright © 2017 Mai Anh Vu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class TGMainViewController: UIViewController, ARSCNViewDelegate {

    //-------------------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------------------
    @IBOutlet weak var sceneView: ARSCNView!
    private let groundTracker = TGGroundTracker()
    private var currentStep: Step = Step.first()

    //-------------------------------------------------------------------------
    // MARK: - View Lifecycle
    //-------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureARScene()

        // Add tap gesture recognition
        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TGMainViewController.didTapInSceneView(using:))))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
    }

    private func configureARScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
    }

    private func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }

    //-------------------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------------------
    @objc
    func didTapInSceneView(using tapGestureRecognizer: UITapGestureRecognizer) {
        if let currentFrame = sceneView.session.currentFrame {
            switch currentStep {
            case .showMonument:
                placeMonument(with: currentFrame)
                break

            case .showMonumentInfo:
                placeRelic(with: currentFrame)
                placeEiffelSignboard(with: currentFrame)

            default:
                break

            }
            advanceCurrentStep()
        }
    }

    private func advanceCurrentStep() {
        switch currentStep {
        case .showMonument:
            currentStep = .showMonumentInfo
        case .showMonumentInfo:
            currentStep =  .showNearbyInfo
        default:
            currentStep = .terminated
        }
    }

    //-------------------------------------------------------------------------
    // MARK: - Overrides
    //-------------------------------------------------------------------------
    override var prefersStatusBarHidden: Bool { return true }
    
    //-------------------------------------------------------------------------
    // MARK: - ARSCNViewDelegate
    //-------------------------------------------------------------------------
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        groundTracker.handleRenderer(renderer, didAdd: node, for: anchor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        groundTracker.handleRenderer(renderer, didUpdate: node, for: anchor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        groundTracker.handleRenderer(renderer, didRemove: node, for: anchor)
    }

    //-------------------------------------------------------------------------
    // MARK: - Placing
    //-------------------------------------------------------------------------
    private func placeMonument(with frame: ARFrame) {
        let eiffel = TGVirtualObject(modelName: "tour_eiffel/EXE_Tour_Eiffel", fileExtension: "dae")
        eiffel.loadModel()
        sceneView.scene.rootNode.addChildNode(eiffel)

        var eiffelAdjust = matrix_identity_float4x4
        eiffelAdjust.columns.3.z = -100
        let eiffelTransform = matrix_multiply(frame.camera.transform, eiffelAdjust)
        eiffel.simdTransform = eiffelTransform

        let scale: Float = 1
        eiffel.scale = SCNVector3Make(scale, scale, scale)
    }


    private func placeRelic(with frame: ARFrame) {
        let glowTrail = SCNParticleSystem(named: "glow.scnp", inDirectory: "art.scnassets")!
        glowTrail.particleColor = UIColor.orange
        let glowGeometry = SCNSphere(radius: 0.01)
        glowTrail.emitterShape = glowGeometry

        // Particle transforms
        var tMatrix = matrix_identity_float4x4
        tMatrix.columns.3.z = -0.3
        tMatrix.columns.3.x = -0.0625
        let transform = matrix_multiply(frame.camera.transform, tMatrix)

        sceneView.scene.addParticleSystem(glowTrail, transform: SCNMatrix4(transform))

        // Add tiny model
        let tinyEiffel = TGVirtualObject(modelName: "tour_eiffel/EXE_Tour_Eiffel", fileExtension: "dae")
        tinyEiffel.loadModel()
        sceneView.scene.rootNode.addChildNode(tinyEiffel)

        // Calculate tiny model transform
        var tinyTranslate = matrix_identity_float4x4
        tinyTranslate.columns.3.z = -0.3
        tinyTranslate.columns.3.x = -0.0625
        tinyTranslate.columns.3.y = -0.01
        let tinyTransform = matrix_multiply(frame.camera.transform, tinyTranslate)

        let scale: Float = 0.0004
        tinyEiffel.simdTransform = tinyTransform
        tinyEiffel.scale = SCNVector3Make(scale, scale, scale)

        // Add tiny eiffel animation
        let spin = CABasicAnimation(keyPath: "eulerAngles")
        spin.fromValue = SCNVector3Make(Float.pi / 8, 0, 0)
        spin.toValue   = SCNVector3Make(Float.pi / 8, Float.pi * 2, 0)
        spin.repeatCount = Float.infinity
        spin.isRemovedOnCompletion = false
        spin.duration = 2
        // spin.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        tinyEiffel.addAnimation(spin, forKey: "spin")
    }

    private func placeEiffelSignboard(with frame: ARFrame) {
        let signboardPlane = SCNPlane(width: 0.12, height: 0.15)
        let signboardForegroundMaterial = SCNMaterial()

        signboardForegroundMaterial.diffuse.contents = #imageLiteral(resourceName: "eiffel_signboard")
        signboardForegroundMaterial.isDoubleSided = false
        signboardForegroundMaterial.lightingModel = .constant

        signboardPlane.materials = [signboardForegroundMaterial]
        let signboardNode = SCNNode(geometry: signboardPlane)
        sceneView.scene.rootNode.addChildNode(signboardNode)

        var tMatrix = matrix_identity_float4x4
        tMatrix.columns.3.z = -0.3
        tMatrix.columns.3.x = 0.0625
        signboardNode.simdTransform = matrix_multiply(frame.camera.transform, tMatrix)
    }

    //-------------------------------------------------------------------------
    // MARK: - Types
    //-------------------------------------------------------------------------
    private enum Step {
        case showMonument
        case showMonumentInfo
        case showNearbyInfo
        case terminated

        static func first() -> Step {
            return .showMonument
        }
    }
}
