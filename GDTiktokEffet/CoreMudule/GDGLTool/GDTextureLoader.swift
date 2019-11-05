//
//  GDTextureLoader.swift
//  GDTiktokEffet
//
//  Created by GDzqw on 2019/11/6.
//  Copyright © 2019 gdAOE. All rights reserved.
//

import UIKit

enum GDGLPowerOf2: GLsizei {
    case aglk1 = 1
    case aglk2 = 2
    case aglk4 = 4
    case aglk8 = 8
    case aglk16 = 16
    case aglk32 = 32
    case aglk64 = 64
    case aglk128 = 128
    case aglk256 = 256
    case aglk512 = 512
    case aglk1024 = 1024
}

struct GDTextureInfo {
    var textureID: GLuint
    var target: GLenum
    var width: GLsizei
    var height: GLsizei
}

class GDTextureLoader: NSObject {
    class func texture(image: CGImage, options:Dictionary<String, Any>? = nil) throws -> GDTextureInfo {
        var width: GLsizei = 0
        var height: GLsizei = 0
        let imageData = data(image: image, width: &width, height: &height)
        
        var textureBufferID: GLuint = 0
        glGenTextures(1, &textureBufferID)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureBufferID)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), imageData)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        free(imageData)
        return GDTextureInfo(textureID: textureBufferID, target: GLenum(GL_TEXTURE_2D), width: width, height: height)
    }
}

func data(image: CGImage, width: inout GLsizei, height: inout GLsizei) -> UnsafeMutablePointer<UInt8> {
    let oWidth = GLsizei(image.width)
    let oHeight = GLsizei(image.height)
    assert(oWidth > 0, "wrong width")
    assert(oHeight > 0, "wrong height")
    
    width = calculatePowerOf2ForDimension(dimension: oWidth)
    height = calculatePowerOf2ForDimension(dimension: oHeight)
    
    let imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(width * height * 4))
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    if let context = CGContext(
        data: imageData, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 4 * Int(width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) {
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        context.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        return imageData
    } else {
        fatalError("unable to create Core Graphics context")
    }
}

func calculatePowerOf2ForDimension(dimension: GLsizei) -> GLsizei {
    var result = GDGLPowerOf2.aglk1.rawValue;

    if dimension > GDGLPowerOf2.aglk512.rawValue {
        result = GDGLPowerOf2.aglk1024.rawValue;
    } else if dimension > GDGLPowerOf2.aglk256.rawValue {
        result = GDGLPowerOf2.aglk512.rawValue;
    } else if dimension > GDGLPowerOf2.aglk128.rawValue {
        result = GDGLPowerOf2.aglk256.rawValue;
    } else if dimension > GDGLPowerOf2.aglk64.rawValue {
        result = GDGLPowerOf2.aglk128.rawValue;
    } else if dimension > GDGLPowerOf2.aglk32.rawValue {
        result = GDGLPowerOf2.aglk64.rawValue;
    } else if dimension > GDGLPowerOf2.aglk16.rawValue {
        result = GDGLPowerOf2.aglk32.rawValue;
    } else if dimension > GDGLPowerOf2.aglk8.rawValue {
        result = GDGLPowerOf2.aglk16.rawValue;
    } else if dimension > GDGLPowerOf2.aglk4.rawValue {
        result = GDGLPowerOf2.aglk8.rawValue;
    } else if dimension > GDGLPowerOf2.aglk2.rawValue {
        result = GDGLPowerOf2.aglk4.rawValue;
    } else if dimension > GDGLPowerOf2.aglk1.rawValue {
        result = GDGLPowerOf2.aglk2.rawValue;
    }

    return result;
}
