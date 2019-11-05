//
//  GDShader.swift
//  GDTiktokEffet
//
//  Created by GDzqw on 2019/11/6.
//  Copyright © 2019 gdAOE. All rights reserved.
//

import UIKit
import OpenGLES

class GDRenderBufferParam {
    var framebufferWidth: GLint = 0
    var framebufferHeight: GLint = 0
}

class GDShader: NSObject {
    // Create render display layer
    class public func createEALayer(context: EAGLContext, view: UIView) -> GDRenderBufferParam {
        EAGLContext.setCurrent(context)
        let layer: CAEAGLLayer = CAEAGLLayer.init()
        layer.frame = CGRect.init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width)
        layer.contentsScale = UIScreen.main.scale
        view.layer.addSublayer(layer)

        var renderBuffer: GLuint = 0
        glGenRenderbuffers(1, &renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        context.renderbufferStorage(Int(GL_RENDERBUFFER), from: layer)
       
        var temWidth: GLint = 0
        var temHeight: GLint = 0
        context.renderbufferStorage(Int(GL_RENDERBUFFER), from: layer)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &temWidth)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &temHeight)
        let param: GDRenderBufferParam = GDRenderBufferParam.init()
        param.framebufferWidth = temWidth
        param.framebufferHeight = temHeight
        
        // deinit
        var frameBuffer: GLuint = 0
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), renderBuffer)

        return param
    }
    
    // Compile Shader
    class public func compileShader(name: String, type: GLenum) -> GLuint {
        let extionName = (type == GLenum(GL_VERTEX_SHADER) ? "vs" : "fs")
        let path: String = Bundle.main.path(forResource: name, ofType: extionName) ?? ""
        if path.count > 0 {
            do {
                let shaderContent: String = try String.init(contentsOfFile: path, encoding: .utf8)
                if shaderContent.count > 0 {
                    let shader: GLuint = glCreateShader(type)
                    
                    var shaderContentLength: GLint = GLint(Int32(shaderContent.lengthOfBytes(using: .utf8)))
                    var shaderCString = NSString(string: shaderContent).utf8String
                    glShaderSource(shader, GLsizei(1), &shaderCString, &shaderContentLength)
                    
                    glCompileShader(shader)
                    
                    var compileStatus: GLint = GLint(0)
                    glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &compileStatus)
                    if compileStatus == GLenum(GL_FALSE) {
                        var infoLog = [GLchar](repeating: 0, count: 512)
                        glGetProgramInfoLog(shader, 512, nil, &infoLog)
                        fatalError(String(cString:infoLog))
                    }
                    return shader
                }
            } catch {
                fatalError("shader compile error")
            }
        } else {
            fatalError("shader compile path is nil")
        }
        return 0
    }
    
    class func bufferOffset(_ n: Int) -> UnsafeRawPointer {
      return UnsafeRawPointer(bitPattern: n)!
    }
}
