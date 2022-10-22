Shader "iigo/iigo/ADDONS"
{
    Properties
    {
        //------------------------------------------------------------------------------------------------------------------------------
        // Properties for material


        //fallback stuff

        _MainTex ("Texture", 2D) = "black" {}
        //----------------------------------------------------------------------

        
        [NoScaleOffset] _MatCap ("MatCap", 2D) = "white" {}
        [Header(RED MAT)]

        // Properties for material
        _MainTexRed ("Texture", 2D) = "white" {}

        _MainMask ("Mask", 2D) = "white" {}

        //[NoScaleOffset] _MainTexEmission ("Texture Emission", 2D) = "black" {}

        //============================================================

        _Meter( "Meter", Range( 0.0, 1.0 )) = 0.0

        [Space(20)]
		[Header(GREEN MAT)]
		[Space(5)]

        _MainTexGreen ("Texture", 2D) = "white" {}

        [Space(20)]
		[Header(BLUE MAT)]
		[Space(5)]

        _MainTexBlue ("Texture", 2D) = "white" {}

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
        Tags { "RenderType"="Opaque" "VRCFallback"="Unlit" "IgnoreProjector"="True"}

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

            sampler2D _MainMask;

            //sampler2D _MainTexEmission;

            float _Meter;

            //float _MeterEmission;

            //GREEN
            //=====================================================

            sampler2D _MainTexGreen;
            float4  _MainTexGreen_ST;

            //BLUE
            //=====================================================

            sampler2D _MainTexBlue;
            float4  _MainTexBlue_ST;

            //==================================================================
            // iigo cginc
            //==================================================================

            #ifndef IIGO_SHADERPACK
            #define IIGO_SHADERPACK
            #endif

            #include "iigo.cginc"

        ENDHLSL

        // ---------------------------------------------------------------------
        // PIN // RED
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
                #define iigo_texture_EMISSION (float(0.2) * tex2D(_MainMask, i.uv).g)

            //#define iigo_matCap_ENABLED
                //#define iigo_matCap_BORDER float(0.3)
                //#define iigo_matCap_TEXTURE _MatCap
                //#define iigo_matCap_EMISSION float(0)

            #define iigo_meter_ENABLED
                #define iigo_meter_METERCOLOR float4(0.86, 1.0, 0.98, 1.0)
                #define iigo_meter_METERCOLOR2 float4(0.69, 0.8, 0.79, 1.0)
                #define iigo_meter_METER2COLOR float4(1.0, 0.86, 0.96, 1.0)
                #define iigo_meter_METER2COLOR2 float4(0.85, 0.74, 0.82, 1.0)
                #define iigo_meter_METER _Meter
                #define iigo_meter_METERMASK (float(1.0) * tex2D(_MainMask, i.uv).r)
                #define iigo_meter_EMISSION float(0.2)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER iigo_global_RIMPOWER
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

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
                #define iigo_texture_EMISSION (float(0.2) * tex2D(_MainMask, i.uv).g)

            //#define iigo_matCap_ENABLED
                //#define iigo_matCap_BORDER float(0.3)
                //#define iigo_matCap_TEXTURE _MatCap
                //#define iigo_matCap_EMISSION float(0)

            #define iigo_meter_ENABLED
                #define iigo_meter_METERCOLOR float4(0.86, 1.0, 0.98, 1.0)
                #define iigo_meter_METERCOLOR2 float4(0.69, 0.8, 0.79, 1.0)
                #define iigo_meter_METER2COLOR float4(1.0, 0.86, 0.96, 1.0)
                #define iigo_meter_METER2COLOR2 float4(0.85, 0.74, 0.82, 1.0)
                #define iigo_meter_METER _Meter
                #define iigo_meter_METERMASK (float(1.0) * tex2D(_MainMask, i.uv).r)
                #define iigo_meter_EMISSION float(0.2)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER iigo_global_RIMPOWER
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        // ---------------------------------------------------------------------
        // FRAMES // GREEN
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
                #define iigo_texture_EMISSION float(0)

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER float(0.3)
                #define iigo_matCap_TEXTURE _MatCap
                #define iigo_matCap_EMISSION float(0)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER iigo_global_RIMPOWER
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

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
                #define iigo_texture_EMISSION float(0)

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER float(0.3)
                #define iigo_matCap_TEXTURE _MatCap
                #define iigo_matCap_EMISSION float(0)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER iigo_global_RIMPOWER
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        // ---------------------------------------------------------------------
        // COLLAR // BLUE
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
                #define iigo_texture_EMISSION float(0)

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER float(0.3)
                #define iigo_matCap_TEXTURE _MatCap
                #define iigo_matCap_EMISSION float(0)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER iigo_global_RIMPOWER
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

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
                #define iigo_texture_EMISSION float(0)

            #define iigo_matCap_ENABLED
                #define iigo_matCap_BORDER float(0.3)
                #define iigo_matCap_TEXTURE _MatCap
                #define iigo_matCap_EMISSION float(0)

            #define iigo_rimlight_ENABLED
                #define iigo_rimlight_POWER iigo_global_RIMPOWER
                #define iigo_rimlight_COLOR iigo_global_RIMLIGHTCOLOR

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        
    }

    // Enable ShadowCaster by fallback to Standard
    Fallback "Standard"
}