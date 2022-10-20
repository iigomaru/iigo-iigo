Shader "iigo/iigo/EARS"
{
    Properties
    {
        //------------------------------------------------------------------------------------------------------------------------------
        // Properties for material

        [Header(### Outline)]

        [Header(Outline Color)]
        _OutlineColor ("Outline Color", Color) = (0,0,0,0)

        [Header(Outline Size)]
        _LineSizeNear ("Line Size Near", Range(0, 2)) = .1
        _LineSize ("Line Size", Range(0, 2)) = .5
        _NearLineSizeRange ("Near Line Size Range", Range(0, 4)) = .3

        [Header(Depth Map)]
        _BoundingExtents ("Depth Bounding Extents", Float) = .5
        _DepthOffset ("Depth Bounding Offset", Range(-1,1)) = 0

        [Header(Local Adaptive Depth Outline)]
        _LocalEqualizeThreshold ("Depth Local Adaptive Equalization Threshold", Range(0, .1)) = .05
        _DepthMult ("Depth Outline Multiplier", Range(0, 4)) = 1
        _DepthBias ("Depth Outline Bias", Range(.5, 1.5)) = .6
        _FarDepthMult ("Far Depth Outline Multiplier", Range(0, 4)) = .5
        
        [Header(Depth Contrast Outline)]
        _DepthContrastMult ("Depth Contrast Outline Multiplier", Range(0, 2)) = 2
        _FarDepthContrastMult ("Far Depth Contrast Outline Multiplier", Range(0, 2)) = .5

        [Header(Depth Outline Gradient)]
        _DepthGradientMin ("Depth Outline Gradient Min", Range(0, 1)) = 0.05
        _DepthGradientMax ("Depth Outline Gradient Max", Range(0, 1)) = 0.5
        _DepthEdgeSoftness ("Depth Outline Edge Softness", Range(0, 2)) = .25

        [Header(Far Depth Outline)]
        //    	[Tooltip(Distance with Depth Multiplier fades into Far Depth Multiplier)]
        _FarDepthSampleDist ("Far Depth Outline Distance", Range(0,10)) = 10

        [Header(Concave Normal Outline Sampling)]
        _NormalSampleMult ("Concave Outline Sampling Multiplier", Range(0,10)) = 3
        _NormalSampleBias ("Concave Outline Sampling Bias", Range(0,4)) = .5
        _FarNormalSampleMult ("Far Concave Outline Multiplier", Range(0,10)) = 2

        [Header(Convex Normal Outline Sampling)]
        _ConvexSampleMult ("Convex Outline Sampling Multiplier", Range(0,10)) = 1
        _ConvexSampleBias ("Convex Outline Sampling Bias", Range(0,4)) = 1
        _FarConvexSampleMult ("Far Convex Outline Multiplier", Range(0,10)) = .5

        [Header(Normal Outline Gradient)]
        _NormalGradientMin ("Normal Gradient Min", Range(0, 1)) = .1
        _NormalGradientMax ("Normal Gradient Max", Range(0, 1)) = .9
        _NormalEdgeSoftness ("Normal Edge Softness", Range(0, 2)) = .5

        [Header(Far Outline Normal)]
        //    	[Tooltip(Distance with Normal Multiplier fades into Far Normal Multiplier)]
        _FarNormalSampleDist ("Far Normal Outline Distance", Range(0,10)) = 10


        //fallback stuff

        _MainTex ("Texture", 2D) = "black" {}
        //----------------------------------------------------------------------

        
        [NoScaleOffset] _MatCap ("MatCap", 2D) = "white" {}
        [Header(RED MAT)]

        _MainTexRed ("Texture", 2D) = "white" {}

        //------------------------------------------------------------------------------------------------------------------------------
        // ForwardBase
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend   ("SrcBlend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend   ("DstBlend", Int) = 0
        [Enum(UnityEngine.Rendering.BlendOp)]   _BlendOp    ("BlendOp", Int) = 0

        //------------------------------------------------------------------------------------------------------------------------------
        //ForwardAdd
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

            sampler2D _MatCap;

            //RED
            //=====================================================
            
            sampler2D _MainTexRed;
            float4  _MainTexRed_ST;

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
	        #include "..//GTToonOutlineGrabPass.hlsl"
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
        // EARS // RED
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
                #define iigo_texture_EMISSION float(0)

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER float(0.3)
                #define iigo_matCap_TEXTURE _MatCap
                #define iigo_matCap_EMISSION float(0)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER iigo_global_RIMPOWER
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

            #define gt_outline_ENABLED
                #define gt_outline_COLOR _OutlineColor

            #include "..//GTToonOutline.hlsl"
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
                #define iigo_texture_EMISSION float(0)

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER float(0.3)
                #define iigo_matCap_TEXTURE _MatCap
                #define iigo_matCap_EMISSION float(0)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER iigo_global_RIMPOWER
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

            #define gt_outline_ENABLED
                #define gt_outline_COLOR _OutlineColor

            #include "..//GTToonOutline.hlsl"

            #include "iigo_Add.cginc"
            ENDHLSL
        }
    }

    // Enable ShadowCaster by fallback to Standard
    Fallback "Standard"
}