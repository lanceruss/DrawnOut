//
//  DrawCommands.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

protocol Canvas {
    var context:CGContext {get}
    func reset()
}

protocol DrawCommand {
    func execute(canvas: Canvas)
}

protocol DrawCommandReceiver {
    func executeCommands(commands: [DrawCommand])
}
