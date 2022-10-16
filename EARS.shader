Shader "iigo/iigo/EARS"
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

            //==================================================================
            // iigo cginc
            //==================================================================

            #ifndef IIGO_SHADERPACK
            #define IIGO_SHADERPACK
            #endif

            #include "iigo.cginc"

        ENDHLSL

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

            #include "iigo_Add.cginc"
            ENDHLSL
        }
    }

    // Enable ShadowCaster by fallback to Standard
    Fallback "Standard"
}