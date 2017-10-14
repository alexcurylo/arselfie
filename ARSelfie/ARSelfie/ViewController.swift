//
//  ViewController.swift
//  ARSelfie
//
//  Created by Alex Curylo on 10/13/17.
//  Copyright © 2017 Trollwerks Inc. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

internal class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsDrawCount = true
        sceneView.showsNodeCount = true
        sceneView.showsQuadCount = true
        sceneView.showsPhysics = true
        sceneView.showsFields = true

        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

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
}

// MARK: - ARSessionObserver
extension ViewController: ARSessionObserver {

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        // This is called when the camera’s tracking state has changed.
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
        // This is called when the session outputs a new audio sample buffer.
    }
}

// MARK: - SKViewDelegate
extension ViewController: SKViewDelegate {

    public func view(_ view: SKView, shouldRenderAtTime time: TimeInterval) -> Bool {
        // Allows the client to dynamically control the render rate.
        return true
    }
}

// MARK: - ARSKViewDelegate
extension ViewController: ARSKViewDelegate {

    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let labelNode = SKLabelNode(text: "🤡")
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        return labelNode;
    }
    
    func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor) {
        // Called when a new node has been mapped to the given anchor.
    }

    func view(_ view: ARSKView, willUpdate node: SKNode, for anchor: ARAnchor) {
        // Called when a node will be updated with data from the given anchor.
    }
    
    func view(_ view: ARSKView, didUpdate node: SKNode, for anchor: ARAnchor) {
        // Called when a node has been updated with data from the given anchor.
    }

    func view(_ view: ARSKView, didRemove node: SKNode, for anchor: ARAnchor) {
        // Called when a mapped node has been removed from the scene graph for the given anchor.
    }
}
