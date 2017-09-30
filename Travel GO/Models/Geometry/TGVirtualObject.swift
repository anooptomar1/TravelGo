//
//  TGVirtualObject.swift
//  Travel GO
//
//  Created by Mai Anh Vu on 9/30/17.
//  Copyright © 2017 Mai Anh Vu. All rights reserved.
//

import SceneKit
import ARKit

class TGVirtualObject: SCNNode {
    //-------------------------------------------------------------------------
    // MARK: - Constants
    //-------------------------------------------------------------------------
    static let ROOT_NAME = "VirtualObject Root Node"

    //-------------------------------------------------------------------------
    // MARK: - Properties
    //-------------------------------------------------------------------------
    private(set) var modelName: String = ""
    private(set) var fileExtension: String = ""
    private var isModelLoaded: Bool = false

    //-------------------------------------------------------------------------
    // MARK: - Initialization
    //-------------------------------------------------------------------------
    override init() {
        super.init()
        self.name = TGVirtualObject.ROOT_NAME
    }

    init(modelName: String, fileExtension: String = "scn") {
        super.init()
        self.name = TGVirtualObject.ROOT_NAME
        self.modelName = modelName
        self.fileExtension = fileExtension
    }

    required init?(coder aDecoder: NSCoder?) {
        fatalError("init(coder:) is not implemented")
    }

    //-------------------------------------------------------------------------
    // MARK: - Model Loading
    //-------------------------------------------------------------------------
    func loadModel() {
        guard let objectScene = SCNScene(named: "\(modelName).\(fileExtension)", inDirectory: "art.scnassets") else {
            return
        }

        if isModelLoaded {
            return
        }

        let wrapperNode = SCNNode()

        objectScene.rootNode.childNodes.map({ node -> SCNNode in
            node.geometry?.firstMaterial?.lightingModel = .physicallyBased
            node.movabilityHint = .movable
            return node
        }).forEach { wrapperNode.addChildNode($0) }

        self.addChildNode(wrapperNode)
        isModelLoaded = true
    }


}
