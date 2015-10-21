//
//  ViewController.swift
//  mp3PlayerPP
//
//  Created by MP on 2015-10-04.
//  Copyright © 2015 MP. All rights reserved.
//

import UIKit
import AVFoundation




class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //need to makre sure this list is never empty
    //will set the default nowPlay be playlist[0]
    var playlist = ["bukeshuo","13.1","13.2","14.1","14.2","15.1","15.2"]
    var lastPlayAt : [Double] = [0,0,0,0,0,0,0]
    var lastIndex:Int = 0
    var nowPlaying: Int!
    
    
    var Timer: NSTimer!
    var player: AVAudioPlayer!
    let NSLASTPLAYKEY = "lastPlay"
    let NSLASTPLAYIDX = "lastPlayindex"
    
    @IBOutlet weak var playlistTableview: UITableView!

    @IBAction func speedChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            player.rate = 1.0;
        case 1:
            player.rate = 1.25;
        case 2:
            player.rate = 1.5
        default:
            break; 
        }
    }
    
    
    @IBOutlet weak var playPause: UIBarButtonItem!
    
    @IBAction func playPauseButton(sender: AnyObject) {
        if player.playing {
            
            player.pause()
            playPause.title = "Play"
            if Timer != nil {
                Timer.invalidate()
            }
            lastPlayAt[nowPlaying] = player.currentTime
            writeLastPlayToDevice()
            
        } else {

            player.currentTime = lastPlayAt[nowPlaying]
            Timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateSlider"), userInfo: nil, repeats: true)
            player.play()
            playPause.title = "Pause"
            lastIndex = nowPlaying
            writeLastPlayToDevice()
            playlistTableview.reloadData()
        }
    }
    
    @IBAction func stop(sender: AnyObject) {
        player.stop()
        playPause.title = "Play"
        player.currentTime = 0;
        sliderValue.value = 0;
        if Timer != nil {
         Timer.invalidate()
        }
        
    }
    
    
    
    @IBAction func sliderChanged(sender: AnyObject) {

        player.currentTime = NSTimeInterval(sliderValue.value * Float(player.duration))
        
        
    }
    
    @IBOutlet var sliderValue: UISlider!
    
    func updateSlider(){
        sliderValue.value = Float(player.currentTime)/Float(player.duration)
    }
    
    
    func play_audio(){
 
        let audioPath = NSBundle.mainBundle().pathForResource(playlist[nowPlaying], ofType: "mp3")!
        do {
            player = try AVAudioPlayer(contentsOfURL: NSURL(string: audioPath)!)
            player.enableRate = true
        }
        catch {
            print("Error: play_audio")
        }
        
        player.prepareToPlay()
        
    }


    func background_play_setup(){
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch {
            print("Error: background_play_setup")
        }
    }
    
    
    // MARK : last play 
    func loadLastPlayFromDevice(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if let played = defaults.objectForKey(NSLASTPLAYKEY)
        {
            lastPlayAt = played as! [Double]
        }
        if let idx = defaults.objectForKey(NSLASTPLAYIDX)
        {
            lastIndex = idx as! Int
        }
    }
    
    func writeLastPlayToDevice(){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(lastPlayAt, forKey: NSLASTPLAYKEY)
        defaults.setObject(lastIndex, forKey: NSLASTPLAYIDX)
    }
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        playlistTableview.delegate = self
        playlistTableview.dataSource = self

        nowPlaying = 0
        background_play_setup()
        play_audio()
        loadLastPlayFromDevice()
        playlistTableview.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if (indexPath.row == lastIndex) {
         cell.textLabel?.text = playlist[indexPath.row] + "  |>"
        } else {
            cell.textLabel?.text = playlist[indexPath.row]

        }
        // Configure the cell...
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        stop(self)
        nowPlaying = indexPath.row
        play_audio()
        playPauseButton(self)
    }
    


}

