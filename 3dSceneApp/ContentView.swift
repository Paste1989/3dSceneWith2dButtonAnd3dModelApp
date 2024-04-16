//
//  ContentView.swift
//  3dSceneApp
//
//  Created by Saša Brezovac on 29.02.2024..
//

import SwiftUI
import ARKit

struct ARSceneView: View {
    var body: some View {
        ARViewContainer()
    }
}

struct ARViewContainer: UIViewRepresentable {
    let coordinator = Coordinator()
    let scene = SCNScene()
    let sceneView = ARSCNView(frame: .zero)
    @State var counter = 0
    
    func makeUIView(context: Context) -> ARSCNView {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        sceneView.scene = scene
        
        // Add Tap Gesture Recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)

        // Add 2D Button
        let buttonNode = createButtonNode()
        scene.rootNode.addChildNode(buttonNode)
        
        // Add your 3D content here if needed + handling of 3D model
        coordinator.onNodeTapped = { node in
            print("node: \(node.name ?? "no name")")
            
            if counter < 1 {
                counter += 1
                setup3DModel(sceneView: sceneView)
            }
            else {
                
            }
            
            if node.name == "bulb" {
                guard let materials = node.geometry?.materials else { return }
                for material in materials {
                    guard let materialName = material.name else { return }
                    if !materialName.contains("base") {
                        material.emission.contents = UIColor.red
                        material.emission.intensity = 25
                    }
                }
            }
        }
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return coordinator
    }
    
    private func setup3DModel(sceneView: SCNView) {
        guard let model = loadScenePart(name: "bulb.scn") else { return }
        model.name = "bulb"
        model.scale = SCNVector3Make(0.05, 0.05, 0.05)
        model.position = SCNVector3(x: 0 , y: 0.15, z: -0.5)
        scene.rootNode.addChildNode(model)
    }
    
    private func loadScenePart(name: String) -> SCNNode? {
        guard let scene = SCNScene(named: name) else {
            print("Failed to load scene named \(name)")
            return nil
        }
        
        let partNode = SCNNode()
        for child in scene.rootNode.childNodes {
            partNode.addChildNode(child)
        }
        
        return partNode
    }
    
    private func createButtonNode() -> SCNNode {
        let buttonGeometry = SCNPlane(width: 0.1, height: 0.1)
        let buttonMaterial = SCNMaterial()
        buttonMaterial.diffuse.contents = UIImage(named: "switchImg")
        buttonGeometry.materials = [buttonMaterial]
        
        let buttonNode = SCNNode(geometry: buttonGeometry)
        buttonNode.name = "button_node"
        buttonNode.position = SCNVector3(x: 0 , y: 0, z: -0.5)
        
        return buttonNode
    }
}

class Coordinator: NSObject, ARSessionDelegate {
    var onNodeTapped: ((SCNNode) -> Void)?
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("ARSession did fail with error: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("ARSession was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("ARSession interruption ended")
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let sceneView = gestureRecognizer.view as! SCNView
        let location = gestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if let hitResult = hitResults.first {
            let node = hitResult.node
            
            print("tapped node: \(node)")
            onNodeTapped?(node)
           
        }
    }
}

struct ContentView: View {
    var body: some View {
        ARSceneView()
    }
}
#Preview {
    ContentView()
}
