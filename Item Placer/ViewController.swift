//
//  ViewController.swift
//  Item Placer
//
//  Created by Trevor Beaton on 12/15/17.
//  Copyright © 2017 Vanguard Logic LLC. All rights reserved.
//

import UIKit
import ARKit


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate {

  let itemArray: [String] = ["cup", "vase", "adabot", "table", "boxing"]
  let config = ARWorldTrackingConfiguration()
  var selectedItem: String?
  
  
  @IBOutlet weak var itemCollectionView: UICollectionView!
  @IBOutlet weak var sceneView: ARSCNView!
 

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
    self.config.planeDetection = .horizontal
    self.sceneView.session.run(config)
    self.itemCollectionView.dataSource = self
    self.itemCollectionView.delegate = self
    self.registerGestureRecognizers()
    self.sceneView.autoenablesDefaultLighting = true
  }

  
  
  func registerGestureRecognizers() {
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
    let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
    self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
    self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    
  }
  
  
  
  @objc func pinch(sender: UIPinchGestureRecognizer) {
    
    let sceneView = sender.view as! ARSCNView
    let pinchLocation = sender.location(in: sceneView)
    let hitTest = sceneView.hitTest(pinchLocation)
    if !hitTest.isEmpty {
      
      let results = hitTest.first!
      let node = results.node
      let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
      print(sender.scale)
      node.runAction(pinchAction)
      sender.scale = 1.0
    }
  }
  
  
  @objc func rotate(sender: UILongPressGestureRecognizer) {
    let sceneView = sender.view as! ARSCNView
    let holdLocation = sender.location(in: sceneView)
    let hitTest = sceneView.hitTest(holdLocation)
    
    if !hitTest.isEmpty{
 
    let result = hitTest.first!
    if sender.state == .began {
      let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
      let forever = SCNAction.repeatForever(rotation)
      result.node.runAction(forever)
    } else if sender.state == .ended {
      result.node.removeAllActions()
    }
  }
}
  
  func centerPivot(for node: SCNNode) {
    let min = node.boundingBox.min
    let max = node.boundingBox.max
    node.pivot = SCNMatrix4MakeTranslation(
      min.x + (max.x - min.x)/2,
      min.y + (max.y - min.y)/2,
      min.z + (max.z - min.z)/2)

  }


  
  @objc func tapped(sender: UITapGestureRecognizer) {
    
    let sceneView = sender.view as! ARSCNView
    let tapLocation = sender.location(in: sceneView)
    let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
    if !hitTest.isEmpty {
      print("touched surface")
      self.addItem(hitTestResult: hitTest.first!)
    }
  }
  
  func addItem(hitTestResult: ARHitTestResult) {
   
    if let selectedItem = self.selectedItem {
      
      let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
      let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
      let transform = hitTestResult.worldTransform
      let thirdColumn = transform.columns.3
      node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
      self.sceneView.scene.rootNode.addChildNode(node)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return itemArray.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    print("Cell for item at")
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell
    cell.itemLabel.text = self.itemArray[indexPath.row]
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
   
    let cell = collectionView.cellForItem(at: indexPath)
    self.selectedItem = itemArray[indexPath.row]
    cell?.backgroundColor = UIColor.gray
  }
  
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath)
    cell?.backgroundColor = UIColor.blue
  }
  
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard anchor is ARPlaneAnchor else {return}
  }
  
}

extension Int {
  
  var degreesToRadians: Double { return Double(self) * .pi/180}
}

