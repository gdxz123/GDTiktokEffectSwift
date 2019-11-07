attribute vec3 position;
attribute vec2 textureCoord;
varying vec2 textureCoordVarying;

void main(void) {
    gl_Position = vec4(position.x, position.y, position.z, 1.0);
    textureCoordVarying = textureCoord;
}
