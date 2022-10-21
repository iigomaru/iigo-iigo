Shader "iigo/iigo/CLOTHES"
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


        [Header(RED MAT)]
        _EmissionRed ("Emission", Range(0,1)) = 0.2

        _ColorRed("Color", Color) = (0.66, 0.64, 0.66, 1)
        _BorderRed ("Border", Range(0,1)) = .44

        _MyArrRed ("Tex", 2DArray) = "" {}
        _RimPowerRed( "Rim Power", Range( 0.00, 1.00 )) = 0.2

        [Space(20)]
		[Header(GREEN MAT)]
		[Space(5)]

        _EmissionGreen ("Emission", Range(0,1)) = 0.2

        _ColorGreen ("Color", Color) = (1,1,1,1)
        _SpeedGreen ("Speed", Range(-100,100)) = 0.3
        _AlphaGreen ("Maximum Alpha", Range(0,1)) = 0.75
        _ScaleGreen ("Scale", Float) = 9

        _EmissionColorGreen ("Rimlight Color", Color) = (0.496,0.447,0.486,1)
        
        _BeefGreen ("Beef", Range(0,1)) = 0
        _PorkGreen ("Pork", Range(0,1)) = 1

        _HoodieColor1Green ("Hoodie Color 1", Color) = (0.0, 0.0, 0.0 ,1)
        _HoodieColor2Green ("Hoodie Color 2", Color) = (0.0, 0.0, 0.0 ,1)

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

        cull off

        HLSLINCLUDE
            #pragma skip_variants LIGHTMAP_ON DYNAMICLIGHTMAP_ON LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK DIRLIGHTMAP_COMBINED

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

        //RED
        //=====================================================

            // iigo properties
            float _EmissionRed;
            float4  _ColorRed;
            float _BorderRed;
            float _RimPowerRed;

            UNITY_DECLARE_TEX2DARRAY(_MyArrRed);

        //GREEN
        //=====================================================

            // iigo properties
            float _EmissionGreen;
            float4 _EmissionColorGreen;
            float _BeefGreen;
            float _PorkGreen;

            //declarations
            float4 _ColorGreen; //
            float _SpeedGreen; //
            float _AlphaGreen; //
            float _ScaleGreen; //

            float4 _HoodieColor1Green;
            float4 _HoodieColor2Green;

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
        // SHOES // RED
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

            #define iigo_base_COLOR _ColorRed

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER _BorderRed
                #define iigo_matCap_TEXTURE _MatCapRed
                #define iigo_matCap_EMISSION _EmissionRed
                #define iigo_matCap_SHOES
                    #define iigo_matCap_SHOES_COLOR1 float3(0.00, 0.92, 0.96)
                    #define iigo_matCap_SHOES_COLOR2 float3(0.87, 0.55, 0.88)
                    #define iigo_matCap_SHOES_ROTATION float(0.325) + i.iigo_audioLinkData_TIMEX

            #define iigo_glitchFlipbook_ENABLED
                #define iigo_glitchFlipbook_TEXTUREARRAY _MyArrRed
                #define iigo_glitchFlipbook_EMISSION _EmissionRed

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerRed
                #define iigo_rimlight_COLOR float4(0.44, 0.44, 0.44, 1)
                #define iigo_rimlight_IGNORELIGHT

            #define gt_outline_ENABLED
                #define gt_outline_COLOR BLACK

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

            #define iigo_base_COLOR _ColorRed

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER _BorderRed
                #define iigo_matCap_TEXTURE _MatCapRed
                #define iigo_matCap_EMISSION _EmissionRed
                #define iigo_matCap_SHOES
                    #define iigo_matCap_SHOES_COLOR1 float3(0.00, 0.92, 0.96)
                    #define iigo_matCap_SHOES_COLOR2 float3(0.87, 0.55, 0.88)
                    #define iigo_matCap_SHOES_ROTATION float(0.325) + i.iigo_audioLinkData_TIMEX

            #define iigo_glitchFlipbook_ENABLED
                #define iigo_glitchFlipbook_TEXTUREARRAY _MyArrRed
                #define iigo_glitchFlipbook_EMISSION _EmissionRed

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerRed
                #define iigo_rimlight_COLOR float4(0.44, 0.44, 0.44, 1)
                #define iigo_rimlight_IGNORELIGHT

            #define gt_outline_ENABLED
                #define gt_outline_COLOR BLACK

            #include "..//GTToonOutline.hlsl"

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        // ---------------------------------------------------------------------
        // HOODIE // GREEN
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

            #define iigo_distortedTexture_ENABLED
                #define iigo_distortedTexture_COLOR1 _HoodieColor1Green 
                #define iigo_distortedTexture_COLOR2 _HoodieColor2Green

            #define iigo_hoodie_ENABLED
                #define iigo_hoodie_SPEED    _SpeedGreen
                #define iigo_hoodie_SCALE    _ScaleGreen
                #define iigo_hoodie_PORK     _PorkGreen
                #define iigo_hoodie_BEEF     _BeefGreen
                #define iigo_hoodie_ALPHA    _AlphaGreen
                #define iigo_hoodie_COLOR    _ColorGreen
                #define iigo_hoodie_EMISSION _EmissionGreen

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER  0.2
                #define iigo_rimlight_COLOR  _EmissionColorGreen

            #define gt_outline_ENABLED
                #define gt_outline_COLOR BLACK

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

            #define IIGO_GREEN

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_distortedTexture_ENABLED
                #define iigo_distortedTexture_COLOR1 _HoodieColor1Green 
                #define iigo_distortedTexture_COLOR2 _HoodieColor2Green

            #define iigo_hoodie_ENABLED
                #define iigo_hoodie_SPEED    _SpeedGreen
                #define iigo_hoodie_SCALE    _ScaleGreen
                #define iigo_hoodie_PORK     _PorkGreen
                #define iigo_hoodie_BEEF     _BeefGreen
                #define iigo_hoodie_ALPHA    _AlphaGreen
                #define iigo_hoodie_COLOR    _ColorGreen
                #define iigo_hoodie_EMISSION _EmissionGreen

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER  0.2
                #define iigo_rimlight_COLOR  _EmissionColorGreen

            #define gt_outline_ENABLED
                #define gt_outline_COLOR BLACK

            #include "..//GTToonOutline.hlsl"

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        // ---------------------------------------------------------------------
        // PANTS // BLUE
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

                #define iigo_base_COLOR float4(0.59,0.70,0.75,1)

            #define iigo_pants_ENABLED

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER 0.2
                #define iigo_rimlight_COLOR float4(0,0,0,1)

            #define gt_outline_ENABLED
                #define gt_outline_COLOR BLACK

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

            #define IIGO_BLUE

                #define iigo_base_COLOR float4(0.59,0.70,0.75,1)

            #define iigo_pants_ENABLED

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER 0.2
                #define iigo_rimlight_COLOR float4(0,0,0,1)

            #define gt_outline_ENABLED
                #define gt_outline_COLOR BLACK

            #include "..//GTToonOutline.hlsl"

            #include "iigo_Add.cginc"
            ENDHLSL
        }
    }

    // Enable ShadowCaster by fallback to Standard
    Fallback "Standard"
}