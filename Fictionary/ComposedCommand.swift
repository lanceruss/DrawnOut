//
//  ComposedCommand.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

struct ComposedCommand : DrawCommand {
    
    private var commands: [DrawCommand]
    
    init(commands: [DrawCommand]) {
        self.commands = commands
    }
    
    func execute(canvas: Canvas) {
        self.commands.map { $0.execute(canvas) }
    }
    
    mutating func addCommand(command: DrawCommand) {
        self.commands.append(command)
    }
}
