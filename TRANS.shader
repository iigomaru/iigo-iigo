Shader "iigo/iigo/TRANS"
{
    Properties
    {
        
        [Header(RED MAT)]
        _MainTexRed ("Texture", 2D) = "white" {}
        _EmissionRed ("Emission", Range(0,1)) = 0

        [NoScaleOffset] _MatCapRed ("MatCap", 2D) = "white" {}
        _BorderRed ("Border", Range(0,1)) = 0.3

        _RimPowerRed( "Rim Power", Range( 0.00, 1.00 )) = 0.2
        
        _EmissionColorRed ("Rimlight Color", Color) = (0.2,0.18,0.196,1)

        [Space(20)]
		[Header(GREEN MAT)]
		[Space(5)]

        // Properties for material
        _MainTexGreen ("Texture", 2D) = "white" {}
        _EmissionGreen ("Emission", Range(0,1)) = 0

        [NoScaleOffset] _MatCapGreen ("MatCap", 2D) = "white" {}
        _BorderGreen ("Border", Range(0,1)) = 0.3

        _RimPowerGreen( "Rim Power", Range( 0.00, 1.00 )) = 0.2
        
        _EmissionColorGreen ("Rimlight Color", Color) = (0.2,0.18,0.196,1)

        _GlassColorGreen ("Glass Color", Color) = (1, 1, 1, 1)
		_EdgeColorGreen ("Edge Color", Color) = (1, 1, 1, 1)
		_EdgeThicknessGreen ("Silouette Dropoff Rate", float) = 1.0

        _AlphaGreen ("Alpha", Range(0,1)) = 0.1

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
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "VRCFallback"="Hidden" "IgnoreProjector"="True"}
        ColorMask RGB


        HLSLINCLUDE
            #pragma skip_variants LIGHTMAP_ON DYNAMICLIGHTMAP_ON LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK DIRLIGHTMAP_COMBINED

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTexRed;
            float4  _MainTexRed_ST;

            // iigo properties
            float _EmissionRed;
            float4 _EmissionColorRed;

            sampler2D _MatCapRed;
            float _BorderRed;

            float _RimPowerRed;

            
            //green ==================================

            sampler2D _MainTexGreen;
            float4  _MainTexGreen_ST;

            // iigo properties
            float _EmissionGreen;
            float4 _EmissionColorGreen;

            sampler2D _MatCapGreen;
            float _BorderGreen;

            float _RimPowerGreen;

            float _AlphaGreen;

            float4	_GlassColorGreen;
			float4	_EdgeColorGreen;
			float   _EdgeThicknessGreen;

            //==================================================================
            // iigo cginc
            //==================================================================

            #ifndef IIGO_SHADERPACK
            #define IIGO_SHADERPACK
            #endif

            #include "iigo.cginc"

        ENDHLSL

        // ---------------------------------------------------------------------
        // DROOL // RED
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

            //#define iigo_matCap_ENABLED
                //#define iigo_matCap_BORDER _BorderRed
                //#define iigo_matCap_TEXTURE _MatCapRed
                //#define iigo_matCap_EMISSION _EmissionRed

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerRed
                #define iigo_rimlight_COLOR _EmissionColorRed

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

            //#define iigo_matCap_ENABLED
                //#define iigo_matCap_BORDER _BorderRed
                //#define iigo_matCap_TEXTURE _MatCapRed
                //#define iigo_matCap_EMISSION _EmissionRed

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerRed
                #define iigo_rimlight_COLOR _EmissionColorRed

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        // ---------------------------------------------------------------------
        // GLASS // GREEN
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

            #define iigo_glass_ENABLED
                #define iigo_glass_ALPHA _AlphaGreen
                #define iigo_glass_COLOR _GlassColorGreen 
                #define iigo_glass_EDGECOLOR _EdgeColorGreen     
                #define iigo_glass_EDGETHICKNESS _EdgeThicknessGreen
                #define iigo_glass_EMISSION _EmissionGreen

            //#define iigo_matCap_ENABLED
                //#define iigo_matCap_BORDER _BorderGreen
                //#define iigo_matCap_TEXTURE _MatCapGreen
                //#define iigo_matCap_EMISSION _EmissionGreen

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerGreen
                #define iigo_rimlight_COLOR _EmissionColorGreen

            #include "iigo_Base.cginc"

            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}

            BlendOp [_BlendOpFA], Max
            Blend [_SrcBlendFA] [_DstBlendFA], SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog

            #define IIGO_GREEN

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_glass_ENABLED
                #define iigo_glass_ALPHA _AlphaGreen
                #define iigo_glass_COLOR _GlassColorGreen 
                #define iigo_glass_EDGECOLOR _EdgeColorGreen     
                #define iigo_glass_EDGETHICKNESS _EdgeThicknessGreen
                #define iigo_glass_EMISSION _EmissionGreen

            //#define iigo_matCap_ENABLED
                //#define iigo_matCap_BORDER _BorderGreen
                //#define iigo_matCap_TEXTURE _MatCapGreen
                //#define iigo_matCap_EMISSION _EmissionGreen

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER _RimPowerGreen
                #define iigo_rimlight_COLOR _EmissionColorGreen

            #include "iigo_Add.cginc"
            ENDHLSL
        }
    }

    // Enable ShadowCaster by fallback to Standard
    Fallback "Standard"
}