            struct appdata
            {
                float4 vertex   : POSITION;
                float2 uv       : TEXCOORD0;
                float4 uv1      : TEXCOORD1;
                float3 normalOS : NORMAL;
                float4 color    : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos           : SV_POSITION;
                float3 positionWS    : TEXCOORD0;
                float2 uv            : TEXCOORD1;
                float3 normalWS      : TEXCOORD2;
                nointerpolation float3 directLight : TEXCOORD3;
                UNITY_FOG_COORDS(4)
                UNITY_LIGHTING_COORDS(5, 6)
                float3 camPos        : TEXCOORD7;
                float4 audioLinkData : TEXCOORD8;
                float4 scrPos : POSITION2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                // Gets the worldspace position of the camera or inbetween both cameras in vr
                o.camPos = iigo_playerCenterCamera();

                // Gets the data for the time and base/treble from audiolink if in scene

                if(AudioLinkIsAvailable())
                {
                    o.iigo_audioLinkData_TIMEX  = AudioLinkDecodeDataAsSeconds( ALPASS_GENERALVU_NETWORK_TIME ) / 20.0; //same as _Time.x
                    o.iigo_audioLinkData_TIMEY  = AudioLinkDecodeDataAsSeconds( ALPASS_GENERALVU_NETWORK_TIME );        //same as _Time.y
                    o.iigo_audioLinkData_BASS   = AudioLinkData( ALPASS_AUDIOBASS );
                    o.iigo_audioLinkData_TREBLE = AudioLinkData( ALPASS_AUDIOTREBLE );
                }
                else
                {
                    o.iigo_audioLinkData_TIMEX  = _Time.x;
                    o.iigo_audioLinkData_TIMEY  = _Time.y;
                    o.iigo_audioLinkData_BASS   = 0.0;
                    o.iigo_audioLinkData_TREBLE = 0.0;
                } 

                float3 position = v.vertex.xyz;

                #ifdef iigo_hairOutline_ENABLED
                    position = iigo_hairOutline(v.vertex, v.normalOS, iigo_hairOutline_THICKNESS);
                #endif

                #ifdef iigo_pants_ENABLED
                    position = iigo_pants(position, o.audioLinkData.xy); // this is broken atm and just returns position.xyz
                #endif
                #undef iigo_pants_ENABLED

                o.positionWS    = mul(unity_ObjectToWorld, float4(position.xyz, 1.0));
                o.pos           = UnityWorldToClipPos(o.positionWS);
                #ifdef iigo_texture_ENABLED
                o.uv            = TRANSFORM_TEX(v.uv, iigo_texture_TEXTURE);
                #else
                o.uv            = v.uv;
                #endif
                o.normalWS      = UnityObjectToWorldNormal(v.normalOS);

                o.scrPos = ComputeGrabScreenPos(o.pos);

                UNITY_TRANSFER_FOG(o,o.pos);
                UNITY_TRANSFER_LIGHTING(o,v.uv1);

                #ifdef IIGO_SHADERPACK
                    #ifdef IIGO_RED
                        if (v.color.r != 1)
                        {
                            o.pos = -1;
                        }
                    #endif
                    #ifdef IIGO_GREEN
                        if (v.color.g != 1)
                        {
                            o.pos = -1;
                        }
                    #endif
                    #ifdef IIGO_BLUE
                        if (v.color.b != 1)
                        {
                            o.pos = -1;
                        }
                    #endif
                #endif

                #undef IIGO_RED
                #undef IIGO_GREEN
                #undef IIGO_BLUE

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.positionWS);
                

                float4 col = iigo_base_COLOR;

                col.rgb *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));

                // TEXTURE
                // =============================================================

                #ifdef iigo_texture_ENABLED

                    // emission
                    float4 emission = iigo_texture_EMISSION;

                    // Sample the albedo texture
                    float4 albedo = tex2D(iigo_texture_TEXTURE, i.uv);

                    // Applies the overall emmission value
                    albedo.rgb *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));

                    col = albedo;

                #endif
                #undef iigo_texture_ENABLED

                // DISTORTEDTEXTURE
                // =============================================================

                #ifdef iigo_distortedTexture_ENABLED

                    col = iigo_distortedTexture(i.uv, i.iigo_audioLinkData_TIMEX, iigo_distortedTexture_DISTORTIONTEX, iigo_distortedTexture_MAINTEX);

                    col.rgb *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));

                #endif
                #undef iigo_distortedTexture_ENABLED

                // HOODIE
                // =============================================================

                #ifdef iigo_hoodie_ENABLED

                    float4 hoodie = iigo_hoodieColor(i.uv, iigo_hoodie_SPEED, i.audioLinkData, iigo_hoodie_SCALE, iigo_hoodie_PORK, iigo_hoodie_BEEF, iigo_hoodie_ALPHA, iigo_hoodie_COLOR);

                    hoodie.rgb *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));

                    col.rgb = lerp(col.rgb, hoodie.rgb, hoodie.a);

                #endif
                #undef iigo_hoodie_ENABLED

                // GLASS
                // =============================================================

                #ifdef iigo_glass_ENABLED
                    // Sample the albedo texture
                    float4 glass = iigo_glass(_AlphaGreen, i.camPos, i.positionWS, i.normalWS, iigo_glass_COLOR, iigo_glass_EDGECOLOR, iigo_glass_EDGETHICKNESS);

                    // Applies the overall emmission value
                    glass.rgb *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));

                    col = glass;              
                #endif
                #undef iigo_glass_ENABLED

                // HAIR OUTLINE
                // =============================================================

                #ifdef iigo_hairOutline_ENABLED

                    col = iigo_hairOutline_COLOR;
                    //emission
                    col.rgb *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));

                #endif
                #undef iigo_hairOutline_ENABLED

                // MAKEUP
                // =============================================================

                #ifdef iigo_catMakeup_ENABLED

                    float4 makeup = tex2D(_MakeupTexGreen, i.uv);

                    col.rgb = saturate(lerp(col.rgb, col.rgb * makeup.rgb, makeup.a * _MakeupGreen));

                #endif
                #undef iigo_catMakeup_ENABLED

                

                // Meter
                // =============================================================

                #ifdef iigo_meter_ENABLED

                    float4 meterColor = iigo_meter(i.uv, col, iigo_meter_METERCOLOR, iigo_meter_METERCOLOR2, iigo_meter_METER2COLOR, iigo_meter_METER2COLOR2, iigo_meter_METER, iigo_meter_METERMASK, i.iigo_audioLinkData_TIMEY);

                    meterColor.rgb *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));

                    col.rgb = lerp(col.rgb, meterColor.rgb, meterColor.a);

                #endif
                #undef iigo_meter_ENABLED

                // EYES
                // =============================================================

                #ifdef iigo_eyes_ENABLED

                    float4 Panosphere = saturate( iigo_panosphere(i.positionWS, i.camPos, iigo_eyes_TEXTURE, i.iigo_audioLinkData_TIMEX));

                    col.rgb = lerp(col.rgb, max(Panosphere.rgb, col.rgb), iigo_eyes_ALPHA);

                #endif
                #undef iigo_eyes_ENABLED

                // Rimlight
                // =============================================================

                #ifdef iigo_rimlight_ENABLED

                    #ifndef iigo_rimlight_ALPHA
                        #define iigo_rimlight_ALPHA 1
                    #endif

                    #ifndef iigo_rimlight_RATIO
                        #define iigo_rimlight_RATIO float2(0.3,0.0)
                    #endif

                    // Returns the raw rimlight power
                    float3 rim = iigo_rimlight(i.normalWS, i.positionWS, i.camPos, iigo_rimlight_POWER);


                    // Applies the "Glow in the Dark Rimlight"
                    float  rimPower  = smoothstep(iigo_rimlight_RATIO.x, iigo_rimlight_RATIO.y, attenuation) * iigo_rimlight_ALPHA;

                    #ifdef iigo_rimlight_IGNORELIGHT
                        rimPower = 1.0;
                    #endif
                    #undef iigo_rimlight_IGNORELIGHT

                    col.rgb = lerp(col.rgb, max(col.rgb , (rim.rgb * iigo_rimlight_COLOR)), rimPower);

                #endif
                #undef iigo_rimlight_ENABLED

                // Matcap
                // =============================================================

                #ifdef iigo_matCap_ENABLED

                    // Returns the Matcap color
                    float4 matCap = iigo_matCap(i.normalWS, i.positionWS, i.camPos, iigo_matCap_BORDER, iigo_matCap_TEXTURE);

                    // Light
                    matCap.rgb *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));

                    // Applies the matcap color
                    #ifndef iigo_matCap_FULL
                        col.rgb = lerp(col.rgb, col.rgb * matCap.rgb, .1);
                        col.rgb = lerp(col.rgb, col.rgb + matCap.rgb, .1);
                    #else
                        col.rgb = lerp(col.rgb, max(col.rgb, matCap.rgb), matCap.a);
                    #endif
                    #undef iigo_matCap_FULL

                #endif
                #undef iigo_matCap_ENABLED

                // GLITCH FLIPBOOK
                // =============================================================

                #ifdef iigo_glitchFlipbook_ENABLED

                    float4 tex = iigo_glitchFlipbook(i.audioLinkData, i.uv, UNITY_PASS_TEX2DARRAY(iigo_glitchFlipbook_TEXTUREARRAY));

                    tex.rgb *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));
                    col.rgb = max(col.rgb, tex.rgb);

                #endif
                #undef iigo_glitchFlipbook_ENABLED

                // GT OUTLINE
                // =============================================================

                #ifdef gt_outline_ENABLED

                    const float2 centerUV  = i.scrPos.xy / i.scrPos.w;

                    //col = float4(float2(centerUV),1,1);

                    float3 diffuse = col.rgb;

                    float3 outlineColor = gt_outline_COLOR;

                    outlineColor *= saturate(lerp(0.0, _LightColor0.rgb, attenuation));

                    applyToonOutline(diffuse, centerUV, i.pos.w, gt_outline_COLOR.a, outlineColor);

                    col.rgb = diffuse;

                #endif
                #undef gt_outline_ENABLED

                UNITY_APPLY_FOG(i.fogCoord, col);

                col.rgb *= saturate(col.a);

                return col;
            }