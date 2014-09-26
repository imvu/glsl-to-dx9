// --------------------
//       defines
// --------------------

#ifndef GL_ES
#define lowp
    // !!! GLSL versions < 1.3 (such as on IMVU USSR) don't support the lowp qualifier
#endif

// --------------------
//       uniforms
// --------------------

uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uProjMatrix;
uniform mat4 uInvViewMatrix;
uniform mat4 uNormalMatrix;
uniform mat3 uTextureMatrix;
uniform float uEnableVertexColors;

// --------------------
//      attributes
// --------------------

attribute vec4 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexCoord;
attribute vec4 vColor;
attribute lowp vec4 vBoneWeights;
attribute lowp vec4 vBoneIndices;

// --------------------
//       varyings
// --------------------

varying vec2 fTexCoord;
varying vec3 fAmbient;
varying vec3 fEye;
varying vec3 fWorldPos;
varying vec3 fNormal;
varying vec4 fColor;

// --------------------
//   type definitions
// --------------------

struct ShaderState {
    vec3 ambient;
    vec3 eye;
    vec2 texCoord;
    vec3 worldPosition;
    vec3 normal;
    vec4 tangent;
    vec4 color;
    vec4 positionModel;
    vec4 positionWorld;
    vec4 positionView;
    vec4 positionProj;
    vec3 normalModel;
    vec3 normalWorld;
    vec4 tangentModel;
    vec4 tangentWorld;
// @@@ RESOLVE THESE
    vec3 scale;
    float rotation;
};
// TODO: @@@ until custom modules are revised
#define VertexState ShaderState
#define FragmentState ShaderState

// --------------------
//   state functions
// --------------------

void initStatePosition(inout ShaderState s) {
    s.positionProj = s.positionView = s.positionWorld = s.positionModel = vPosition;
}
void finishStatePosition(inout ShaderState s) {
    s.worldPosition = s.positionWorld.xyz;
    gl_Position = s.positionProj;
}
void initStateNormal(inout ShaderState s) {
    // scaled/biased bytes are mapped to [0,254] instead of [0,255],
    // so that there will be a middle value exactly corresponding to zero
    // $$$ in case the shader compiler is too dumb to make a constant out of this
    //float factor = (2.0 * (255.0/254.0));
    float factor = 2.00787401574804;
    vec3 n = (vNormal * factor) - vec3(1.0);
    s.normalModel = s.normalWorld = n;
}
void finishStateNormal(inout ShaderState s) {
    s.normal = s.normalWorld;
}
void initStateTexture(inout ShaderState s) {
    s.texCoord = vTexCoord.xy;
}
void finishStateTexture(inout ShaderState s) {
    fTexCoord = s.texCoord;
}
void initStateColor(inout ShaderState s) {
    s.color = vec4(1);
}
void finishStateEye(inout ShaderState s) {
    s.eye = uInvViewMatrix[3].xyz - s.positionWorld.xyz;
}

// --------------------
//       modules
// --------------------

// This is not 7 lights but a collection of all 'low priority' lights,
// composed onto six basis vectors (with ambient light in the 7th).
uniform vec4 uCollectedLights[7];

void AmbientCube(inout ShaderState s) {
    vec3 posN = clamp(s.normalWorld, 0.0, 1.0);
    vec3 negN = clamp(-s.normalWorld, 0.0, 1.0);
    s.ambient = (
          posN.x * uCollectedLights[0].xyz
        + posN.y * uCollectedLights[1].xyz
        + posN.z * uCollectedLights[2].xyz
        + negN.x * uCollectedLights[3].xyz
        + negN.y * uCollectedLights[4].xyz
        + negN.z * uCollectedLights[5].xyz
        + uCollectedLights[6].xyz
    );
}
#define MAX_USED_BONES 68
#define MAX_BONE_INDEX 67.0

uniform vec4 uBones[3 * MAX_USED_BONES]; // passed as 3x4 matrices, row-major, to save constant registers

void SkeletonPoseWeighted3(inout ShaderState s) {
    lowp vec3 boneIndices = vBoneIndices.xyz;
    ivec3 i = ivec3(vBoneIndices) * 3;
    vec4 row0 = uBones[i.x]   * vBoneWeights.x
              + uBones[i.y]   * vBoneWeights.y
              + uBones[i.z]   * vBoneWeights.z;
    vec4 row1 = uBones[i.x+1] * vBoneWeights.x
              + uBones[i.y+1] * vBoneWeights.y
              + uBones[i.z+1] * vBoneWeights.z;
    vec4 row2 = uBones[i.x+2] * vBoneWeights.x
              + uBones[i.y+2] * vBoneWeights.y
              + uBones[i.z+2] * vBoneWeights.z;
    s.normalModel = vec3(
        dot(row0.xyz, s.normalModel),
        dot(row1.xyz, s.normalModel),
        dot(row2.xyz, s.normalModel));
    s.positionModel.xyz = vec3(
        dot(row0, s.positionModel),
        dot(row1, s.positionModel),
        dot(row2, s.positionModel));
}
void Transform(inout ShaderState s) {
    s.normalModel = normalize(s.normalModel);
    s.normalWorld = normalize(uNormalMatrix * vec4(s.normalModel,0.0)).xyz;
    s.positionWorld = uModelMatrix * s.positionModel;
    s.positionView = uViewMatrix * s.positionWorld;
    s.positionProj = uProjMatrix * s.positionView;
}
uniform float uFogMultiplier;
uniform vec4 uFogParams;
#define fogNear uFogParams.x
#define fogFar uFogParams.y
#define fogDensity uFogParams.z
#define fogInvRange 1.0/(fogFar-fogNear)

varying float fFogIntensity;

void LinearFogIntensity(inout VertexState s) {
    float fogCoord = -s.positionView.z;
    fFogIntensity = clamp(fogDensity * uFogMultiplier * (fogCoord-fogNear) * fogInvRange, 0.0, 1.0);
}

// ====================
//       M A I N
// ====================

void main() {
    //
    // state initialization
    //
    ShaderState ss;
    initStatePosition(ss);
    initStateNormal(ss);
    initStateTexture(ss);
    initStateColor(ss);
    //
    // call pre-transform, transform, and post-transform modules
    //
    AmbientCube(ss);
    SkeletonPoseWeighted3(ss);
    Transform(ss);
    LinearFogIntensity(ss);
    //
    // finish state
    //
    finishStatePosition(ss);
    finishStateNormal(ss);
    finishStateTexture(ss);
    finishStateEye(ss);
    //
    // prepare fragment lighting
    //
    fAmbient.rgb = ss.ambient;
    fEye = ss.eye;
    fWorldPos = ss.worldPosition;
    fNormal = ss.normal;
    fColor = ss.color;
}
