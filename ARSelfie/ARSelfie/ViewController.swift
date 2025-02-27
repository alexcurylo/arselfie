//
//  ViewController.swift
//  ARSelfie
//
//  Created by Alex Curylo on 10/13/17.
//  Copyright © 2017 Trollwerks Inc. All rights reserved.
//

import ARKit
import SpriteKit
import Vision

final class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSKView?

    @IBOutlet weak var visionInfo: UITextView?
    var visionRequests = [VNRequest]()
    let visionQueue = DispatchQueue(label: "com.arselfie.visionQueue")
    var visionThing: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScene()
        setupVision()
    }

    func setupScene() {
        sceneView?.delegate = self
        
        sceneView?.showsFPS = true
        sceneView?.showsDrawCount = true
        sceneView?.showsNodeCount = true
        sceneView?.showsQuadCount = true
        sceneView?.showsPhysics = true
        sceneView?.showsFields = true

        if let scene = SKScene(fileNamed: "Scene") {
            sceneView?.presentScene(scene)
        }

        if let visionInfo = visionInfo {
            sceneView?.addSubview(visionInfo)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView?.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView?.session.pause()
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
        let text = visionThing.isEmpty ? "🤡" : visionThing
        let labelNode = SKLabelNode(text: text)
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

// MARK: - Vision
extension ViewController {

    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("VNCoreMLModel() FAIL")
        }
        
        let classifyRequest = VNCoreMLRequest(model: visionModel,
                                              completionHandler: classified)
        classifyRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [classifyRequest]
        
        classify()
    }

    func classify() {
        visionQueue.async {
            self.updateVision()
            self.classify()
        }
    }

    func classified(request: VNRequest, error: Error?) {
        guard error == nil else {
            print("classified FAIL: " + (error?.localizedDescription ?? "?"))
            return
        }
        guard let results = request.results else {
            return
        }

        let classifieds = results[0...1]
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
            .joined(separator: "\n")

        DispatchQueue.main.async {
            self.visionInfo?.text = classifieds
            let things = classifieds.components(separatedBy: "-")[0]
            let thing = things.components(separatedBy: ",")[0]
            self.visionThing = thing
        }
    }

    func updateVision() {
        guard let frame = sceneView?.session.currentFrame else {
            return
        }

        let image = CIImage(cvPixelBuffer: frame.capturedImage)
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
}
