//
//  ComposedCommand.swift
//  Fictionary
//
//  Created by Lance Russ on 6/30/16.
//  Copyright © 2016 Lance Russ. All rights reserved.
//

import UIKit

struct ComposedCommand : DrawCommand {
    
    fileprivate var commands: [DrawCommand]
    
    init(commands: [DrawCommand]) {
        self.commands = commands
    }
    
    func execute(_ canvas: Canvas) {
        self.commands.map { $0.execute(canvas) }
    }
    
    mutating func addCommand(_ command: DrawCommand) {
        self.commands.append(command)
    }
}
