//
//  ArtViewController.swift
//  ARty
//
//  Created by 藤崎伊織 on 2020/07/13.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import NCMB

class ArtViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    // sceneView
    @IBOutlet var sceneView: ARSCNView!
    
    // ContainerView
    @IBOutlet weak var graffitiContainer: UIView!
    @IBOutlet weak var stampContainer: UIView!
    
    // 落書き
    var fontSize: Float = 0.0
    var lineColor = UIColor.lightGray
    
    var polygonVertices: [SCNVector3] = []
    var indices: [Int32] = []
    var centerVerticesCount: Int32 = 0
    var pointTouching: CGPoint = .zero
    var drawingNode: SCNNode?
    
    // スタンプ
    var stampHeight = 500
    var stampWidth = 500
    var stampImage: UIImage?
    
    //落書きかスタンプかの判定に使うフラグ
    var isDrawing: Bool = false
    var drawFlag: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートを設定
        sceneView.delegate = self
        
        // シーンの追加
        sceneView.scene = SCNScene()
        
        // 特徴点の表示
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // ライトの追加
        sceneView.automaticallyUpdatesLighting = true
        
        // コンフィギュレーションの設定
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        // セッションを開始
        sceneView.session.run(configuration)

        // ContainerViewを非表示に設定
        graffitiContainer.isHidden = true
        stampContainer.isHidden = true
        
        print("fontSize3: \(self.fontSize)")
    }
    
    // MARK: Method
    
    func graffitiConfigUpdate() {
        
        var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.fontSize = appDelegate.fontSize!;
        
        print("art : \(fontSize)")
        print("delegate art : \(appDelegate.fontSize)")
    }
    
    func stampConfigUpdate() {
        
    }
    
    // MARK: Action
    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            graffitiContainer.isHidden = false
            stampContainer.isHidden = true
            drawFlag = true
            print(self.fontSize)
        case 1:
            graffitiContainer.isHidden = true
            stampContainer.isHidden = false
            drawFlag = false
        case 2:
            graffitiContainer.isHidden = true
            stampContainer.isHidden = true
            print(self.fontSize)
        default:
            break;
        }
    }
    
    //Graffiti
    func begin(){
        print("fontSize6 : \(self.fontSize)")
        drawingNode = SCNNode()
        sceneView.scene.rootNode.addChildNode(drawingNode!)
    }
    
    func addPointAndCreateVertices(){
        //print("fontSize5 : \(fontSize)")
        //カメラノード
        guard let camera: SCNNode = sceneView.pointOfView else{
            return
        }
        
        let pointScreen: SCNVector3 = SCNVector3Make(Float(pointTouching.x),Float(pointTouching.y), 0.997)
        let pointWorld: SCNVector3 = sceneView.unprojectPoint(pointScreen)
        let pointCamera: SCNVector3 = camera.convertPosition(pointWorld, from: nil)
        
        let x: Float = pointCamera.x
        let y: Float = pointCamera.y
        let z: Float = -0.2
        
        let vertice0InCamera: SCNVector3 = SCNVector3Make(x - self.fontSize, y + self.fontSize, z)
        let vertice1InCamera: SCNVector3 = SCNVector3Make(x + self.fontSize, y + self.fontSize, z)
        let vertice2InCamera: SCNVector3 = SCNVector3Make(x - self.fontSize, y - self.fontSize, z)
        let vertice3InCamera: SCNVector3 = SCNVector3Make(x + self.fontSize, y - self.fontSize, z)
        
        let vertice0: SCNVector3 = camera.convertPosition(vertice0InCamera, to: nil)
        let vertice1: SCNVector3 = camera.convertPosition(vertice1InCamera, to: nil)
        let vertice2: SCNVector3 = camera.convertPosition(vertice2InCamera, to: nil)
        let vertice3: SCNVector3 = camera.convertPosition(vertice3InCamera, to: nil)
        
        polygonVertices += [vertice0, vertice1, vertice2, vertice3]
        centerVerticesCount += 2
        
        guard centerVerticesCount > 2 else {
            return
        }
        
        let leftn: Int32 = centerVerticesCount - 4
        let leftm: Int32 = 2 * leftn
        let nextLeftIndices: [Int32] = [
            leftm    , leftm + 1, leftm + 2,//前面
            leftm    , leftm + 1, leftm + 4,//上面左
            leftm    , leftm + 2, leftm + 4,//左側面上
            leftm + 1, leftm + 4, leftm + 5,//上面右
            leftm + 2, leftm + 4, leftm + 6,//左側面下
            leftm + 4, leftm + 5, leftm + 6 //後ろ面
        ]
        indices += nextLeftIndices
        
        let rightn: Int32 = centerVerticesCount - 4
        let rightm: Int32 = 2 * rightn + 1
        let nextRightIndices: [Int32] = [
            rightm    , rightm + 1, rightm + 2,
            rightm    , rightm + 2, rightm + 4,
            rightm + 1, rightm + 2, rightm + 5,
            rightm + 1, rightm + 2, rightm + 6,
            rightm + 2, rightm + 4, rightm + 6,
            rightm + 4, rightm + 5, rightm + 6
        ]
        indices += nextRightIndices
        
        updateGeometry()
    }
    
    func reset() {
        centerVerticesCount = 0
        polygonVertices.removeAll()
        indices.removeAll()
        drawingNode = nil
    }
    
    func updateGeometry(){
        let source = SCNGeometrySource(vertices: polygonVertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        drawingNode?.geometry = SCNGeometry(sources:[source], elements: [element])
    
        drawingNode?.geometry?.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.4627581835, green: 0.9555212855, blue: 0.5625822544, alpha: 1)
        drawingNode?.geometry?.firstMaterial?.isDoubleSided = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
        
        if isDrawing {
            addPointAndCreateVertices()
        }
    }
    
    // MARK: Touch Method
    
    // 画面をタップしたとき
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !drawFlag {
            
            // スタンプの処理
            // タップした座標を取り出す
            guard let touch = touches.first else{return}
            
            // スクリーン座標に変換する
            let touchPos = touch.location(in: sceneView)
            
            // タップされた位置のARアンカーを探す
            let hitTest = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
            if !hitTest.isEmpty{
                // タップした箇所が取得できていればアンカーを追加
                let anchor = ARAnchor(name: "stamp", transform: hitTest.first!.worldTransform)
                //print(anchor.name)
                sceneView.session.add(anchor: anchor)
            }
        } else {
            // 落書きの処理
            
            //print(fontSize)
            
            guard let location = touches.first?.location(in: nil) else{
                return
            }
            pointTouching = location
            
            begin()
            isDrawing = true
        }
    }
    
    // タッチされた状態で指で動かすと呼ばれる
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !drawFlag {
            
        } else {
            guard let location = touches.first?.location(in: nil) else{
                return
            }
            pointTouching = location
        }
        
        
    }
    
    // 指を離したら呼ばれる
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !drawFlag {
        } else {
            isDrawing = false
            reset()
        }
    }
}
