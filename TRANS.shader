Shader "iigo/iigo/TRANS"
{
    Properties
    {     
        [Header(RED MAT)]
        _MainTexRed ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "VRCFallback"="Hidden" "IgnoreProjector"="True"}
        
        cull off
        ColorMask RGB


        HLSLINCLUDE
            #pragma skip_variants LIGHTMAP_ON DYNAMICLIGHTMAP_ON LIGHTMAP_SHADOW_MIXING SHADOWS_SHADOWMASK DIRLIGHTMAP_COMBINED

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            //red ==================================

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

        // https://github.com/pema99/shader-knowledge/blob/main/tips-and-tricks.md#avoiding-draw-order-issues-with-transparent-shaders
        Pass
        {
            ZWrite On
            ColorMask 0
        }

        // ---------------------------------------------------------------------
        // DROOL // RED
        // ---------------------------------------------------------------------

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            BlendOp Add
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #define IIGO_RED

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_texture_ENABLED
                #define iigo_texture_TEXTURE _MainTexRed
                #define iigo_texture_EMISSION float(0.0)

            #include "iigo_Base.cginc"

            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}

            BlendOp Max
            Blend One One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog

            #define IIGO_RED

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_texture_ENABLED
                #define iigo_texture_TEXTURE _MainTexRed
                #define iigo_texture_EMISSION float(0.0)

            #include "iigo_Add.cginc"
            ENDHLSL
        }

        // ---------------------------------------------------------------------
        // GLASS // GREEN
        // ---------------------------------------------------------------------

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            BlendOp Add
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #define IIGO_GREEN

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_glass_ENABLED
                #define iigo_glass_ALPHA float(0.5)
                #define iigo_glass_COLOR float4(1.0, 1.0, 1.0, 0.1)
                #define iigo_glass_EDGECOLOR float4(1.0, 1.0, 1.0, 1.0)  
                #define iigo_glass_EDGETHICKNESS float(1.0)
                #define iigo_glass_EMISSION float(0.0)

            #include "iigo_Base.cginc"

            ENDHLSL
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}

            BlendOp Max
            Blend One One

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #pragma multi_compile_fog

            #define IIGO_GREEN

            #define iigo_base_COLOR float4(1,1,1,1)

            #define iigo_glass_ENABLED
                #define iigo_glass_ALPHA float(0.5)
                #define iigo_glass_COLOR float4(1.0, 1.0, 1.0, 0.1)
                #define iigo_glass_EDGECOLOR float4(1.0, 1.0, 1.0, 1.0)     
                #define iigo_glass_EDGETHICKNESS float(1.0)
                #define iigo_glass_EMISSION float(0.0)

            #include "iigo_Add.cginc"
            ENDHLSL
        }
    }

    // Enable ShadowCaster by fallback to Standard
    Fallback "Standard"
}