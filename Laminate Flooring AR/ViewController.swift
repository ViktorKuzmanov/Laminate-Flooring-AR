import UIKit
import ARKit
import StoreKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var userFriendlyLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var laminateCollectionView: UICollectionView!
    let laminateNames = ["laminate1","laminate2","laminate3","laminate4","laminate5","laminate6","laminate7","laminate8","laminate9"]
    
    let configuration = ARWorldTrackingConfiguration()
    var selectedLaminateName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUp()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        collectionView.backgroundView = UIImageView(image: UIImage(named: "greenBG2 Copy"))
    }
    
    // MARK: Handle tap
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let scnView = sceneView else { return }
        let touchLocation = sender.location(in: scnView)
        let hitTestResult = scnView.hitTest(touchLocation)
        
        if hitTestResult.count > 0 {
            // remove anchor for node
            let node = hitTestResult.first?.node
            let anchorOfSelectedNode = scnView.anchor(for: (node)!)
            // add physics body to node
            if let geometry = node?.geometry {
                node?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry, options: nil))
                switchButton.isOn = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                if let unwrappedAnchor = anchorOfSelectedNode {
                    self.sceneView.session.remove(anchor: unwrappedAnchor)
                }
            })
        }
    }
    
    func addAnimationToLaminate(node: SCNNode) {
        // add bokeh animation to node
        let confetti = SCNParticleSystem(named: "Media.scnassets/bokeh.scnp", inDirectory: nil)
        confetti?.loops = false
        confetti?.particleLifeSpan = 4
        confetti?.emitterShape = node.geometry
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        confettiNode.position = node.position
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
    }
    
    // MARK: Collection view data source methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return laminateNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemID", for: indexPath) as! ItemCell
        cell.backgroundView = UIImageView(image: UIImage(named: laminateNames[indexPath.row]))
        return cell
    }
    
    // MARK: DidSelectItemAt - Collection View
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ItemCell
        selectedLaminateName = laminateNames[indexPath.row]
        cell?.backgroundColor = .green
        switchButton.isEnabled = true
        userFriendlyLabel.isHidden = false
        userFriendlyLabel.text = "Scan your surroundings"
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5, execute: {
            self.userFriendlyLabel.isHidden = true
        })
    }
    
    // MARK: DidDeselectItemAt - Collection View
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // vaa func se povikue na pr. ako stisnis edna cell i posle stisnis duga vikame deka prvata so si a stisnal e deselected (u via slucaj i davam na taa cell orange(default) bg color)
        let cell = collectionView.cellForItem(at: indexPath) as? ItemCell
        cell?.backgroundColor = .orange
        userFriendlyLabel.isHidden = false
        userFriendlyLabel.text = "Scan your surroundings"
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5, execute: {
            self.userFriendlyLabel.isHidden = true
        })
    }
    
    func createLaminate(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let laminateNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        laminateNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: selectedLaminateName!)
        laminateNode.geometry?.firstMaterial?.isDoubleSided = true
        
        laminateNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        laminateNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        // Cim so vaa func addnujme laminate moze da go enable resetButton
        resetButton.isEnabled = true
        return laminateNode
    }
    
    // MARK: Renderer func that add laminate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            if self.switchButton.isOn {
                // ako switch e on userot vikje postavue laminate taka da ne treba da mu pise "scan for.."
                self.userFriendlyLabel.isHidden = true
                let laminateNode = self.createLaminate(planeAnchor: planeAnchor)
                node.addChildNode(laminateNode)
            } else {
                self.userFriendlyLabel.isHidden = false
                if self.selectedLaminateName != nil {
                    self.userFriendlyLabel.text = "Turn switch on"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.userFriendlyLabel.isHidden = true
                    }
                } else {
                    self.userFriendlyLabel.text = "Select laminate"
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            if self.switchButton.isOn {
                node.enumerateChildNodes { (childNode, _) in
                    childNode.removeFromParentNode()
                }
                let laminateNode = self.createLaminate(planeAnchor: planeAnchor)
                node.addChildNode(laminateNode)
            }
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if self.switchButton.isOn {
                guard let _ = anchor as? ARPlaneAnchor else {return}
                node.enumerateChildNodes { (childNode, _) in
                    childNode.removeFromParentNode()
                }
            }
        }
    }
    
    // MARK: ResetButtonTapped
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        if self.sceneView.scene.rootNode.childNodes.count > 0 {
            DispatchQueue.main.async {
                self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                    if let geometry = node.geometry {
                        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: geometry, options: nil))
                    }
                }
                self.askForRate()
            }
            removeAllNodes()
        }
        // da naprajme da e off za da ne se stava/update uste laminate
        switchButton.isOn = false
        sender.bounceAnimation()
        resetButton.isEnabled = false
    }
    
    func askForRate() {
        if UserDefaults.standard.bool(forKey: "WalkthroughWatched") {
            // Walkthrought has been watched
        } else {
            // Walkthrought has not been watched
            DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                // ask for rate
                if #available( iOS 10.3,*){
                    SKStoreReviewController.requestReview()
                }
            })
        }
        UserDefaults.standard.set(true, forKey: "WalkthroughWatched")
    }
    
    func removeAllNodes() {
        // removni gi site nodes oti vo sprotivno kje se pojavat pak kaa kje click reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                node.position = SCNVector3(342523532235,53252352352,5325235235)
            })
        })
    }
    
    fileprivate func settingUp() {
        resetButton.isEnabled = false
        userFriendlyLabel.isHidden = false
        switchButton.isEnabled = false
        configuration.planeDetection = .horizontal
        laminateCollectionView.dataSource = self
        laminateCollectionView.delegate = self
        sceneView.delegate = self
        self.sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
    }
}


