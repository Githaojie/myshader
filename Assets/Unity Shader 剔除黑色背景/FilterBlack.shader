// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Esfog/FilterBlack" {
Properties {
_MainTex ("Base (RGB)", 2D) = "white" {}
}
SubShader 
{
Tags { "RenderType"="Opaque" }
//LOD 200
Cull Off
ZWrite Off
Blend SrcAlpha OneMinusSrcAlpha
Pass
{
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
uniform sampler2D _MainTex;
struct VertexOutput
{
float4 pos:SV_POSITION;
float4 uv:TEXCOORD0;
};
VertexOutput vert(float4 vertex:POSITION,float4 uv:TEXCOORD0)
{
VertexOutput o;
o.pos = UnityObjectToClipPos(vertex);
o.uv = uv;
return o;
}
float4 frag(VertexOutput i):COLOR
{
float4 col;
col.rgba = tex2D(_MainTex,i.uv.xy);
col.a = 1;
if(col.r + col.g + col.b == 0)
{
col.a = 0;
}
return col;
}
ENDCG
}
} 
FallBack "Diffuse"
}

