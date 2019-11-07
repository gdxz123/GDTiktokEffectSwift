precision mediump float;
uniform float time;
uniform sampler2D textureImage;
varying vec2 textureCoordVarying;

const float PI = 3.1415926;
const float scaleDuration = 0.5;

void main(void) {
    float scaleProcess = mod(time, scaleDuration);
    float scale = 1.0 + 0.1 * abs(sin(scaleProcess / scaleDuration * PI));
    vec2 scaleTextureCoord = vec2(textureCoordVarying.x * scale, textureCoordVarying.y * scale);
    float alpha = 0.5 * (1.0 - scaleProcess);
    
    float flowX = 0.5 + (textureCoordVarying.x - 0.5) / scale;
    float flowY = 0.5 + (textureCoordVarying.y - 0.5) / scale;
    vec2 maskTextureCoord = vec2(flowX, flowY);
    
    vec4 originColor = texture2D(textureImage, scaleTextureCoord);
    
    vec4 maskColor = texture2D(textureImage, maskTextureCoord);
    
    gl_FragColor = originColor * (1.0 - alpha) + maskColor * alpha;
    
//    gl_FragColor = texture2D(textureImage, scaleTextureCoord);
}
