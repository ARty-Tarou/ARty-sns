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
import ReplayKit
import NCMB

class ArtViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate, RPPreviewViewControllerDelegate {
    
    // てすと
    var testWorldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("testWorldMapURL")
        } catch {
            fatalError("no such file")
        }
    }()
    
    // MARK: Properties
    // appDelegate
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 表示するworldMapのfileName
    var fileName: String?
    
    var worldMap: ARWorldMap?
    
    
    // sceneView
    @IBOutlet var sceneView: ARSCNView!
    
    // ContainerView
    @IBOutlet weak var graffitiContainer: UIView!
    @IBOutlet weak var stampContainer: UIView!
    
    // 投稿用
    var stickImage: UIImage? = nil
    var stickData: Data? = nil
    
    // 落書き
    var fontSize: Float = 0.003
    var lineColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    
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
    
    // 初回
    var bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ARWorldMapFileName:\(self.fileName)")
        
        if self.fileName != nil {
            // WorldMapを取得
            pullWorldMap()
        }
        
        if bool {
            graffitiContainer.isHidden = true
            stampContainer.isHidden = true
            bool = false
        }
        
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // ナビゲーションバーを非表示にする
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    // MARK: Method
    func getScreenShot(windowFrame: CGRect) -> UIImage {
        // スクリーンショットを取得
        let image = sceneView.snapshot()
        
        return image
    }
    
    //Graffiti
    func begin(){
        drawingNode = SCNNode()
        sceneView.scene.rootNode.addChildNode(drawingNode!)
    }
    
    func addPointAndCreateVertices(){
        //カメラノード
        guard let camera: SCNNode = sceneView.pointOfView else{
            return
        }
        
        // fontSizeを取得
        let fontSize = appDelegate.fontSize
        
        let pointScreen: SCNVector3 = SCNVector3Make(Float(pointTouching.x),Float(pointTouching.y), 0.997)
        let pointWorld: SCNVector3 = sceneView.unprojectPoint(pointScreen)
        let pointCamera: SCNVector3 = camera.convertPosition(pointWorld, from: nil)
        
        let x: Float = pointCamera.x
        let y: Float = pointCamera.y
        let z: Float = -0.2
        
        let vertice0InCamera: SCNVector3 = SCNVector3Make(x - fontSize, y + fontSize, z)
        let vertice1InCamera: SCNVector3 = SCNVector3Make(x + fontSize, y + fontSize, z)
        let vertice2InCamera: SCNVector3 = SCNVector3Make(x - fontSize, y - fontSize, z)
        let vertice3InCamera: SCNVector3 = SCNVector3Make(x + fontSize, y - fontSize, z)
        
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
        
        // fontColorを取得
        self.lineColor = appDelegate.lineColor
        print("lineColor:\(self.lineColor)")
        
        let source = SCNGeometrySource(vertices: polygonVertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        drawingNode?.geometry = SCNGeometry(sources:[source], elements: [element])
    
        drawingNode?.geometry?.firstMaterial?.diffuse.contents = self.lineColor
        drawingNode?.geometry?.firstMaterial?.isDoubleSided = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
        if isDrawing {
            addPointAndCreateVertices()
        }
    }
    
    // TODO: Stamp
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        
        guard !(anchor is ARPlaneAnchor) else { return }
        
        
        if anchor.name == "stamp" {
            // スタンプの設定を取得
            self.stampHeight = appDelegate.stampHeight
            self.stampWidth = appDelegate.stampWidth
            self.stampImage = appDelegate.stampImage
            
            // ノードを作成
            let boxNode = SCNNode()
            
            // ボックスを作成
            let box = SCNBox(width: CGFloat(self.stampWidth) / 10000, height: 0.0001, length: CGFloat(self.stampHeight) / 10000, chamferRadius: 0)
            
            // スタンプテクスチャのマテリアルを生成
            let stampTexture = SCNMaterial()
            stampTexture.diffuse.contents = self.stampImage
            
            // 透明な面を生成
            let blank = SCNMaterial()
            blank.diffuse.contents = UIColor.clear
            
            // ボックスにマテリアルを貼り付け
            box.materials = [blank, blank, blank, blank, stampTexture, blank]
            
            // ジオメトリを設定
            boxNode.geometry = box
            boxNode.position.y += 0.01
            
            // 検出面の子要素にする
            node.addChildNode(boxNode)
        }
        
        
    }
    
    // WorldMapを取得
    func pullWorldMap() {
        print("pullしてるよ")
        self.fileName = String(self.fileName!.suffix(self.fileName!.count - 2))
        self.fileName = "a." + self.fileName!
        print("fileName : \(fileName)")
        let file = NCMBFile(fileName: self.fileName!)
        
        file.fetchInBackground(callback: {result in
            switch result {
            case let .success(data):
                print("WorldMapが取得できたよ")
                
                print("pullWorldMap(data):\(data!)")
                
                // デシリアライズ
                guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data!) else {
                    print("デシリアライズできなかったよ")
                    return
                    
                }
                
                print("pullWorldMap(worldMap):\(worldMap)")
                
                self.worldMap = worldMap
                
                self.reload()
                
            case let .failure(error):
                print("WorldMapが取得できなかったよ\(error)")
            }
        })
    }
    
    func reload() {
        print("reload : \(self.worldMap!)")
        // WorldMapの再設定
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.initialWorldMap = self.worldMap!
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: Action
    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // graffiti
            graffitiContainer.isHidden = false
            stampContainer.isHidden = true
            drawFlag = true
            print(self.fontSize)
            
            // ナビゲーションバーを表示
            navigationController?.setNavigationBarHidden(false, animated: true)
            
        case 1: // stamp
            graffitiContainer.isHidden = true
            stampContainer.isHidden = false
            drawFlag = false
            
            // ナビゲーションバーを表示
            navigationController?.setNavigationBarHidden(false, animated: true)
            
        case 2:// close
            graffitiContainer.isHidden = true
            stampContainer.isHidden = true
            
            // ナビゲーションバーを非表示
            navigationController?.setNavigationBarHidden(true, animated: true)
            
        default:
            break;
        }
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        viewDidLoad()
    }
    
    @IBAction func reloadButtonAction(_ sender: Any) {
        reload()
    }
    
    // test
    @IBAction func saveButtonAction(_ sender: Any) {
        // worldMapを取得
        sceneView.session.getCurrentWorldMap {
            worldMap, error in guard let map = worldMap else {return}
            
            print("保存(worldMap):\(map)")
            
            // シリアライズ
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else {return}
            
            print("保存(data):\(data)")
            
            // ローカルに保存
            guard ((try? data.write(to: self.testWorldMapURL)) != nil) else {return}
        }
        
    }
    @IBAction func loadButtonAction(_ sender: Any) {
        // 保存したworldMapの読み出し
        var data: Data? = nil
        do {
            try data = Data(contentsOf: self.testWorldMapURL)
            
        } catch {
            return
        }
        
        print("読込(data):\(data!)")
        print("読込(data2):\(data ?? Data())")
        
        // デシリアライズ
        guard let testWorldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data!) else {return}
        
        print("読込(worldMap):\(testWorldMap)")
        
        // worldMapの再設定
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.initialWorldMap = testWorldMap
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    
    
    @IBAction func shotButtonAction(_ sender: Any) {
        // スクリーンショットを取得
        self.stickImage = getScreenShot(windowFrame: self.view.bounds)
        
        // WorldMapを取得
        sceneView.session.getCurrentWorldMap { worldMap, error in guard let map = worldMap else {return}
            
            print("投稿(worldMap):\(String(describing: worldMap))")
            
            // シリアライズ
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else {return}
            
            print("投稿(data):\(data)")
            
            self.stickData = data
            
            // 画面遷移
            self.performSegue(withIdentifier: "stick", sender: nil)
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
                
                sceneView.session.add(anchor: anchor)
            }
        } else {
            // 落書きの処理
            
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
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // ARStickForm画面のインスタンスを格納
        if let stickFormViewController = segue.destination as? StickFormViewController {
            // デバッグ用出力
            print("StickForm画面へ")
            
            // 投稿データ
            stickFormViewController.stickImage = self.stickImage
            stickFormViewController.stickData = self.stickData
            
            // ARだよ
            stickFormViewController.ar = true
        }
    }
}
