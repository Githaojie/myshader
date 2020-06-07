// create by JiepengTan 
// https://github.com/JiepengTan/FishManShaderTutorial
// 2018-04-13  email: jiepengtan@gmail.com
Shader "FishManShaderTutorial/GameHPUI" {
    Properties{
	_Fill("Fill rate", Range(0, 1)) = 1

		[Space(10)]

		_SurfaceColor("Surface color", Color) = (1, 1, 1, 1)
		_Color("Accent color", Color) = (1, 1, 1, 1)
		_BaseColor("Base color", Color) = (1, 1, 1, 1)
		
				test_Color ("test_Color", color) = (1.0,0.3,0.0,1.)


		[Space(10)]

		_P1Mul("Particles 1 multiplier", Range(0, 1)) = 0.35
		_P2Mul("Particles 2 multiplier", Range(0, 1)) = 0.75

		[Space(10)]

		_Smoke1Tiling("Smoke 1 tiling", Float) = 0.8
		_Smoke2Tiling("Smoke 2 tiling", Float) = 0.75
		_Particles1Tiling("Particles 1 tiling", Float) = 1.0
		_Particles2Tiling("Particles 2 tiling", Float) = 0.5

		[Space(10)]

		[NoScaleOffset]_SurfaceTexture("Surface texture (Add)", 2D) = "black" {}

		[NoScaleOffset]_uva("UV+A map", 2D) = "black" {}
		[NoScaleOffset]_Smoke("Smoke", 2D) = "black" {}
		[NoScaleOffset]_Particles("Particles", 2D) = "black" {}
		[NoScaleOffset]_SAlphaTex("Surface alpha map", 2D) = "white" {}
		[NoScaleOffset]_Gradient("Gradient (Add)", 2D) = "black" {}
		[NoScaleOffset]_Overlay("Overlay (Add)", 2D) = "black" {}
		[NoScaleOffset]_Shadow("Shadow (Normal)", 2D) = "white" {}

		[HideInInspector]_SurfaceOffsetX("Surface Offset X", Float) = 0
		[HideInInspector]_Smoke1OffsetX("Smoke 1 Offset X", Float) = 0
		[HideInInspector]_Smoke1OffsetY("Smoke 1 Offset Y", Float) = 0
		[HideInInspector]_Smoke2OffsetX("Smoke 2 Offset X", Float) = 0
		[HideInInspector]_Smoke2OffsetY("Smoke 2 Offset Y", Float) = 0
		[HideInInspector]_Particles1OffsetX("Particles 1 Offset X", Float) = 0
		[HideInInspector]_Particles1OffsetY("Particles 1 Offset Y", Float) = 0
		[HideInInspector]_Particles2OffsetX("Particles 2 Offset X", Float) = 0
		[HideInInspector]_Particles2OffsetY("Particles 2 Offset Y", Float) = 0

    }  
    SubShader
    {
      Tags{ "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
		ZWrite on
		Blend One OneMinusSrcAlpha
		Cull Off
		Lighting Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "ShaderLibs/Math.cginc"
			 
			#define  SIZE  0.5
			#define WATER_DEEP 0.6
			
sampler2D _uva;

			sampler2D _Smoke;
			sampler2D _Particles;

			sampler2D _Gradient;
			sampler2D _Overlay;
			sampler2D _Shadow;

			sampler2D _SAlphaTex;
			sampler2D _SurfaceTexture;

			float _Fill;
			float _P1Mul;
			float _P2Mul;

			float _Smoke1Tiling;
			float _Smoke2Tiling;
			float _Particles1Tiling;
			float _Particles2Tiling;

			float _SurfaceOffsetX;
			float _Smoke1OffsetX;
			float _Smoke1OffsetY;
			float _Smoke2OffsetX;
			float _Smoke2OffsetY;
			float _Particles1OffsetX;
			float _Particles1OffsetY;
			float _Particles2OffsetX;
			float _Particles2OffsetY;

			fixed4 _SurfaceColor;
			fixed4 _Color;
			fixed4 _BaseColor;
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
			
			float Rand(float x)
			{
				return frac(sin(x*866353.13)*613.73);
			}

			float2x2 Rotate2D(float deg){
				deg = deg * Deg2Radius;
				return float2x2(cos(deg),sin(deg),-sin(deg),cos(deg));
			}
			float2 Within(float2 uv, float4 rect) {
				return (uv-rect.xy)/(rect.zw-rect.xy);
			}
			float Circle(float2 uv,float2 center,float size,float blur){
				uv = uv - center;
				uv /= size;
				float len = length(uv);
				return smoothstep(1.,1.-blur,len);
			}

			float PureCircle(float2 uv,float2 center,float size,float blur,float powVal){
				uv = uv - center;
				uv /= size;
				float len = 1.-length(uv);
				float val = clamp(Remap(0.,blur,0.,1.,len),0.,1.);
				return pow(val,powVal);//* pow(1.+len * 3.,0.1);
			}
			float Ellipse(float2 uv,float2 center,float2 size,float blur){
				uv = uv - center;
				uv /= size;
				float len = length(uv);
				return smoothstep(1.,1.-blur,len);
			}


			float3 Draw3DFrame(float2 uv){
				//cameraPos  
				float3 camPos = float3(0.,0.,-3);
				//Torus 
				float3 frameCol = float3(0.9,0.75,0.6);
				float frameMask = Circle(uv,float2(0.,0.),SIZE*1.1,0.01) - 
					Circle(uv,float2(0.,0.),SIZE,0.01);
				return float3(0.,0.,0.);
    
			}
			float Torus2D(float2 uv,float2 center,float2 size,float blur){
				uv = uv - center;
				float len = length(uv);
				if(len<size.y || len >size.x)
					return 0.;
				float radio = (len-size.y)/(size.x-size.y);
				float val = 1.-abs((radio-0.5)*2.);
				return pow(val,blur);
			}

			float3 DrawFrame(float2 uv){
				float3 frameCol = float3(0.9,0.75,0.6);
				float frameMask = Circle(uv,float2(0.,0.),SIZE*1.1,0.01) - 
					Circle(uv,float2(0.,0.),SIZE,0.01);
				//return frameCol * frameMask;
				return float4(Torus2D(uv,float2(0.,0.),float2(SIZE * 1.1,SIZE),0.2) *frameCol, 1);
			}
			float3 DrawHightLight(float2 uv){
				//up
				float3 hlCol = float3(0.95,0.95,0.95);
				float upMask = Ellipse(uv,float2(0.,0.8)*SIZE,float2(0.9,0.7)*SIZE,0.6)*0.9;
				upMask = upMask * Circle(uv,float2(0.,0.)*SIZE,SIZE*0.95,0.02) ;
				upMask = upMask * Circle(uv,float2(0.,-0.9)*SIZE,SIZE*1.1,-0.8) ;
				//bottom
				uv =mul(Rotate2D(30.),uv) ;
				float btMask =1.;
				btMask *=  Circle(uv,float2(0.,0.)*SIZE,SIZE*0.95,0.02);
				float scale = 0.9;
				btMask *= 1.- Circle(uv,float2(0.,-0.17+scale)*SIZE,SIZE*(1.+scale),0.2) ;
				return  (upMask + btMask) * hlCol;
    
			}


			float GetWaveHeight(float2 uv){
				uv =mul(Rotate2D(-30.),uv) ;
				float wave =  0.12*sin(-2.*uv.x+_Time.y*4.); 
				uv =mul(Rotate2D(-50.),uv) ;
				wave +=  0.05*sin(-2.*uv.x+_Time.y*4.); 
				return wave;
			}

			float RayMarchWater(float3 camera, float3 dir,float startT,float maxT){
				float3 pos = camera + dir * startT;
				float t = startT;
				for(int i=0;i<150;i++){
					if(t > maxT){
        				return -1.;
					}
					float h = GetWaveHeight(pos.xz) * WATER_DEEP;
					if(h + 0.01 > pos.y ) {//+ 0.01 acc intersect speed
						// get the intersect point
						return t;
					}
					t += pos.y - h; 
					pos = camera + dir * t;
				}
				return -1.0;
			}

			float4 SimpleWave3D(float2 uv,float3 col){
				float3 camPos =float3(0.23,0.13,-2.28);
				float3 targetPos = float3(0.,0.,0.);
    
				float3 f = normalize(targetPos-camPos);
				float3 r = cross(normalize(float3(0.01, 1., 0.)), f);
				float3 u = cross(f, r);
    
				float3 ray = normalize(uv.x*r+uv.y*u+1.0*f);
    
				float startT = 0.1;
				float maxT = 20.;
				float dist = RayMarchWater(camPos, ray,startT,maxT);
				float3 pos = camPos + ray * dist;
				//only need a small circle
				float circleSize = 2.;
				if(dist < 0.){
    				return float4(0.,0.,0.,0.);
				}
				float2 offsetPos = pos.xz;
				if(length(offsetPos)>circleSize){
    				return float4(0.,0.,0.,0.);
				}
				float colVal = 1.-((pos.z+0.)/circleSize +1.0) *.5;//0~1
				return float4(col*smoothstep(0.,1.4,colVal),1.);
			}
			float SmoothCircle(float2 uv,float2 offset,float size){
				uv -= offset;
				uv/=size;
				float temp = clamp(1.-length(uv),0.,1.);
				return smoothstep(0.,1.,temp);
			}
			float DrawBubble(float2 uv,float2 offset,float size){
				uv = (uv - offset)/size;
				float val = 0.;
				val = length(uv);
				val = smoothstep(0.5,2.,val)*step(val,1.);
    
				val +=SmoothCircle(uv,float2(-0.2,0.3),0.6)*0.4;
				val +=SmoothCircle(uv,float2(0.4,-0.5),0.2)*0.2;
				return val; 
			}
			float DrawBubbles(float2 uv){
				uv = Within(uv, float4(-SIZE,-SIZE,SIZE,SIZE));
				uv.x-=0.5;
				float val = 0.;
				const float count = 2.;// bubble num per second
				const float maxVY = 0.1;
				const float ay = -.3;
				const  float ax = -.5;
				const  float maxDeg = 80.;
				const float loopT = maxVY/ay + (1.- 0.5*maxVY*maxVY/ay)/maxVY;
				const  float num = loopT*count;
				for(float i=1.;i<num;i++){
    				float size = 0.02*Rand(i*451.31)+0.02;
					float t = fmod(_Time.y + Rand(i)*loopT,loopT);
					float deg = (Rand(i*1354.54)*maxDeg +(90.-maxDeg*0.5))*Deg2Radius;
					float2 vel = float2(cos(deg),sin(deg));
					float ty = max((vel.y*0.3 - maxVY),0.)/ay;
					float yt = clamp(t,0.,ty);
					float y = max(0.,abs(vel.y)*yt + 0.5*ay*yt*yt) + max(0.,t-ty)*maxVY;// 加点加速度
        
					float tx = abs(vel.x/ax);
					t = min(tx,t);
					float xOffset = abs(vel.x)*t+0.5*ax*t*t + sin(_Time.y*(0.5+Rand(i)*2.)+Rand(i)*2.*PI)*0.03;
					float x = sign(vel.x)*xOffset;
					float2 offset = float2(x,y);
    				val += DrawBubble(uv,offset,size*0.5);
				}
				return val;
			}


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
		
            float4 frag (v2f i) : SV_Target
            {

float4 uva = tex2D(_uva, i.uv);

				fixed4 col = fixed4(0, 0, 0, 0);
				fixed sAlpha = tex2D(_SAlphaTex, float2(_Fill, 0)).r;

				float fillSign = sign(_Fill - 0.001 - i.uv.y);

				// fill color
				fixed4 fillCol = _BaseColor;

				fillCol.rgb += tex2D(_Smoke, uva.rg * _Smoke1Tiling + float2(_Smoke1OffsetX, _Smoke1OffsetY)).rgb;
				fillCol.rgb -= 0.75 * tex2D(_Smoke, uva.rg * _Smoke2Tiling + float2(_Smoke2OffsetX, _Smoke2OffsetY)).rgb;

				fillCol.rgb += tex2D(_Gradient, i.uv).rgb;

				fillCol.rgb *= _Color.rgb;

				fixed4 particleCol = tex2D(_Particles, uva.rg * _Particles1Tiling + float2(_Particles1OffsetX, _Particles1OffsetY));
				particleCol *= particleCol.a;
				fillCol.rgb += _P1Mul * particleCol.rgb;

				particleCol = tex2D(_Particles, uva.rg * _Particles2Tiling + float2(_Particles2OffsetX, _Particles2OffsetY));
				particleCol *= particleCol.a;
				fillCol.rgb += _P2Mul * particleCol.rgb;

				fixed4 surfaceCol = sAlpha * 0.9 * tex2D(_SurfaceTexture, float2(i.uv.x + _SurfaceOffsetX, i.uv.y - _Fill - 0.005f));
				surfaceCol *= surfaceCol.a;
				fillCol.rgb += surfaceCol.rgb;


				// surface color
				fixed4 surfaceCol1 = sAlpha * _SurfaceColor * tex2D(_SurfaceTexture, float2(i.uv.x + 0.5 + _SurfaceOffsetX, -i.uv.y + _Fill - 0.005f));
				surfaceCol1.rgb *= surfaceCol1.a;
				fixed4 surfaceCol2 = sAlpha * _SurfaceColor * tex2D(_SurfaceTexture, float2(-i.uv.x + 0.2 + _SurfaceOffsetX, -i.uv.y + _Fill - 0.005f));
				surfaceCol2 *= surfaceCol2.a;
				surfaceCol = surfaceCol1 + surfaceCol2;


				col += max(0, fillSign) * fillCol;
				col += max(0, -fillSign) * surfaceCol;

				fixed4 overlayCol = tex2D(_Overlay, i.uv);
				overlayCol.rgb *= overlayCol.a;
				col += overlayCol;

				fixed4 shadowCol = tex2D(_Shadow, i.uv);
				col.rgb = shadowCol.rgb + (1 - shadowCol.a) * col.rgb;
				col.a = shadowCol.a + (1 - shadowCol.a) * col.a;



				float hpPer = (_Fill - 0.26) * 1.94;
				
				float3 waterCol = 0.5+0.5*cos(2.*PI*(float3(1.,1.,1.)*_Time.y*0.2+float3(0.,0.33,0.67)));
    
				float2 uv = (i.uv/1 - 0.5)  / 1 * 2;
				//float4 col = float4(0.,0.,0, 1);//final color 
				

				//draw 3D frame
				//col.rgb += DrawFrame(uv);
    
				//draw base water
				float hpPerMask = step(0 ,(hpPer *2. -1)*SIZE - uv.y);
  				float bgMask = 0.;
				bgMask += PureCircle(uv,float2(0.,0.),SIZE*2,1,1);
 				bgMask += Circle(uv,float2(0.,0.),SIZE*2,1)*0.2;
				col.xyz += bgMask * waterCol *hpPerMask ;


				//draw wave
				float waterMask = step(length(uv),SIZE * 2);
				float offset = hpPer -0.5+0.03;
				float wavePicSize = 1*SIZE + 0.06;
				float2 remapUV = Within(uv,float4(0.,offset ,wavePicSize + 0.5,offset+wavePicSize - 0.3));
				float4 wave = SimpleWave3D(remapUV,waterCol);
				col.xyz = lerp(col,wave.xyz*bgMask,wave.w*waterMask);

				//draw bubbles
				float bubbleMask = smoothstep(0.,0.1,(hpPer *2. -1.2)*SIZE - uv.y);
				col.xyz+= DrawBubbles(uv)*float3(1.,1.,1.)* bubbleMask*waterMask;
				//draw hight light
				//col.xyz += DrawHightLight(uv*1.);
                col *= uva.a;
                return col; 
            }			
            ENDCG
        }
    }
    FallBack Off
}
