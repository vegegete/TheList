//
//  SoundPlayer.swift
//  TheList
//
//  Created by Nenad Matic on 25/03/2020.
//  Copyright © 2020 Nenad Matic. All rights reserved.
//

import Foundation
import AVFoundation


class SoundPlayer {

var player: AVAudioPlayer?

    func playSound(with name: String) {
    guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }

    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        //try AVAudioSession.sharedInstance().setActive(true)

        /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
       player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
       guard let player = player else { return }

        player.play()

    } catch let error {
        print(error.localizedDescription)
    }
}
}
