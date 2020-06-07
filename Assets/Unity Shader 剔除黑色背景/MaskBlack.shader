Shader "Custom/MaskBlack" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskValue("Mask Value(0-1)",Range(0,1)) = 0.1
	}
	SubShader {
		Tags { "RenderType"="Transparent" }
		LOD 200
		CGPROGRAM
		#pragma surface surf Lambert alpha
		sampler2D _MainTex;
		float _MaskValue;
		struct Input {
			float2 uv_MainTex;
		};
		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
		        if(c.r+c.g+c.b<_MaskValue){
			     c.a=0;
		        }
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}