//
//  PlayerContainerView.swift
//  Telewebion
//
//  Created by Mahsa Mo on 17.10.18.
//  Copyright © 2018 Mahsa Mo. All rights reserved.
//

import UIKit
import AVKit
import Foundation


enum stateOfVC {
    case minimized
    case fullScreen
    case hidden
}

enum Direction {
    case up
    case left
    case none
}


class PlayerContainerView: UIView    {
    
    //init constant
    private let customErrorViewHeight : CGFloat = 91
    private var playerLayerHeight : CGFloat =  250
    private let sliderHeight : CGFloat = 30
    private let playBtnHeight : CGFloat = 32
    private let changeVideoScaleBtnHeight: CGFloat = 30
    private let adaptiveHeight: CGFloat = 30
    private let adaptiveWidth: CGFloat = 150
    private let defaultMargin : CGFloat = 10
    private let expiredTimeLblHeight : CGFloat = 16
    private let expiredTimeLblWidth: CGFloat = 52
    private let duratiponLblWidth: CGFloat = 66
    private let sliderBackgroundLblWidth: CGFloat = 40
    
    //init IBOutlet
    @IBOutlet weak var playerBtnContainerLbl: UILabel!
    @IBOutlet weak var gestureLbl: UILabel!
    @IBOutlet weak var sliderBackgroundLbl: UILabel!
    @IBOutlet weak var adaptiveBtn: UIButton!
    @IBOutlet weak var minimizeBtn: UIButton!
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var changeVideoScaleBtn: UIButton!
    @IBOutlet weak var expiredTimeLbl: UILabel!
    @IBOutlet weak var custommErrorContainer: UIView!
    
    var state = stateOfVC.fullScreen
    var direction = Direction.none
    var link : String?
    
    var playerLayer:AVPlayerLayer?
    var player: AVPlayer?
    var isVideoLandScape : Bool?
    var isVideoMinimize : Bool?
    
    var minimizedOrigin: CGPoint?
    
    var  customActionSheet: CustomActionSheet?
    
    var  viewPortFrame: CGRect?
    var  isContainerVisible: Bool = true
    
    var counterTimer : Timer?
    var counter = 0
    var cashedTime: CGFloat = 0.0
    var sliderChangedValue: CGFloat = 0.0
    
    let vodLink = ["480p x264", "720p x265", "1080p x265","Adaptive"]
    var selectedActionSheetIndex = 0
    
    func initializeView() {
        
        playerContainer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: playerLayerHeight)
        playerContainer.backgroundColor = UIColor.black
        
        playBtn.frame = CGRect(x: (UIScreen.main.bounds.width-playBtnHeight)/2, y: (playerContainer.frame.height-playBtnHeight)/2, width: playBtnHeight, height: playBtnHeight)
        
        minimizeBtn.frame = CGRect(x: defaultMargin, y: 3*defaultMargin , width: changeVideoScaleBtnHeight, height: changeVideoScaleBtnHeight)
        minimizeBtn.setImage(UIImage(named: "dismiss"), for: .normal)
        slider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        slider.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(sliderTapped(gestureRecognizer:))))
        playerContainer.alpha = 1
        
        slider.isHidden = true
        changeVideoScaleBtn.isHidden = true
        
        //adaptive button initialize
        adaptiveBtn.isHidden = false
        adaptiveBtn.backgroundColor = .white
        adaptiveBtn.tintColor = .black
        adaptiveBtn.layer.cornerRadius = 6.0
        adaptiveBtn.layer.masksToBounds = true
        
        //view add panGesture to minimize the player
        playerContainer.isHidden = false
        isVideoMinimize = false
        isVideoLandScape = false
        gestureLbl.isUserInteractionEnabled = true
        playerBtnContainerLbl.isHidden = true
        playerBtnContainerLbl.isUserInteractionEnabled = false
        gestureLbl.frame = CGRect(x: 0, y: defaultMargin, width: UIScreen.main.bounds.width, height: playerLayerHeight)
        gestureLbl.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(sender:))))
        gestureLbl.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(playerTappedToMaximize(sender:))))
        
        addPlayer()
    }
    
    //initialize player view
    func addPlayer()  {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        slider.isHidden = false
        changeVideoScaleBtn.isHidden = false
        counterTimer = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(prozessTimer), userInfo: nil, repeats: true)
        viewPortFrame = self.frame
        if playerLayer?.player?.currentItem != nil {
            playerLayer?.player?.pause()
            playerLayer?.removeFromSuperlayer()
        }
        isVideoLandScape = false
        link = "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
        
        adaptiveBtn.setTitle("Change Video Quality", for: UIControl.State.normal)
        
        let asset = AVURLAsset(url: URL.init(string: link!)!)
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = CGRect(x: 0, y: 20 , width: UIScreen.main.bounds.width, height: playerLayerHeight + 20)
        
        slider.isHidden = false
        sliderBackgroundLbl.isHidden = false
        expiredTimeLbl.isHidden = false
        durationLbl.isHidden = false
        adaptiveBtn.frame = CGRect(x: UIScreen.main.bounds.width - adaptiveWidth - defaultMargin , y: 3*defaultMargin , width: adaptiveWidth, height: adaptiveHeight)
        playerContainer.layer.addSublayer(playerLayer!)
        playerLayer?.player?.play()
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.addSublayer(playerBtnContainerLbl.layer)
        playerLayer?.addSublayer(sliderBackgroundLbl.layer)
        playerLayer?.addSublayer(slider.layer)
        playerLayer?.addSublayer(durationLbl.layer)
        playerLayer?.addSublayer(changeVideoScaleBtn.layer)
        playerLayer?.addSublayer(minimizeBtn.layer)
        playerLayer?.addSublayer(adaptiveBtn.layer)
        playerLayer?.addSublayer(expiredTimeLbl.layer)
        playerLayer?.addSublayer(gestureLbl.layer)
        
        gestureLbl.frame = CGRect(x: 0, y: defaultMargin, width: UIScreen.main.bounds.width, height: playerLayerHeight)
        changeVideoScaleBtn.setBackgroundImage(UIImage(named: "enlarge"), for: .normal)
        playerBtnContainerLbl.frame = gestureLbl.frame
        
        self.playerLayer?.addSublayer(self.playBtn.layer)
        
        sliderBackgroundLbl.frame = CGRect(x: 0, y: playerLayerHeight - sliderBackgroundLblWidth, width: UIScreen.main.bounds.width, height: sliderBackgroundLblWidth)
        
        playerContainer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: playerLayerHeight)
        slider.frame = CGRect(x: expiredTimeLblWidth + 2*defaultMargin , y: sliderBackgroundLbl.frame.origin.y + 2*defaultMargin  , width: UIScreen.main.bounds.width-expiredTimeLblWidth - duratiponLblWidth - changeVideoScaleBtnHeight - 4*defaultMargin  , height: sliderHeight)
        expiredTimeLbl.frame = CGRect(x: defaultMargin/2, y:sliderBackgroundLbl.frame.origin.y + defaultMargin , width: expiredTimeLblWidth + 10, height: expiredTimeLblHeight)
        durationLbl.frame = CGRect(x: UIScreen.main.bounds.width - duratiponLblWidth - changeVideoScaleBtnHeight - 2*defaultMargin , y: sliderBackgroundLbl.frame.origin.y + defaultMargin, width: duratiponLblWidth, height: expiredTimeLblHeight)
        changeVideoScaleBtn.frame = CGRect(x: UIScreen.main.bounds.width - changeVideoScaleBtnHeight - defaultMargin, y:sliderBackgroundLbl.frame.origin.y + defaultMargin/2, width: changeVideoScaleBtnHeight, height: changeVideoScaleBtnHeight)
        durationLbl.textColor = UIColor.white
        var eventTime: Int = 0
        
        playerLayer?.player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.playerLayer?.player!.currentItem?.status == .readyToPlay {
                _ = self.dispatchOnce
                
                let time : Float64 = CMTimeGetSeconds((self.playerLayer?.player!.currentTime())!)
                
                self.slider!.value = Float ( time )
                
                self.expiredTimeLbl.text = String(format: "\(time.format(using: [.hour, .minute, .second])!)")
                self.expiredTimeLbl.textColor = UIColor.white
                eventTime = Int(time)
                
                if self.sliderChangedValue == 0{
                    self.cashedTime = CGFloat ( time )
                }else {
                    
                    let tmp = (CGFloat(time) - self.sliderChangedValue) + self.cashedTime
                    self.cashedTime = tmp
                    return
                }
                
                if eventTime == 1 {
                    self.killTimer()
                }
            }
        }
        
    }
    
    private lazy var dispatchOnce: Void = {
        
        if self.player?.rate == 0 {
            self.playBtn.setImage(UIImage(named: "play"), for: .normal)
        }else{
            self.playBtn.setImage(UIImage(named: "pause"), for: .normal)
        }
        let tim : Float64 = CMTimeGetSeconds((self.playerLayer?.player!.currentItem?.asset.duration)!)
        self.slider.isHidden = false
        self.slider.maximumValue = Float(tim)
        self.durationLbl.text = String(format: "\(tim.format(using: [.hour, .minute, .second])!)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.hidePlayerButtonsOnPlay()
        }
    }()
    
    
    //MARK: change video scale
    func  landScapeMode() {
        
        playerBtnContainerLbl.isHidden = false
        playerBtnContainerLbl.isUserInteractionEnabled = true
        playerBtnContainerLbl.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleHideContainerBtn)))
        
        isVideoLandScape = true
        
        self.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        self.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.width)
        self.playerContainer.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: playerContainer.frame.width)
        self.playerLayer?.frame = playerContainer.frame
        self.gestureLbl.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: playerContainer.frame.width)
        sliderBackgroundLbl.frame = CGRect(x: 0, y: (playerLayer?.frame.height)!-sliderBackgroundLblWidth ,  width: UIScreen.main.bounds.height, height: sliderBackgroundLblWidth)
        
        playerBtnContainerLbl.frame = gestureLbl.frame
        self.slider?.frame = CGRect(x: expiredTimeLblWidth + 4*defaultMargin , y: sliderBackgroundLbl.frame.origin.y + 2*defaultMargin, width: playerContainer.frame.width - expiredTimeLblWidth - changeVideoScaleBtnHeight - duratiponLblWidth - 7*defaultMargin, height: sliderHeight)
        self.expiredTimeLbl.frame = CGRect(x: defaultMargin*2, y: self.slider.frame.origin.y-defaultMargin/2 , width: expiredTimeLblWidth + 2*defaultMargin , height: expiredTimeLblHeight)
        self.durationLbl.frame = CGRect(x: self.playerContainer.frame.width - duratiponLblWidth - changeVideoScaleBtnHeight - 2*defaultMargin, y: expiredTimeLbl.frame.origin.y, width: duratiponLblWidth, height: expiredTimeLblHeight)
        self.adaptiveBtn.frame = CGRect(x: playerContainer.frame.width - adaptiveWidth - defaultMargin, y: 2*defaultMargin, width: adaptiveWidth, height: adaptiveHeight)
        self.changeVideoScaleBtn.frame = CGRect(x: playerContainer.frame.width - changeVideoScaleBtnHeight - defaultMargin, y: playerContainer.frame.height - changeVideoScaleBtnHeight/2 - defaultMargin - defaultMargin/2 , width: changeVideoScaleBtnHeight, height: changeVideoScaleBtnHeight)
        changeVideoScaleBtn.setBackgroundImage(UIImage(named: "scale-down"), for: .normal)
        minimizeBtn.setImage(UIImage(named: "back"), for: .normal)
        self.playBtn.frame = CGRect(x: (playerLayer?.frame.size.width)!/2, y:(playerLayer?.frame.size.height)!/2 , width: playBtnHeight, height: playBtnHeight)
        slider.isHidden = false
        sliderBackgroundLbl.isHidden = false
        expiredTimeLbl.isHidden = false
        durationLbl.isHidden = false
    }
    
    func portraitMode() {
        isVideoLandScape = false
        
        gestureLbl.isUserInteractionEnabled = true
        playerBtnContainerLbl.isHidden = true
        playerBtnContainerLbl.isUserInteractionEnabled = false
        self.transform = CGAffineTransform(rotationAngle: 0)
        self.frame = viewPortFrame ?? CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
        self.playerContainer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: playerLayerHeight)
        
        playerLayer?.frame = CGRect(x: 0, y: 20, width: self.frame.width, height: playerLayerHeight)
        sliderBackgroundLbl.frame = CGRect(x: 0, y: (playerContainer?.frame.height)!-sliderBackgroundLblWidth , width: UIScreen.main.bounds.width, height: sliderBackgroundLblWidth)
        
        self.gestureLbl.frame = CGRect(x: 0, y: defaultMargin, width: self.frame.width, height: playerLayerHeight)
        playerBtnContainerLbl.frame = gestureLbl.frame
        slider.frame = CGRect(x: expiredTimeLblWidth + 2*defaultMargin , y: sliderBackgroundLbl.frame.origin.y + 2*defaultMargin  , width: UIScreen.main.bounds.width-expiredTimeLblWidth - duratiponLblWidth - changeVideoScaleBtnHeight - 4*defaultMargin  , height: sliderHeight)
        changeVideoScaleBtn.frame = CGRect(x: UIScreen.main.bounds.width - changeVideoScaleBtnHeight - defaultMargin, y:sliderBackgroundLbl.frame.origin.y + defaultMargin/2, width: changeVideoScaleBtnHeight, height: changeVideoScaleBtnHeight)
        
        expiredTimeLbl.frame = CGRect(x: defaultMargin/2, y:sliderBackgroundLbl.frame.origin.y + defaultMargin , width: expiredTimeLblWidth + 10, height: expiredTimeLblHeight)
        durationLbl.frame = CGRect(x: UIScreen.main.bounds.width - duratiponLblWidth - changeVideoScaleBtnHeight - 2*defaultMargin , y: sliderBackgroundLbl.frame.origin.y + defaultMargin, width: duratiponLblWidth, height: expiredTimeLblHeight)
        self.adaptiveBtn.frame = CGRect(x: playerContainer.frame.width - adaptiveWidth - defaultMargin, y: 4*defaultMargin, width: adaptiveWidth, height: adaptiveHeight)
        changeVideoScaleBtn.setBackgroundImage(UIImage(named: "enlarge"), for: .normal)
        minimizeBtn.setImage(UIImage(named: "dismiss"), for: .normal)
        self.playBtn.frame = CGRect(x: (playerLayer?.frame.size.width)!/2, y:(playerLayer?.frame.size.height)!/2 , width: playBtnHeight, height: playBtnHeight)
        slider.isHidden = false
        sliderBackgroundLbl.isHidden = false
        expiredTimeLbl.isHidden = false
        durationLbl.isHidden = false
    }
    
    @IBAction func changeVideoOrientation(_ sender: Any) {
        
        if isVideoLandScape == false {
            landScapeMode()
            
        }else {
            portraitMode()
        }
    }
    
    @objc func handleHideContainerBtn(){
        
        if isContainerVisible == true {
            hidePlayerButtonsOnPlay()
        }else{
            unhidePlayerButtonOnTap()
        }
    }
    
    // Gesture selector initialize
    @objc func playerTappedToMaximize(sender:UITapGestureRecognizer){
        guard isVideoMinimize == true else {
            if isContainerVisible == true {
                hidePlayerButtonsOnPlay()
            }else{
                unhidePlayerButtonOnTap()
            }
            return
        }
        maximizeView()
    }
    
    func maximizeView() {
        isVideoMinimize = false
        self.playerContainer.backgroundColor = UIColor.black
        self.state = .fullScreen
        let factor: CGFloat = 1 - 0.2649
        self.swipeToMinimize(translation: factor, toState: .fullScreen)
        self.didEndedSwipe(toState: self.state)
        self.animate()
        adaptiveBtn.isUserInteractionEnabled = true
        if isContainerVisible == true {
            self.minimizeBtn.isHidden = false
            self.slider.isHidden = false
            self.durationLbl.isHidden = false
            self.expiredTimeLbl.isHidden = false
            self.adaptiveBtn.isHidden = false
            self.changeVideoScaleBtn.isHidden = false
        }
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        if player?.rate == 0 {
            let seconds : Float64 = CMTimeGetSeconds((player?.currentItem?.asset.duration)!)
            if self.expiredTimeLbl.text == String(format: "\(seconds.format(using: [.hour, .minute, .second])!)") {
                playerLayer?.player?.seek(to: .zero)
                playBtn.setImage(UIImage(named: "pause"), for: .normal)
                playerLayer?.player?.play()
                hidePlayerButtonsOnPlay()
                return
            }
            playBtn.setImage(UIImage(named: "pause"), for: .normal)
            playerLayer?.player?.play()
            hidePlayerButtonsOnPlay()
            
        }else{
            playBtn.setImage(UIImage(named: "play"), for: .normal)
            playerLayer?.player?.pause()
            unhidePlayerButtonOnTap()
        }
    }
    @objc func minimizePlayer() {
        if UIDevice.current.userInterfaceIdiom == .pad{// || player == nil{
            playerLayer?.player?.pause()
            killTimer()
            return
        }
        minimizeBtn.setImage(UIImage(named: "dismiss"), for: .normal)
        gestureLbl.isUserInteractionEnabled = true
        playerBtnContainerLbl.isHidden = true
        playerBtnContainerLbl.isUserInteractionEnabled = false
        adaptiveBtn.isUserInteractionEnabled = false
        
        isVideoMinimize = true
        self.direction = .up
        var finalState = stateOfVC.fullScreen
        let factor: CGFloat = 0.0009
        changeValues(scaleFactor: factor)
        
        finalState = .minimized
        self.state = finalState
        animate()
        didEndedSwipe(toState: self.state)
        
        
        self.minimizeBtn.isHidden = true
        self.slider.isHidden = true
        self.durationLbl.isHidden = true
        self.expiredTimeLbl.isHidden = true
        self.adaptiveBtn.isHidden = true
        self.changeVideoScaleBtn.isHidden = true
        self.backgroundColor = UIColor.clear
        self.playerContainer.backgroundColor = UIColor.black// UIColor.clear
    }
    
    @IBAction func minimizeBtnPlayerTapped(_ sender: Any) {
        
        if UIDevice.current.userInterfaceIdiom == .pad || player == nil{
            playerLayer?.player?.pause()
            killTimer()
            return
        }
        if isVideoLandScape == true{
            portraitMode()
            return
        }
        minimizePlayer()
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player!.seek(to: targetTime)
        sliderChangedValue = CGFloat(playbackSlider.value)
        print("=======================%@",cashedTime)
        if player!.rate == 0
        {
            player?.play()
            playBtn.setImage(UIImage(named: "pause"), for: .normal)
            hidePlayerButtonsOnPlay()
        }
    }
    //MARK:Pangesture selector
    @objc func handlePanGesture(sender:UIPanGestureRecognizer){
        if  isVideoLandScape == true {
            return
        }
        if sender.state == .began {
            let velocity = sender.velocity(in: nil)
            if abs(velocity.x) < abs(velocity.y) {
                self.direction = .up
            } else {
                self.direction = .left
            }
        }
        var finalState = stateOfVC.fullScreen
        switch self.state {
        case .fullScreen:
            isVideoMinimize = true
            self.backgroundColor = UIColor.clear
            let factor = (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
            changeValues(scaleFactor: factor)
            swipeToMinimize(translation: factor, toState: .minimized)
            finalState = .minimized
            adaptiveBtn.isUserInteractionEnabled = false
            
        case .minimized:
            isVideoMinimize = true
            if self.direction == .left {
                finalState = .hidden
                let factor: CGFloat = sender.translation(in: nil).x
                self.swipeToMinimize(translation: factor, toState: .hidden)
                adaptiveBtn.isUserInteractionEnabled = false
            } else {
                finalState = .fullScreen
                let factor = 1 - (abs(sender.translation(in: nil).y) / UIScreen.main.bounds.height)
                self.swipeToMinimize(translation: factor, toState: .fullScreen)
                self.minimizeBtn.isHidden = false
                self.slider.isHidden = false
                self.durationLbl.isHidden = false
                self.expiredTimeLbl.isHidden = false
                
                isVideoMinimize = false
                adaptiveBtn.isUserInteractionEnabled = true
            }
        default: break
        }
        if sender.state == .ended {
            self.state = finalState
            animate()
            didEndedSwipe(toState: self.state)
            if self.state == .hidden {
                self.playerLayer?.player?.pause()
            }
        }
    }
    func changeValues(scaleFactor: CGFloat) {
        
        let scale = CGAffineTransform.init(scaleX: (1 - 0.5 * scaleFactor), y: (1 - 0.5 * scaleFactor))
        let trasform = scale.concatenating(CGAffineTransform.init(translationX: -(self.bounds.width / 4 * scaleFactor), y: -(self.bounds.height / 4 * scaleFactor)))
        self.transform = trasform
    }
    
    func swipeToMinimize(translation: CGFloat, toState: stateOfVC) {
        switch toState {
        case .fullScreen:
            self.playerContainer.backgroundColor = UIColor.black
            self.frame.origin = positionDuringSwipe(scaleFactor: translation)
        case .hidden:
            self.frame.origin.x = UIScreen.main.bounds.width/2 - abs(translation) - 10
            playerLayer?.player?.pause()
            killTimer()
        case .minimized:
            self.playerContainer.backgroundColor = UIColor.black
            self.frame.origin = self.positionDuringSwipe(scaleFactor: translation)
            self.frame.origin = self.positionDuringSwipe(scaleFactor: translation)
        }
    }
    
    func didEndedSwipe(toState: stateOfVC) {
        animatePlayView(toState: toState)
    }
    
    func positionDuringSwipe(scaleFactor: CGFloat) -> CGPoint {
        let width = UIScreen.main.bounds.width * 0.5 * scaleFactor
        let height = width * 9 / 16
        let x = (UIScreen.main.bounds.width - 10) * scaleFactor - width
        let y = (UIScreen.main.bounds.height - 10) * scaleFactor - height
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }
    
    func animatePlayView(toState: stateOfVC) {
        switch toState {
        case .fullScreen:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [.beginFromCurrentState], animations: {
                self.frame.origin = self.fullScreenOrigin
                self.playerLayer?.frame.origin = CGPoint(x: 0, y: 0)
                self.backgroundColor = .black
                
            })
        case .minimized:
            UIView.animate(withDuration: 0.3, animations: {
                self.frame.origin = self.minimizedOrigin!
                self.playerLayer?.frame.origin = CGPoint(x: 0, y: -20)
            })
        case .hidden:
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowAnimatedContent, animations: {
                self.frame.origin = self.hiddenOrigin
            }, completion: { (completedAnimation) in
                self.removeFromSuperview()
            })
        }
    }
    
    let hiddenOrigin: CGPoint = {
        let y = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 9 / 32) - 10
        let x = -UIScreen.main.bounds.width
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    
    let fullScreenOrigin = CGPoint.init(x: 0, y: 0)
    
    func animate()  {
        switch self.state {
        case .fullScreen:
            UIView.animate(withDuration: 0 , animations: {
                
                self.transform = CGAffineTransform.identity
                //  UIApplication.shared.isStatusBarHidden = true
            })
        case .minimized:
            UIView.animate(withDuration: 0 , animations: {
                // UIApplication.shared.isStatusBarHidden = false
                let scale = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                let trasform = scale.concatenating(CGAffineTransform.init(translationX: -self.bounds.width/4, y: -self.bounds.height/4))
                self.transform = trasform
            })
        default: break
        }
    }
    
    //MARK: adaptive action sheet handling
    @IBAction func adaptiveBtnPressed(_ sender: Any) {
        initializeCustomActionSheetView(vodlinks:vodLink, selectedIndex: selectedActionSheetIndex)
    }
    
    // actionSheet selector initialize
    func addNewLink(tmpLink : String , isLandScape: Bool , buttonTitle: String) {
        playerLayer?.player?.pause()
        adaptiveBtn.isHidden = false
        adaptiveBtn.setTitle(buttonTitle, for: UIControl.State.normal)
        
        link = tmpLink
    }
    
    // MARK: Add gesture to slider to cgange value
    @objc func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        var pointTapped: CGPoint = gestureRecognizer.location(in: self)
        pointTapped.x -= 0  //30Subtract left constraint (distance of the slider's origin from "self.view"
        
        let positionOfSlider: CGPoint = slider.frame.origin
        let widthOfSlider: CGFloat = slider.frame.size.width
        
        //If tap is too near from the slider thumb, cancel
        let thumbPosition = CGFloat((slider.value / slider.maximumValue)) * widthOfSlider
        let dif = abs(pointTapped.x - thumbPosition)
        let minDistance: CGFloat = 51.0  //You can calibrate this value, but I think this is the maximum distance that tap is recognized
        if dif < minDistance {
            // return
        }
        var newValue: CGFloat
        if pointTapped.x < 10 {
            newValue = 0  //Easier to set slider to 0
        } else {
            newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(slider.maximumValue) / widthOfSlider)
        }
        
        slider.setValue(Float(newValue), animated: true)
        self.expiredTimeLbl.text = String(format: "\(Float64(newValue).format(using: [.hour, .minute, .second])!)")
        let targetTime:CMTime = CMTimeMake(value: Int64(newValue), timescale: 1)
        
        let seconds : Float64 = CMTimeGetSeconds((player?.currentItem?.asset.duration)!)
        if expiredTimeLbl.text == String(format: "\(seconds.format(using: [.hour, .minute, .second])!)") {
            self.playBtn.setImage(UIImage(named: "retry"), for: .normal)
        }
        player!.seek(to: targetTime)
        // cashedTime = newValue - cashedTime
        print("=======================%@",cashedTime)
        sliderChangedValue = newValue
        if player!.rate == 0
        {
            player?.play()
            playBtn.setImage(UIImage(named: "pause"), for: .normal)
            hidePlayerButtonsOnPlay()
        }
    }
    
    // action sheet implementation
    var parentView: CustomActionSheetContainer?
    var actionSheetContainer: UIView?
    func initializeCustomActionSheetView(vodlinks: Array<String>, selectedIndex: Int){
        var titleArray = Array<String>.init()
        var linkArray = Array<String>.init()
        
        for index in 0..<vodlinks.count {
            
            linkArray.append(vodlinks[index])
            titleArray.append(vodlinks[index])
        }
        
        // create parent view
        if isVideoLandScape == true {
            parentView = CustomActionSheetContainer(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.width))
        }else {
            parentView = CustomActionSheetContainer(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height))
        }
        parentView?.backgroundColor = .black
        
        parentView?.alpha = 0.8
        self.addSubview(parentView!)
        
        parentView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissCustomActionSheet)))
        
        // create custom action sheet
        let defaultItemHeight = 50
        var dynamicY: CGFloat = -20
        if  isVideoLandScape ==  true {
            dynamicY = 0
        }
        
        actionSheetContainer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: CGFloat(defaultItemHeight + defaultItemHeight * vodlinks.count)))
        
        actionSheetContainer?.backgroundColor = UIColor.black
        
        //create action sheet title view
        customActionSheet = Bundle.main.loadNibNamed("customActionSheet", owner: self, options: nil)?.first as? CustomActionSheet
        customActionSheet?.frame = CGRect(x: 0, y: dynamicY, width: UIScreen.main.bounds.width, height: 50)
        //actionSheet background color
        let actionBackGroundView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: CGFloat(defaultItemHeight + defaultItemHeight * vodlinks.count)))
        actionBackGroundView.backgroundColor = UIColor.black
        
        dynamicY += 50
        let title = "selectQuality"
        customActionSheet?.actionButton.setTitle(title, for: UIControl.State.normal)
        actionSheetContainer?.addSubview(customActionSheet!)
        var tmpFrame : CGRect = CGRect.zero
        tmpFrame.size.width = UIScreen.main.bounds.height
        
        //add this part
        customActionSheet?.actionButton.frame = CGRect(x: 0 , y: 0 , width: UIScreen.main.bounds.width, height:49)
        if isVideoLandScape == true {
            customActionSheet?.actionButton.frame = CGRect(x: (customActionSheet?.actionButton.frame.origin.y)! , y: (customActionSheet?.actionButton.frame.origin.x)! , width: UIScreen.main.bounds.height, height: (customActionSheet?.actionButton.frame.height)!)
        }
        customActionSheet?.actionButton.tintColor = .white
        customActionSheet?.actionButton.isSelected = false
        for i in 0..<vodlinks.count {
            customActionSheet = Bundle.main.loadNibNamed("customActionSheet", owner: self, options: nil)?.first as? CustomActionSheet
            customActionSheet?.frame = CGRect(x: 0, y: dynamicY, width: UIScreen.main.bounds.width, height: 50)
            //add this part
            customActionSheet?.actionButton.frame = CGRect(x: 0 , y: 0 , width: UIScreen.main.bounds.width, height:49)
            if isVideoLandScape == true {
                customActionSheet?.frame = CGRect(x: (customActionSheet?.frame.origin.x)!, y: (customActionSheet?.frame.origin.y)!, width: UIScreen.main.bounds.height, height: (customActionSheet?.frame.height)!)
                
                customActionSheet?.actionButton.frame = CGRect(x: (customActionSheet?.actionButton.frame.origin.y)! , y: (customActionSheet?.actionButton.frame.origin.x)! , width: UIScreen.main.bounds.height, height: (customActionSheet?.actionButton.frame.height)!)
            }
            
            dynamicY += 50
            actionSheetContainer?.addSubview(customActionSheet!)
            let title: String = linkArray[i]
            
            parentView?.linkDic[title] = linkArray[i]
            customActionSheet?.actionButton.setTitle(title, for: UIControl.State.normal)
            customActionSheet?.actionButton.addTarget(self, action: #selector(actionSheetTapped), for: UIControl.Event.allEvents)
            customActionSheet?.actionButton.tintColor = .white
            if i == selectedIndex {
                customActionSheet?.actionButton.tintColor = .red
            }
        }
        
        self.addSubview(actionSheetContainer!)
        actionSheetContainer?.bringSubviewToFront(self)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [.beginFromCurrentState], animations: {
            if self.isVideoLandScape == true {
                self.actionSheetContainer?.frame = CGRect(x: 0, y: self.frame.width - CGFloat(defaultItemHeight + defaultItemHeight * vodlinks.count) , width:UIScreen.main.bounds.height , height:CGFloat(defaultItemHeight + defaultItemHeight * vodlinks.count) )
                
            }else{
                self.actionSheetContainer?.frame = CGRect(x: 0, y: self.frame.height - CGFloat(defaultItemHeight + defaultItemHeight * vodlinks.count) , width: UIScreen.main.bounds.width , height: CGFloat(defaultItemHeight + defaultItemHeight * vodlinks.count) )
            }
        })
        
    }
    
    @objc func actionSheetTapped(_ Sender: Any){
        
        let key = (Sender as! UIButton).titleLabel?.text
        guard parentView?.linkDic[key!] != nil else{
            return
        }
        
        self.updateQualityList(link: (self.parentView?.linkDic[key!])!)
        self.addNewLink(tmpLink: (parentView?.linkDic[key!])!, isLandScape: isVideoLandScape! , buttonTitle: key!)
        
        dismissCustomActionSheet()
    }
    
    @objc func updateQualityList(link: String) {
        if let linkIndex = vodLink.firstIndex(where: {$0 == link}) {
            self.selectedActionSheetIndex = linkIndex
            let link = vodLink[linkIndex]
            actionSheetContainer?.subviews.forEach({ customActionSheet in
                if let sheet = customActionSheet as? CustomActionSheet {
                    DispatchQueue.main.async {
                        if sheet.actionButton.titleLabel?.text == link {
                            sheet.actionButton.tintColor = .red
                        } else {
                            sheet.actionButton.tintColor = .white
                        }
                    }
                    self.setNeedsLayout()
                }
            })
        }
        
      
    }
    
    @objc func dismissCustomActionSheet() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [.beginFromCurrentState], animations: {
            
            self.parentView?.removeFromSuperview()
            self.actionSheetContainer?.removeFromSuperview()
        })
    }
    
    func hidePlayerButtonsOnPlay() {
        
        if self.player?.rate == 0 {
            return
        }
        isContainerVisible = false
        self.playBtn.isHidden = true
        self.minimizeBtn.isHidden = true
        self.adaptiveBtn.isHidden = true
        self.slider.isHidden = true
        self.sliderBackgroundLbl.isHidden = true
        self.expiredTimeLbl.isHidden = true
        self.durationLbl.isHidden = true
        self.changeVideoScaleBtn.isHidden = true
    }
    
    func unhidePlayerButtonOnTap() {
        
        isContainerVisible = true
        self.playBtn.isHidden = false
        self.minimizeBtn.isHidden = false
        self.adaptiveBtn.isHidden = false
        self.slider.isHidden = false
        self.sliderBackgroundLbl.isHidden = false
        self.expiredTimeLbl.isHidden = false
        self.durationLbl.isHidden = false
        self.changeVideoScaleBtn.isHidden = false
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.hidePlayerButtonsOnPlay()
        }
    }
    
    //CounterTimer functions implementation
    func killTimer() {
        
        counterTimer?.invalidate()
        counterTimer = nil
    }
    
    @objc func prozessTimer() {
        counter += 1
    }
    
}

// MARK : TimeInterval extension
extension TimeInterval {
    func format(using units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        if self .isNaN {
            print("isNan")
            return " "
        }
        return formatter.string(from: self)
    }
}
