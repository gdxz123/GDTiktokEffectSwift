precision mediump float;
uniform float time;
uniform sampler2D textureImage;
varying vec2 textureCoordVarying;

const float PI = 3.1415926;

float random(float n) {
    return fract(sin(n) * 43758.5453123);
}

void main(void) {
    float maxJitter = 0.06;
    float duration = 0.3;
    float colorROffset = 0.01;
    float colorBOffset = -0.025;

    float temTime = mod(time, duration * 2.0);
    float amplitude = max(sin(temTime * (PI / duration)), 0.0);

    float jitter = random(textureCoordVarying.y) * 2.0 - 1.0; // -1~1
    bool needOffset = abs(jitter) < maxJitter * amplitude;

    float textureX = textureCoordVarying.x + (needOffset ? jitter : (jitter * amplitude * 0.006));
    vec2 textureCoords = vec2(textureX, textureCoordVarying.y);

    vec4 mask = texture2D(textureImage, textureCoords);
    vec4 maskR = texture2D(textureImage, textureCoords + vec2(colorROffset * amplitude, 0.0));
    vec4 maskB = texture2D(textureImage, textureCoords + vec2(colorBOffset * amplitude, 0.0));
   
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
    
//    gl_FragColor = texture2D(textureImage, textureCoordVarying);
}
