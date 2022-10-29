Shader "iigo/iigo/BODY"
{
    Properties
    {
        //------------------------------------------------------------------------------------------------------------------------------
        // Properties for material

        [Header(### Outline)]

        [Header(Outline Color)]
        _OutlineColor ("Outline Color", Color) = (0,0,0,0)
        _OutlineColorTex ("Outline Color Texture", Color) = (0,0,0,0)

        [Header(Outline Size)]
        _LineSizeNear ("Line Size Near", Range(0, 2)) = .2
        _LineSize ("Line Size", Range(0, 2)) = .8
        _NearLineSizeRange ("Near Line Size Range", Range(0, 4)) = 1

        [Header(Depth Map)]
        _BoundingExtents ("Depth Bounding Extents", Float) = .5
        _DepthOffset ("Depth Bounding Offset", Range(-.5,.5)) = 0
    	_DepthOffsetTex ("Depth Offset Texture", Color) = (0,0,0,0)
        _LocalEqualizeThreshold ("Depth Local Adaptive Equalization Threshold", Range(0.01, .1)) = .02
        [ToggleUI] _DepthSilhouetteMultiplier ("Depth Silhouette", Float) = 1

        [Header(Depth Outline Gradient)]
        _DepthGradientMin ("Depth Outline Gradient Min", Range(0, 1)) = 0
        _DepthGradientMax ("Depth Outline Gradient Max", Range(0, 1)) = 0.5
        _DepthEdgeSoftness ("Depth Outline Edge Softness", Range(0, 2)) = .25

        [Header(Concave Normal Outline Sampling)]
        _NormalSampleMult ("Concave Outline Sampling Multiplier", Range(0,10)) = 1
        _FarNormalSampleMult ("Far Concave Outline Multiplier", Range(0,10)) = 10

        [Header(Convex Normal Outline Sampling)]
        _ConvexSampleMult ("Convex Outline Sampling Multiplier", Range(0,10)) = 0
        _FarConvexSampleMult ("Far Convex Outline Multiplier", Range(0,10)) = 0

        [Header(Normal Outline Gradient)]
        _NormalGradientMin ("Normal Gradient Min", Range(0, 1)) = 0
        _NormalGradientMax ("Normal Gradient Max", Range(0, 1)) = .3
        _NormalEdgeSoftness ("Normal Edge Softness", Range(0, 2)) = .25

        [Header(Far)]
        _FarDist ("Far Distance", Range(0,10)) = 10

        //fallback stuff

        _MainTex ("Texture", 2D) = "black" {}
        //----------------------------------------------------------------------

        _CombinedMask ("Combined Mask", 2D) = "white" {}


        [Header(RED MAT)]
        _MainTexRed ("Texture", 2D) = "white" {}

        _EmissionRed ("Emission", Range(0,1)) = 0.2
        _EmissionRedColor ("Emission Color", Color) = (1,0.902,0.98,1)

        _OutlineColorRed ("Outline Color", Color) = (1,0.902,0.98,1)
        _OutlineThicknessRed ("Outline Thickness", Range(0,0.01)) = 0.002
        _OutlineEmissionRed ("Outline Emission", Range(0,1)) = 0.1

        _RimPowerRed ( "Rim Power", Range( 0.00, 1.00 )) = 0.2

        [Space(20)]
		[Header(GREEN MAT)]
		[Space(5)]

        _MainTexGreen ("Texture", 2D) = "white" {}
        _EmissionGreen ("Emission", Range(0,1)) = 0.2

        _MakeupTexGreen ("Cat Makeup", 2D) = "white" {}

        _MakeupGreen( "Makeup", Range( 0, 1 )) = 0

        [NoScaleOffset] _MatCapGreen ("MatCap", 2D) = "white" {}
        _BorderGreen ("Border", Range(0,1)) = 0.3

        _RimPowerGreen( "Rim Power", Range( 0.00, 1.00 )) = 0.2
        
        _EmissionColorGreen ("Rimlight Color", Color) = (0.2,0.18,0.196,1)

        _PanoSphereGreen ("PanoSphere", 2D) = "white" {}

        [Space(20)]
		[Header(BLUE MAT)]
		[Space(5)]

        _MainTexBlue ("Texture", 2D) = "white" {}
        _EmissionBlue ("Emission", Range(0,1)) = 0

        [NoScaleOffset] _MatCapBlue ("MatCap", 2D) = "white" {}
        _BorderBlue ("Border", Range(0,1)) = 0.3

        _RimPowerBlue( "Rim Power", Range( 0.00, 1.00 )) = 0.2
        
        _EmissionColorBlue ("Rimlight Color", Color) = (0.2,0.18,0.196,1)

        //------------------------------------------------------------------------------------------------------------------------------
        // ForwardBase
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend   ("SrcBlend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend   ("DstBlend", Int) = 0
        [Enum(UnityEngine.Rendering.BlendOp)]   _BlendOp    ("BlendOp", Int) = 0

        //------------------------------------------------------------------------------------------------------------------------------
        // ForwardAdd
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendFA ("ForwardAdd SrcBlend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendFA ("ForwardAdd DstBlend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendOp)]   _BlendOpFA  ("ForwardAdd BlendOp", Int) = 4
    }
    SubShader
    {
        Tags { "RenderType"="Geometry+10" "VRCFallback"="Unlit" "IgnoreProjector"="True"}

        HLSLINCLUDE
            #pragma skip_variants LIGHTMAP_ON DYNAMICLIGHTMAP_ON LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK DIRLIGHTMAP_COMBINED

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            

            //RED
            //=====================================================

            sampler2D _MainTexRed;
            float4  _MainTexRed_ST;

            //sampler2D _EmissionTexRed;

            float4 _EmissionRedColor;

            // iigo properties
            float _EmissionRed;

            float4 _OutlineColorRed;
            float _OutlineThicknessRed;
            float _OutlineEmissionRed;

            float _RimPowerRed;

            //GREEN
            //=====================================================

            sampler2D _MainTexGreen;
            float4  _MainTexGreen_ST;

            sampler2D _CombinedMask;

            sampler2D _MakeupTexGreen;

            //sampler2D _EmissionMaskGreen;
            sampler2D _PanoSphereGreen;

            //sampler2D _PanoSphereMaskGreen;

            // iigo properties
            float _EmissionGreen;
            float4 _EmissionColorGreen;

            sampler2D _MatCapGreen;
            float _BorderGreen;

            float _RimPowerGreen;
            //sampler2D _RimMaskGreen;

            float _MakeupGreen;

            //BLUE
            //=====================================================

            sampler2D _MainTexBlue;
            float4  _MainTexBlue_ST;

            // iigo properties
            float _EmissionBlue;
            float4 _EmissionColorBlue;

            sampler2D _MatCapBlue;
            float _BorderBlue;

            float _RimPowerBlue;

            //==================================================================
            // iigo cginc
            //==================================================================

            #ifndef IIGO_SHADERPACK
            #define IIGO_SHADERPACK
            #endif

            #include "iigo.cginc"

            
        ENDHLSL

        Pass
        {        	
	        HLSLPROGRAM
            #include "..//GTAvaToon//Shaders//GTToonOutlineGrabPass.hlsl"
	        #pragma target 5.0
            #pragma vertex grabpass_vert
            #pragma fragment grabpass_frag
            ENDHLSL
        }

        GrabPass
        {
            "_GTToonGrabTexture"
        }


        // ---------------------------------------------------------------------
        // HAIR // RED
        // ---------------------------------------------------------------------

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            BlendOp [_BlendOp], Add
            Blend [_SrcBlend] [_DstBlend], One OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #define IIGO_RED

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_texture_ENABLED
                #define iigo_texture_TEXTURE _MainTexRed
                #define iigo_texture_EMISSION _EmissionRed

            #define iigo_hairEmission_ENABLED
                #define iigo_hairEmission_EMISSION _EmissionRed
                #define iigo_hairEmission_COLOR _EmissionRedColor

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerRed
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

            #include "iigo_Base.cginc"
            ENDHLSL
        }

        // OUTLINE
        // -------
        Pass
        {
            cull front
            Tags {"LightMode" = "ForwardBase"}

            BlendOp [_BlendOp], Add
            Blend [_SrcBlend] [_DstBlend], One OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #define iigo_hairOutline_ENABLED
                #define iigo_hairOutline_THICKNESS _OutlineThicknessRed
                #define iigo_hairOutline_COLOR _OutlineColorRed
                #define iigo_hairOutline_EMISSION _OutlineEmissionRed

            #define IIGO_RED

            #define iigo_base_COLOR float4(1,1,1,1)

            #include "iigo_Base.cginc"
            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}

            BlendOp [_BlendOpFA], Add
            Blend [_SrcBlendFA] [_DstBlendFA], Zero One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog

            #define IIGO_RED

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_texture_ENABLED
                #define iigo_texture_TEXTURE _MainTexRed
                #define iigo_texture_EMISSION _EmissionRed

            #define iigo_hairEmission_ENABLED
                #define iigo_hairEmission_TEXTURE _EmissionTexRed
                #define iigo_hairEmission_EMISSION _EmissionRed
                #define iigo_hairEmission_COLOR _EmissionRedColor

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerRed
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        // OUTLINE
        // -------
        Pass
        {
            cull front
            Tags {"LightMode" = "ForwardAdd"}

            BlendOp [_BlendOpFA], Add
            Blend [_SrcBlendFA] [_DstBlendFA], Zero One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog

            #define iigo_hairOutline_ENABLED
                #define iigo_hairOutline_THICKNESS _OutlineThicknessRed

            #define iigo_hairOutline_ENABLED
                #define iigo_hairOutline_THICKNESS _OutlineThicknessRed
                #define iigo_hairOutline_COLOR _OutlineColorRed
                #define iigo_hairOutline_EMISSION _OutlineEmissionRed

            #define IIGO_RED

            #define iigo_base_COLOR float4(1,1,1,1)

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        // ---------------------------------------------------------------------
        // FACE // GREEN
        // ---------------------------------------------------------------------

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            BlendOp [_BlendOp], Add
            Blend [_SrcBlend] [_DstBlend], One OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #define IIGO_GREEN

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_texture_ENABLED
                #define iigo_texture_TEXTURE _MainTexGreen
                #define iigo_texture_EMISSION (_EmissionGreen * tex2D(_CombinedMask, i.uv).r)

            #define iigo_catMakeup_ENABLED
                #define iigo_catMakeup_TEXTURE _MakeupTexGreen
                #define iigo_catMakeup_ALPHA _MakeupGreen

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER _BorderGreen
                #define iigo_matCap_TEXTURE _MatCapGreen
                #define iigo_matCap_EMISSION (_EmissionGreen * tex2D(_CombinedMask, i.uv).r)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerGreen
                #define iigo_rimlight_COLOR _EmissionColorGreen

                #define iigo_rimlight_ALPHA (tex2D(_CombinedMask, i.uv).g)

            #define iigo_eyes_ENABLED
                #define iigo_eyes_TEXTURE _PanoSphereGreen
                #define iigo_eyes_ALPHA (tex2D(_CombinedMask, i.uv).b)

            #define gt_outline_ENABLED
                #define gt_outline_COLOR (BLACK * tex2D(_CombinedMask, i.uv).g)

            #include "..//GTAvaToon//Shaders//GTToonOutline.hlsl"

            #include "iigo_Base.cginc"
            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}

            BlendOp [_BlendOpFA], Add
            Blend [_SrcBlendFA] [_DstBlendFA], Zero One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog

            #define IIGO_GREEN

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_texture_ENABLED
                #define iigo_texture_TEXTURE _MainTexGreen
                #define iigo_texture_EMISSION (_EmissionGreen * tex2D(_CombinedMask, i.uv).r)

            #define iigo_catMakeup_ENABLED
                #define iigo_catMakeup_TEXTURE _MakeupTexGreen
                #define iigo_catMakeup_ALPHA _MakeupGreen

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER _BorderGreen
                #define iigo_matCap_TEXTURE _MatCapGreen
                #define iigo_matCap_EMISSION (_EmissionGreen * tex2D(_CombinedMask, i.uv).r)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerGreen
                #define iigo_rimlight_COLOR _EmissionColorGreen

                #define iigo_rimlight_ALPHA (tex2D(_CombinedMask, i.uv).g)

            #define iigo_eyes_ENABLED
                #define iigo_eyes_TEXTURE _PanoSphereGreen
                #define iigo_eyes_ALPHA (tex2D(_CombinedMask, i.uv).b)

            #define gt_outline_ENABLED
                #define gt_outline_COLOR (BLACK * tex2D(_CombinedMask, i.uv).g)

            #include "..//GTAvaToon//Shaders//GTToonOutline.hlsl"

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        // ---------------------------------------------------------------------
        // BODY // BLUE
        // ---------------------------------------------------------------------

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            BlendOp [_BlendOp], Add
            Blend [_SrcBlend] [_DstBlend], One OneMinusSrcAlpha

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #define IIGO_BLUE

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_texture_ENABLED
                #define iigo_texture_TEXTURE _MainTexBlue
                #define iigo_texture_EMISSION _EmissionBlue

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER _BorderBlue
                #define iigo_matCap_TEXTURE _MatCapBlue
                #define iigo_matCap_EMISSION _EmissionBlue

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerBlue
                #define iigo_rimlight_COLOR _EmissionColorBlue

            #define gt_outline_ENABLED
                #define gt_outline_COLOR BLACK

            #include "..//GTAvaToon//Shaders//GTToonOutline.hlsl"
            #include "iigo_Base.cginc"

            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}

            BlendOp [_BlendOpFA], Add
            Blend [_SrcBlendFA] [_DstBlendFA], Zero One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog

            #define IIGO_BLUE

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_texture_ENABLED
                #define iigo_texture_TEXTURE _MainTexBlue
                #define iigo_texture_EMISSION _EmissionBlue

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER _BorderBlue
                #define iigo_matCap_TEXTURE _MatCapBlue
                #define iigo_matCap_EMISSION _EmissionBlue

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerBlue
                #define iigo_rimlight_COLOR _EmissionColorBlue

            #define gt_outline_ENABLED
                #define gt_outline_COLOR BLACK

            #include "..//GTAvaToon//Shaders//GTToonOutline.hlsl"

            #include "iigo_Add.cginc"
            ENDHLSL
        }
    }

    // Enable ShadowCaster by fallback to Standard
    Fallback "Standard"
}