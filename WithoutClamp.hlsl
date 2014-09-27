struct _ShaderState
{
	float3 _ambient;
	float3 _eye;
	float2 _texCoord;
	float3 _worldPosition;
	float3 _normal;
	float4 _tangent;
	float4 _color;
	float4 _positionModel;
	float4 _positionWorld;
	float4 _positionView;
	float4 _positionProj;
	float3 _normalModel;
	float3 _normalWorld;
	float4 _tangentModel;
	float4 _tangentWorld;
	float3 _scale;
	float _rotation;
};
struct _ShaderState_0
{
	float3 _ambient;
	float3 _eye;
	float2 _texCoord;
	float3 _worldPosition;
	float3 _normal;
	float4 _tangent;
	float4 _color;
	float4 _positionModel;
	float4 _positionWorld;
	float4 _positionView;
	float4 _positionProj;
	float3 _normalModel;
	float3 _normalWorld;
	float4 _tangentModel;
	float4 _tangentWorld;
	float3 _scale;
	float _rotation;
};
_ShaderState _ShaderState_ctor(float3 x0, float3 x1, float2 x2, float3 x3, float3 x4, float4 x5, float4 x6, float4 x7, float4 x8, float4 x9, float4 x10, float3 x11, float3 x12, float4 x13, float4 x14, float3 x15, float x16)
{
	_ShaderState structure = { x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16 };
	return structure;
}
_ShaderState_0 _ShaderState_0_ctor(float3 x0, float3 x1, float2 x2, float3 x3, float3 x4, float4 x5, float4 x6, float4 x7, float4 x8, float4 x9, float4 x10, float3 x11, float3 x12, float4 x13, float4 x14, float3 x15, float x16)
{
	_ShaderState_0 structure = { x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16 };
	return structure;
}
float3 vec3(float x0, float x1, float x2)
{
	return float3(x0, x1, x2);
}
float4 vec4(float3 x0, float x1)
{
	return float4(x0, x1);
}
int3 ivec3(int4 x0)
{
	return int3(x0.xyz);
}
// Attributes
static float4 _vBoneIndices = { 0, 0, 0, 0 };
static float4 _vBoneWeights = { 0, 0, 0, 0 };
static float3 _vNormal = { 0, 0, 0 };
static float4 _vPosition = { 0, 0, 0, 0 };
static float2 _vTexCoord = { 0, 0 };

static float4 gl_Position = float4(0, 0, 0, 0);

// Varyings
static float3 _fAmbient = { 0, 0, 0 };
static float4 _fColor = { 0, 0, 0, 0 };
static float3 _fEye = { 0, 0, 0 };
static float _fFogIntensity = { 0 };
static float3 _fNormal = { 0, 0, 0 };
static float2 _fTexCoord = { 0, 0 };
static float3 _fWorldPos = { 0, 0, 0 };

uniform float4 dx_ViewAdjust : register(c1);

uniform float4 _uBones[204] : register(c2);
uniform float4 _uCollectedLights[7] : register(c206);
uniform float _uFogMultiplier : register(c213);
uniform float4 _uFogParams : register(c214);
uniform float4x4 _uInvViewMatrix : register(c215);
uniform float4x4 _uModelMatrix : register(c219);
uniform float4x4 _uNormalMatrix : register(c223);
uniform float4x4 _uProjMatrix : register(c227);
uniform float4x4 _uViewMatrix : register(c231);

;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
void _initStatePosition(inout _ShaderState _s)
{
	{
		(_s._positionProj = (_s._positionView = (_s._positionWorld = (_s._positionModel = _vPosition))));
	}
}
;
void _finishStatePosition(inout _ShaderState _s)
{
	{
		(_s._worldPosition = _s._positionWorld.xyz);
		(gl_Position = _s._positionProj);
	}
}
;
void _initStateNormal(inout _ShaderState _s)
{
	{
		float _factor = 2.007874;
		float3 _n = ((_vNormal * _factor) - float3(1.0, 1.0, 1.0));
			(_s._normalModel = (_s._normalWorld = _n));
	}
}
;
void _finishStateNormal(inout _ShaderState _s)
{
	{
		(_s._normal = _s._normalWorld);
	}
}
;
void _initStateTexture(inout _ShaderState _s)
{
	{
		(_s._texCoord = _vTexCoord.xy);
	}
}
;
void _finishStateTexture(inout _ShaderState _s)
{
	{
		(_fTexCoord = _s._texCoord);
	}
}
;
void _initStateColor(inout _ShaderState _s)
{
	{
		(_s._color = float4(1.0, 1.0, 1.0, 1.0));
	}
}
;
void _finishStateEye(inout _ShaderState _s)
{
	{
		(_s._eye = (_uInvViewMatrix[3].xyz - _s._positionWorld.xyz));
	}
}
;
;
void _AmbientCube(inout _ShaderState _s)
{
	{
		float3 _posN = clamp(_s._normalWorld, 0.0, 1.0);
			float3 _negN = clamp((-_s._normalWorld), 0.0, 1.0);
			(_s._ambient = (((((((_posN.x * _uCollectedLights[0].xyz) + (_posN.y * _uCollectedLights[1].xyz)) + (_posN.z * _uCollectedLights[2].xyz)) + (_negN.x * _uCollectedLights[3].xyz)) + (_negN.y * _uCollectedLights[4].xyz)) + (_negN.z * _uCollectedLights[5].xyz)) + _uCollectedLights[6].xyz));
	}
}
;
;
void _SkeletonPoseWeighted3(inout _ShaderState _s)
{
	{
		float3 _boneIndices = _vBoneIndices.xyz;
			int3 _i = (ivec3(int4(_vBoneIndices)) * 3);
			float4 _row0 = (((_uBones[int(clamp(float(_i.x), 0.0, 203.0))] * _vBoneWeights.x) + (_uBones[int(clamp(float(_i.y), 0.0, 203.0))] * _vBoneWeights.y)) + (_uBones[int(clamp(float(_i.z), 0.0, 203.0))] * _vBoneWeights.z));
			float4 _row1 = (((_uBones[int(clamp(float((_i.x + 1)), 0.0, 203.0))] * _vBoneWeights.x) + (_uBones[int(clamp(float((_i.y + 1)), 0.0, 203.0))] * _vBoneWeights.y)) + (_uBones[int(clamp(float((_i.z + 1)), 0.0, 203.0))] * _vBoneWeights.z));
			float4 _row2 = (((_uBones[int(clamp(float((_i.x + 2)), 0.0, 203.0))] * _vBoneWeights.x) + (_uBones[int(clamp(float((_i.y + 2)), 0.0, 203.0))] * _vBoneWeights.y)) + (_uBones[int(clamp(float((_i.z + 2)), 0.0, 203.0))] * _vBoneWeights.z));
			(_s._normalModel = vec3(dot(_row0.xyz, _s._normalModel), dot(_row1.xyz, _s._normalModel), dot(_row2.xyz, _s._normalModel)));
		(_s._positionModel.xyz = vec3(dot(_row0, _s._positionModel), dot(_row1, _s._positionModel), dot(_row2, _s._positionModel)));
	}
}
;
void _Transform(inout _ShaderState _s)
{
	{
		(_s._normalModel = normalize(_s._normalModel));
		(_s._normalWorld = normalize(mul(transpose(_uNormalMatrix), vec4(_s._normalModel, 0.0))).xyz);
		(_s._positionWorld = mul(transpose(_uModelMatrix), _s._positionModel));
		(_s._positionView = mul(transpose(_uViewMatrix), _s._positionWorld));
		(_s._positionProj = mul(transpose(_uProjMatrix), _s._positionView));
	}
}
;
;
;
;
void _LinearFogIntensity(inout _ShaderState _s)
{
	{
		float _fogCoord = (-_s._positionView.z);
		(_fFogIntensity = clamp(((((_uFogParams.z * _uFogMultiplier) * (_fogCoord - _uFogParams.x)) * 1.0) / (_uFogParams.y - _uFogParams.x)), 0.0, 1.0));
	}
}
;
void gl_main()
{
	{
		_ShaderState_0 _ss = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
		_initStatePosition(_ss);
		_initStateNormal(_ss);
		_initStateTexture(_ss);
		_initStateColor(_ss);
		_AmbientCube(_ss);
		_SkeletonPoseWeighted3(_ss);
		_Transform(_ss);
		_LinearFogIntensity(_ss);
		_finishStatePosition(_ss);
		_finishStateNormal(_ss);
		_finishStateTexture(_ss);
		_finishStateEye(_ss);
		(_fAmbient.xyz = _ss._ambient);
		(_fEye = _ss._eye);
		(_fWorldPos = _ss._worldPosition);
		(_fNormal = _ss._normal);
		(_fColor = _ss._color);
	}
}
;
struct VS_INPUT
{
	float4 _vBoneIndices : TEXCOORD0;
	float4 _vBoneWeights : TEXCOORD1;
	float3 _vNormal : TEXCOORD2;
	float4 _vPosition : TEXCOORD3;
	float2 _vTexCoord : TEXCOORD4;
};

struct VS_OUTPUT
{
	float4 gl_Position : POSITION;
	float4 v0 : TEXCOORD0;
	float3 v1 : TEXCOORD1;
	float3 v2 : TEXCOORD2;
	float3 v3 : TEXCOORD3;
	float3 v4 : TEXCOORD4;
	float2 v5 : TEXCOORD5;
	float1 v6 : TEXCOORD6;
};

VS_OUTPUT main(VS_INPUT input)
{
	_vBoneIndices = (input._vBoneIndices);
	_vBoneWeights = (input._vBoneWeights);
	_vNormal = (input._vNormal);
	_vPosition = (input._vPosition);
	_vTexCoord = (input._vTexCoord);

	gl_main();

	VS_OUTPUT output;
	output.gl_Position.x = gl_Position.x * dx_ViewAdjust.z + dx_ViewAdjust.x * gl_Position.w;
	output.gl_Position.y = -(gl_Position.y * dx_ViewAdjust.w + dx_ViewAdjust.y * gl_Position.w);
	output.gl_Position.z = (gl_Position.z + gl_Position.w) * 0.5;
	output.gl_Position.w = gl_Position.w;
	output.v1 = _fAmbient;
	output.v0 = _fColor;
	output.v2 = _fEye;
	output.v6 = _fFogIntensity;
	output.v3 = _fNormal;
	output.v5 = _fTexCoord;
	output.v4 = _fWorldPos;

	return output;
}
