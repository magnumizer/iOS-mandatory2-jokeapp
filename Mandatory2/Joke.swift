//
//  Joke.swift
//  Mandatory2
//
//  Created by Magnus Holm Svendsen on 01/05/2018.
//  Copyright © 2018 Magnus Holm Svendsen. All rights reserved.
//

import UIKit

class Joke: NSObject {
    
    var localTitle: String = ""
    var localContent: String = ""

    open var title: String { get{ return localTitle} set{ localTitle = newValue} }
    open var content: String { get{ return localContent} set{ localContent = newValue} }
    
}
