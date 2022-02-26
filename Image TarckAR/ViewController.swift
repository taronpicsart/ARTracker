//
//  ViewController.swift
//  Image TarckAR
//
//  Created by Narek Kirakosyan on 20.02.22.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import SpriteKit
import Lottie

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var videoNode: SKVideoNode!
    var videoPlayer: AVPlayer!
    var newReferenceImages:Set<ARReferenceImage> = Set<ARReferenceImage>()
    let lottieView = AnimationView(name: "faceID")
    var imageUrl: String = "" {
        didSet {
            startTracking(urlString: imageUrl)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! AVAudioSession.sharedInstance().setCategory(.playback)

        configScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTracking(urlString: "imageUrl")
        addLoading()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //MARK: Scene Configs
    private func configScene() {
        sceneView.delegate = self
//        sceneView.showsStatistics = true
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        sceneView.scene = scene
    }
    
    private func startTracking(urlString: String) {
        //load image
        /* loadImageFrom(url: urlString, completionHandler: get img)
         */
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 10
        configuration.detectionImages = arImages
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    //MARK: - marker/video setups
    private func loadImageFrom(url: URL, completionHandler:@escaping(UIImage)->()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil,
                        let image = UIImage(data: data)
                        else { return }
                    DispatchQueue.main.async() {
                        completionHandler(image)
                    }
                }.resume()
    }
    
    private func addVideo(to container: SCNNode, image: ARReferenceImage, node: SCNNode) {
        var videoName: String
        var videoSize: CGSize
        if image.name == "steve_jobs" {
            videoName = "steve_jobs"
            videoSize = CGSize(width: 1080, height: 1628)
        } else {
            videoName = "speach"
            videoSize = CGSize(width: 480, height: 360)
        }
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: ".mp4") else { return }
        //will be add
        let streamUrl = URL(string: "https://cdn140.picsart.com/69188081150963317923.mp4")
        videoPlayer = AVPlayer(url: videoURL)
        try! AVAudioSession.sharedInstance().setCategory(.playback)

        let videoScene = SKScene(size: videoSize)
        videoNode = SKVideoNode(avPlayer: videoPlayer)
        videoNode.position = CGPoint(x: videoScene.size.width/2, y: videoScene.size.height/2)
        videoNode.size = videoScene.size
        videoNode.yScale = -1
        videoNode.play()
        videoScene.addChild(videoNode)
        guard let video = container.childNode(withName: "video", recursively: true) else { return }
        video.geometry?.firstMaterial?.diffuse.contents = videoScene
        video.scale = SCNVector3(x: Float(image.physicalSize.width), y: Float(image.physicalSize.height), z: 1.0)
        video.position = node.position
        // For Animation
        guard let videoContainer = container.childNode(withName: "videoContainer", recursively: false) else { return }
        videoContainer.runAction(SCNAction.sequence([SCNAction.wait(duration: 1.0), SCNAction.scale(to: 1.0, duration: 0.5)]))
    }
    
    
    // MARK: - Loading
    private func addLoading() {
        lottieView.frame = view.bounds
        lottieView.play(completion: nil)
        lottieView.loopMode = .loop
        lottieView.alpha = 0.7
        let planeNode = SCNNode()

        planeNode.geometry = SCNPlane(width: 100,
                                     height: 100)
        
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        planeNode.position.z = -1     // 5 meters away
        sceneView.addSubview(lottieView)
    }
    
    private func removeLoading() {
        DispatchQueue.main.async {
            self.lottieView.removeFromSuperview()
        }
    }
    
    //MARK: - ARSCNViewDelegate
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        removeLoading()
//        guard anchor is ARImageAnchor else { return }
//        guard let referenceImage = ((anchor as? ARImageAnchor)?.referenceImage) else { return }
//        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else { return }
//        container.removeFromParentNode()
//        node.addChildNode(container)
//        container.isHidden = false
//        addVideo(to: container, image: referenceImage, node: node)
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
                removeLoading()
        //        guard anchor is ARImageAnchor else { return }
        //        guard let referenceImage = ((anchor as? ARImageAnchor)?.referenceImage) else { return }
        //        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else { return }
        //        container.removeFromParentNode()
            //1. Check We Have Detected An ARImageAnchor
            guard let validAnchor = anchor as? ARImageAnchor else { return }

            //2. Create A Video Player Node For Each Detected Target
            node.addChildNode(createdVideoPlayerNodeFor(validAnchor.referenceImage))

        }


        /// Creates An SCNNode With An AVPlayer Rendered Onto An SCNPlane
        ///
        /// - Parameter target: ARReferenceImage
        /// - Returns: SCNNode
        func createdVideoPlayerNodeFor(_ target: ARReferenceImage) -> SCNNode{
            var videoName: String
            var videoSize: CGSize
            if target.name == "steve_jobs" {
                videoName = "steve_jobs"
                videoSize = CGSize(width: 1080, height: 1628)
            } else {
                videoName = "speach"
                videoSize = CGSize(width: 480, height: 360)
            }
            
            
            //1. Create An SCNNode To Hold Our VideoPlayer
            let videoPlayerNode = SCNNode()

            //2. Create An SCNPlane & An AVPlayer
            let videoPlayerGeometry = SCNPlane(width: target.physicalSize.width, height: target.physicalSize.height)
            var videoPlayer = AVPlayer()

            //3. If We Have A Valid Name & A Valid Video URL The Instanciate The AVPlayer
            if let targetName = target.name,
                let validURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                videoPlayer = AVPlayer(url: validURL)
                videoPlayer.play()
            }

            //4. Assign The AVPlayer & The Geometry To The Video Player
            videoPlayerGeometry.firstMaterial?.diffuse.contents = videoPlayer
            videoPlayerNode.geometry = videoPlayerGeometry

            //5. Rotate It
            videoPlayerNode.eulerAngles.x = -.pi / 2

            return videoPlayerNode

        }

}
