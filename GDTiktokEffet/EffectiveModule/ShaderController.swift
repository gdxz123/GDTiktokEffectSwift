//
//  ShaderController.swift
//  GDTiktokEffet
//
//  Created by GDzqw on 2019/11/6.
//  Copyright © 2019 gdAOE. All rights reserved.
//

import UIKit
import GLKit

struct ScenceVertex {
    var positionCoord: GLKVector3
    var textureCoord: GLKVector2
}

class ShaderController: UIViewController {
    private let context: EAGLContext = EAGLContext.init(api: .openGLES3)!
    private var renderParam: GDRenderBufferParam = GDRenderBufferParam.init()
    private var textureInfo: GDTextureInfo?
    private var program: GLuint?
    private var vertexBuffer: GLuint?
    private var startTimeInterval: TimeInterval = 0 // 开始的时间戳
    private var pollTimer: CADisplayLink?
    private var vertices: Array<ScenceVertex> = [
        ScenceVertex(positionCoord: GLKVector3Make(-1.0, -1.0, 0.0), textureCoord: GLKVector2Make(0, 0)),
        ScenceVertex(positionCoord: GLKVector3Make( 1.0, -1.0, 0.0), textureCoord: GLKVector2Make(1, 0)),
        ScenceVertex(positionCoord: GLKVector3Make(-1.0,  1.0, 0.0), textureCoord: GLKVector2Make(0, 1)),
        ScenceVertex(positionCoord: GLKVector3Make( 1.0,  1.0, 0.0), textureCoord: GLKVector2Make(1, 1))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.renderParam = GDShader.createEALayer(context: self.context, view: self.view)
        self.createTextureUI()
        self.startAnimateAction()
    }
    
    deinit {
        if EAGLContext.current() == self.context {
            EAGLContext.setCurrent(nil)
        }
    }
    
    // private method
    private func startAnimateAction() {
        self.startTimeInterval = 0
        if let pollTimer: CADisplayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(pollTimerAction)) {
            pollTimer.add(to: RunLoop.current, forMode: .default)
            self.pollTimer = pollTimer
        }
    }
    
    @objc private func pollTimerAction() {
        if let program: GLuint = self.program, let vBuffer: GLuint = vertexBuffer, let pTimer = self.pollTimer {
            if self.startTimeInterval == 0 {
                self.startTimeInterval = pTimer.timestamp
            }
            glUseProgram(program)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), vBuffer)
            
            // input the time param
            let time: GLfloat = GLfloat(pTimer.timestamp - self.startTimeInterval)
            let timeAddress: GLint = GLint(glGetUniformLocation(program, "time"))
            glUniform1f(timeAddress, time)
            
            glClear(GLenum(GL_COLOR_BUFFER_BIT))
            glClearColor(0.0, 0.0, 0.0, 1.0)
            glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
            self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        }
    }
    
    private func createTextureUI() {
        self.textureInfo = self.creatTexureInfo()
        if let textureInfo: GDTextureInfo = self.textureInfo {
            glViewport(0, 0, self.renderParam.framebufferWidth, self.renderParam.framebufferHeight)

            var vertexBuffer: GLuint = 0
            glGenBuffers(1, &vertexBuffer)
            glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
            glBufferData(GLenum(GL_ARRAY_BUFFER), self.vertices.size(), self.vertices, GLenum(GL_STATIC_DRAW))
            self.vertexBuffer = vertexBuffer
            
            self.program = self.programWithShaderName(shaderName: "Burr")
            if let program = self.program {
                glUseProgram(program)
                
                let position: GLuint = GLuint(glGetAttribLocation(program, "position"))
                glEnableVertexAttribArray(position)
                glVertexAttribPointer(position, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<ScenceVertex>.size), nil)
                
                let textureCoord: GLuint = GLuint(glGetAttribLocation(program, "textureCoord"))
                glEnableVertexAttribArray(textureCoord)
                glVertexAttribPointer(textureCoord, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<ScenceVertex>.size), GDShader.bufferOffset(4 * MemoryLayout<GLfloat>.size))
                
                let textureImage: GLint = GLint(glGetUniformLocation(program, "textureImage"))
                glActiveTexture(GLenum(GL_TEXTURE0))
                glBindTexture(GLenum(GL_TEXTURE_2D), textureInfo.textureID)
                glUniform1i(textureImage, 0)
                
                // draw
                glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
                glClearColor(0.0, 0.0, 0.0, 1.0)
                glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)
                self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
            }
        }
    }
    
    private func creatTexureInfo() -> GDTextureInfo? {
        if let cgImage = UIImage(named: "launchLogo")?.cgImage {
            do {
                let textureInfo: GDTextureInfo = try GDTextureLoader.texture(image: cgImage)
                return textureInfo
            } catch {
                fatalError("Unable to load the targetInfo")
            }
        } else {
            fatalError("Unable to load the cgImage")
        }
        return nil
    }
    
    private func programWithShaderName(shaderName: String) -> GLuint {
        let vShader: GLuint = GDShader.compileShader(name: "Burr", type: GLenum(GL_VERTEX_SHADER))
        let fShader: GLuint = GDShader.compileShader(name: "Burr", type: GLenum(GL_FRAGMENT_SHADER))
        
        let program: GLuint = glCreateProgram()
        glAttachShader(program, vShader)
        glAttachShader(program, fShader)
        
        glLinkProgram(program)
        
        var linkStatus: GLint = GLint(0)
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GLenum(GL_FALSE) {
            var infoLog = [GLchar](repeating: 0, count: 512)
            glGetProgramInfoLog(program, 512, nil, &infoLog)
            fatalError(String(cString:infoLog))
        }
        glDeleteShader(vShader)
        glDeleteShader(fShader)
        return program
    }
}
