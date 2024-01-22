//
//  kfdoverwrite.swift
//  misaka
//
//  Created by mini on 2023/08/13.
//

import Foundation

func kfdOverwrite(from: String, to: String) -> UInt64 {
    let cPathtoTargetFont = to.withCString { ptr in
        return strdup(ptr)
    }
    let cFontURL = from.withCString { ptr in
        return strdup(ptr)
    }
    let mutablecFontURL = UnsafeMutablePointer<Int8>(mutating: cFontURL)
    return funVnodeOverwrite2(cPathtoTargetFont, mutablecFontURL)
}

