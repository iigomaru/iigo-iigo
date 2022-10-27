// audiolink
#include "AudioLink.cginc"

#include "hashwithoutsine.cginc"

#define iigo_audioLinkData_TIMEX  audioLinkData.x
#define iigo_audioLinkData_TIMEY  audioLinkData.y
#define iigo_audioLinkData_BASS   audioLinkData.z
#define iigo_audioLinkData_TREBLE audioLinkData.w

#define iigo_audioLinkData_SETUP if(AudioLinkIsAvailable())\
                                    {\
                                        o.audioLinkData.x = AudioLinkDecodeDataAsSeconds( ALPASS_GENERALVU_NETWORK_TIME ) / 20.0; /*same as _Time.x*/ \
                                        o.audioLinkData.y  = AudioLinkDecodeDataAsSeconds( ALPASS_GENERALVU_NETWORK_TIME );        /*same as _Time.y*/ \
                                        o.audioLinkData.z   = AudioLinkData( ALPASS_AUDIOBASS ); \
                                        o.audioLinkData.w = AudioLinkData( ALPASS_AUDIOTREBLE ); \
                                    }\
                                    else\
                                    {\
                                        o.audioLinkData.x  = _Time.x;\
                                        o.audioLinkData.y  = _Time.y;\
                                        o.audioLinkData.z  = 0.0;\
                                        o.audioLinkData.w = 0.0;\
                                    }
// Global Shader Property defines

#define iigo_global_RIMLIGHTCOLOR float4(0.2,0.18,0.196,1)
#define iigo_global_RIMPOWER      float(0.2)
#define BLACK                     float4(0.0, 0.0, 0.0, 1.0)

float _VRChatMirrorMode;
float3 _VRChatMirrorCameraPos;

float3 iigo_playerCenterCamera()
{
    #if defined(USING_STEREO_MATRICES)
    float3 PlayerCenterCamera = ( unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1] ) / 2;
    #else
    float3 PlayerCenterCamera = _WorldSpaceCameraPos.xyz;
    #endif

    if (_VRChatMirrorMode > 0)
    {
        PlayerCenterCamera = _VRChatMirrorCameraPos;
    }

    return PlayerCenterCamera;
}

float iigo_AA(float2 input)
{
    float derivX = ddx(input.x);
    float derivY = ddy(input.y);
    float gradientLength = length(float2(derivX, derivY));
    float thresholdWidth = 1.0 * gradientLength;  // the 2.0 is a constant you can tune
        //thresholdWidth = 0.00001;

    return thresholdWidth;
}

float smoothmin(float a, float b, float k)
{
    float x = exp(-k * a);
    float y = exp(-k * b);
    return (a * x + b * y) / (x + y);
}

float smoothmax(float a, float b, float k)
{
    return smoothmin(a, b, -k);
}

void iigo_ComputeFlat(out float3 directLight)
{
    #if !defined(LIGHTMAP_ON) && UNITY_SHOULD_SAMPLE_SH
        directLight   =  float3(unity_SHAr.w + unity_SHBr.z/3, unity_SHAg.w + unity_SHBg.z/3, unity_SHAb.w + unity_SHBb.z/3); // thx lox
    #else
        directLight = 0.0;
    #endif
    directLight += _LightColor0.rgb;
    directLight = clamp(directLight, 0.0, 1.0);
}

// This math is from https://gist.github.com/bgolus/02e37cd76568520e20219dc51653ceaa

float4 iigo_matCap(float3 worldSpaceNormal, float3 worldSpacePos, float3 cameraPos, float MatcapBorder, sampler2D MatcapTexture)
{
    float3 worldSpaceViewDir = normalize(worldSpacePos - cameraPos);

    float3 up = mul((float3x3)UNITY_MATRIX_I_V, float3(0,1,0));
    float3 right = normalize(cross(up, worldSpaceViewDir));
    up = cross(worldSpaceViewDir, right);
    float2 matcapUV = mul(float3x3(right, up, worldSpaceViewDir), worldSpaceNormal).xy;

    // remap from -1 .. 1 to 0 .. 1
    matcapUV = matcapUV * MatcapBorder + 0.5;

    float4 matCap = tex2D(MatcapTexture, matcapUV);

    return matCap; 
}

float2 iigo_matCap(float3 worldSpaceNormal, float3 worldSpacePos, float3 cameraPos, float MatcapBorder)
{
    float3 worldSpaceViewDir = normalize(worldSpacePos - cameraPos);

    float3 up = mul((float3x3)UNITY_MATRIX_I_V, float3(0,1,0));
    float3 right = normalize(cross(up, worldSpaceViewDir));
    up = cross(worldSpaceViewDir, right);
    float2 matcapUV = mul(float3x3(right, up, worldSpaceViewDir), worldSpaceNormal).xy;

    // remap from -1 .. 1 to 0 .. 1
    matcapUV = matcapUV * MatcapBorder + 0.5;

    return matcapUV;
}

float iigo_rimlight(float3 worldSpaceNormal, float3 worldSpacePos, float3 cameraPos, float RimPower)
{
    float3 viewDir = normalize(cameraPos - worldSpacePos);
    float3 preRim = saturate( dot( viewDir, worldSpaceNormal ) );

    float rimAA = iigo_AA(preRim.xx);

    //return float3(rimAA.xxx * 10);

    //preRim = smoothstep(0 + rimAA *, 1 + rimAA, preRim);
    float3 rim = 1 / (1 + exp(100 * (preRim - RimPower)));
    //float3 rim = saturate(pow(1 - preRim , RimPower));

    //rim = rim - (rimAA );

    if (preRim.x == 0.0)
    {
        rim = float3( 0,0,0 );
    }

    //return preRim;

    return saturate(rim);
}

float4 iigo_panosphere(float3 worldspacePos, float3 cameraPos, sampler2D PanosphereTexture, float time)
{
    float3 normalizedCoords = normalize(worldspacePos - cameraPos);
    float latitude = acos(normalizedCoords.y);
    float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
    float2 sphereCoords = float2(longitude, latitude) * float2(1.0 / UNITY_PI, 1.0 / UNITY_PI);
    sphereCoords = float2(1.0, 1.0) - sphereCoords;
    sphereCoords = float2(sphereCoords.x, sphereCoords.y + time * .1);

    float4 Panosphere = tex2D(PanosphereTexture, float2(sphereCoords.x * 20, sphereCoords.y * 20));
    return Panosphere;
}



float4 iigo_meter(float2 uv, float4 col, float4 MeterColor, float4 MeterColor2, float4 Meter2Color, float4 Meter2Color2, float Meter, float meterMask, float time)
{
    float4 meterColor = float4(col.rgb, 1);

    float level = uv.y + sin(uv.x * 20 + sin(time)) / 50;

    float level2 = uv.y + sin(uv.x * 20 + sin(time * .9) * 2 ) / 50;

    float thresholdWidth = iigo_AA(level.xx);

    float Meter2 = Meter - .1 + (sin(time) / 50); 

    meterColor.rgb = lerp(meterColor.rgb, MeterColor, saturate(smoothstep(Meter,Meter - thresholdWidth, level) - .25));

    meterColor.rgb = lerp(meterColor.rgb, MeterColor2, saturate(smoothstep(Meter,Meter - thresholdWidth - .1, level) - .25));

    meterColor.rgb = lerp(meterColor.rgb, Meter2Color, saturate(smoothstep(Meter2,Meter2 - thresholdWidth, level2) - .25));

    meterColor.rgb = lerp(meterColor.rgb, Meter2Color2, saturate(smoothstep(Meter2,Meter2 - thresholdWidth - .1, level2) - .25));

    meterColor.a = saturate(smoothstep(Meter,Meter - thresholdWidth, level));

    meterColor.a *= meterMask;

    return meterColor;
}

float iigo_hairEmission(sampler2D EmissionTex, float2 uv, float emissionValue, float3 positionWS, float time)
{
    // Samples the emission texture
    float3 emissionCol = tex2D(EmissionTex, uv).rgb;
    float  emissionDot = dot(float3(1,1,1), emissionCol);

    // scrolling emission
    float  verticalHight = fmod(positionWS.y + time * 2, 30);
    emissionValue = min(smoothstep(0,1, verticalHight), smoothstep(1,0, verticalHight));

    return emissionValue * emissionDot;
}

float3 iigo_hairOutline(float4 vertex, float3 normalOS, float OutlineThickness)
{
    float3 normal = normalize(normalOS);
    float3 outlineOffset = normal * OutlineThickness;
    float3 position = vertex.xyz + outlineOffset;

    return position;
}

float4 iigo_glass(float alpha, float3 cameraPosition, float3 worldspacePos, float3 normalWS, float4 glassColor, float4 edgeColor, float edgeThickness)
{
    // =============================================================
    // sample texture for color
    //float4 texColor = tex2D(_MainTex, input.texCoord.xy);
    float4 texColor = float4(1,1,1, alpha);

    // apply silouette equation
    // based on how close normal is to being orthogonal to view vector
    // dot product is smaller the smaller the angle bw the vectors is
    // close to edge = closer to 0
    // far from edge = closer to 1
    float3 viewDir = normalize(cameraPosition - worldspacePos);
    float3 N = normalize(normalWS);
    float edgeFactor = abs(dot(viewDir, N));

    // apply edgeFactor to Albedo color & EdgeColor
    float oneMinusEdge = 1.0 - edgeFactor;
    float3 rgb = (glassColor.rgb * edgeFactor) + (edgeColor.rgb * oneMinusEdge);
    rgb = min(float3(1, 1, 1), rgb); // clamp to real color vals
    rgb = rgb * texColor.rgb;

    // apply edgeFactor to Albedo transparency & EdgeColor transparency
    // close to edge = more opaque EdgeColor & more transparent Albedo 
    float opacity = min(1.0, glassColor.a / edgeFactor);

    // opacity^thickness means the edge color will be near 0 away from the edges
    // and escalate quickly in opacity towards the edges
    opacity = pow(opacity, edgeThickness);
    opacity = opacity * texColor.a;
    // =============================================================

    float4 col = saturate(float4(rgb, opacity));

    return col;
}

float4 iigo_distortedTexture(float3 position, float time, float3 color1, float3 color2)
{
    float4 col = float4(0.0, 0.0, 0.0, 1.0);

    col.x = csimplex3(float3(abs(position + time )));

    col.y = csimplex3(float3(abs(position + time * 0.5 )));

    col.z = csimplex3(float3(abs(position + time * 2.0 )));

    col.xyz = csimplex3(col);

    col.xyz = lerp(color1, color2, saturate(col.x + 0.5));

    return saturate(col);
}

float2 rotateUVmatrix(float2 uv, float rotation)
{
    float2x2 rotation_matrix = transpose(float2x2(float2(sin(rotation), -cos(rotation)), float2(cos(rotation), sin(rotation))));
    uv = mul(uv,rotation_matrix);
    return uv;
}

#define SQRT3DIV2   0.86602540378
#define SQRT3       1.73205080757
#define TWODIVSQRT3 1.15470053838
#define SQRT3DIV4   0.43301270189 

// https://andrewhungblog.wordpress.com/2018/07/28/shader-art-tutorial-hexagonal-grids/
float4 calcHexInfo(float2 uv) 
{
    // remember, s is vec2(1, sqrt(3))
    float2 s = float2(1,SQRT3);
    float4 hexCenter = round(float4(uv, uv - float2(.5, 1.)) / s.xyxy);
    float4 offset = float4(uv - hexCenter.xy * s, uv - (hexCenter.zw + .5) * s);
    return dot(offset.xy, offset.xy) < dot(offset.zw, offset.zw) ? 
    float4(offset.xy, hexCenter.xy) : float4(offset.zw, -hexCenter.zw);
}

float calcHexDistance(float2 p) 
{
    p = abs(p);
    return max(dot(p, float2(1,SQRT3) * .5), p.x);
}


float calcHexDistance2(float2 p, float2 q) 
{
    p = abs(p);
    q = abs(q);
    float pM = max(dot(p, float2(1,SQRT3) * .5), p.x);
    float qM = max(dot(q, float2(1,SQRT3) * .5), q.x);
    return max(pM,qM);
}

// this might be broken right now needs more testing. might just be mirrors?
inline float3 iigo_pants(float3 position, float2 time)
{
    float porktime = 0.0;

    if(AudioLinkIsAvailable())
    {
        porktime = min(AudioLinkData( ALPASS_AUDIOTREBLE  ), AudioLinkData( ALPASS_AUDIOBASS  ));
    }
    else
    {
        porktime = fmod((time.x * 5) * sin(time.x + 10), 1);
    }

    float3 modPos      = position;
    modPos.x           = modPos.x + sin(modPos.x * 5000 * time.y) / 80;
    position.xyz    = lerp(position.xyz, modPos, smoothstep(0.9,1.0,porktime));

    return position;
}

float iigo_hoodieDistance(float2 UV)
{
    float2 Hex = calcHexInfo(UV); //

    float2 Hex2 = calcHexInfo(float2(UV.x + 0.5 ,UV.y));

    float2 ModUV = float2(UV.x + 0.25, UV.y + SQRT3DIV4);

    float2 Hex3 = calcHexInfo(ModUV); //

    float2 Hex4 = calcHexInfo(float2(ModUV.x + 0.5 ,ModUV.y));

    float TotalDist = calcHexDistance2(Hex.xy, Hex2.xy);

    float TotalDist2 = calcHexDistance2(Hex3.xy, Hex4.xy);

    TotalDist = max(TotalDist,TotalDist2);

    float2 Hex5 = calcHexInfo(float2(UV.y + SQRT3DIV2, UV.x + 1) * TWODIVSQRT3 ); //

    float2 Hex6 = calcHexInfo(float2(UV.y + SQRT3DIV2, UV.x + 0.5) * TWODIVSQRT3 ); //

    float2 Hex7 = calcHexInfo(float2(UV.y + SQRT3DIV2, UV.x) * TWODIVSQRT3 ); //

    TotalDist2 = calcHexDistance2(Hex5, Hex6);

    TotalDist = max(TotalDist,TotalDist2);

    TotalDist2 = calcHexDistance(Hex7);

    TotalDist = max(TotalDist,TotalDist2);

    return TotalDist;
}

float iigo_hoodieDots(float2 UV, float Modifyer)
{
    
    float2 Hex = calcHexInfo(UV); //

    float time = AudioLinkDecodeDataAsUInt( ALPASS_CHRONOTENSITY +
        uint2( 3, 2 ) ) % 628318;

    time = time / 100000;

    Hex = rotateUVmatrix(Hex, time);

    float  Dot = 1.0 - calcHexDistance(Hex);

    Dot *= Modifyer;

    float2 Hex2 = calcHexInfo(float2(UV.x + 0.5 ,UV.y));

    time = time + 1;

    Hex2 = rotateUVmatrix(Hex2, time);

    float  Dot2 =  1.0 - calcHexDistance(Hex2);

    Dot2 *= Modifyer;

    float2 ModUV = float2(UV.x + 0.25, UV.y + SQRT3DIV4);

    float2 Hex3 = calcHexInfo(ModUV); //

    time = time + 1;

    Hex3 = rotateUVmatrix(Hex3, time);

    float  Dot3 =  1.0 - calcHexDistance(Hex3);

    Dot3 *= Modifyer;

    float2 Hex4 = calcHexInfo(float2(ModUV.x + 0.5 ,ModUV.y));

    time = time + 1;

    Hex4 = rotateUVmatrix(Hex4, time);

    float  Dot4 =  1.0 - calcHexDistance(Hex4);

    Dot4 *= Modifyer;

    float  TotalDot = max(Dot, Dot2);
    
    float  TotalDot2 = max(Dot3, Dot4);

           TotalDot  = max(TotalDot, TotalDot2);

    return TotalDot;
}

float inverse_smoothstep(float x) {
  return 0.5 - sin(asin(1.0 - 2.0 * x) / 3.0);
}

float iigo_hoodieTing(float TotalDist, float pork, float bass, float beef, float treble)
{
    float Porky = (pork - bass);

    Porky = inverse_smoothstep(inverse_smoothstep(Porky));
    
    Porky = Porky * (0.502 - 0.48) + 0.48; //

    float BarAlpha = 0; //

    float Beefy = (beef + treble);

    Beefy = inverse_smoothstep(inverse_smoothstep(Beefy));

    Beefy = Beefy * (0.02 - 0.01) + 0.01;

    float distFromEdge = 1.0 - TotalDist;

    float thresholdWidth = iigo_AA(distFromEdge.xx);

    BarAlpha = smoothstep((Porky - Beefy) - thresholdWidth, (Porky - Beefy) + thresholdWidth, TotalDist);

    BarAlpha *= smoothstep((Porky ) + thresholdWidth, (Porky ) - thresholdWidth,  TotalDist);

    return BarAlpha;
}

float iigo_hoodieTingDots(float TotalDist, float pork, float bass, float beef, float treble)
{
    float Porky = (pork - bass);

    Porky = inverse_smoothstep(inverse_smoothstep(Porky));
    
    Porky = Porky * (0.502 - 0.48) + 0.48; //

    float BarAlpha = 0; //

    float Beefy = 0.01;

    float distFromEdge = 1.0 - TotalDist;

    float thresholdWidth = iigo_AA(distFromEdge.xx);

    BarAlpha = smoothstep((Porky - Beefy) - thresholdWidth, (Porky - Beefy) + thresholdWidth, TotalDist);

    BarAlpha *= smoothstep((Porky ) + thresholdWidth, (Porky ) - thresholdWidth,  TotalDist);

    return BarAlpha;
}

float4 iigo_hoodieColor(float2 unscaledUV, float speed, float4 audiolinkData, float scale, float pork, float beef, float alpha, float4 color)
{
    unscaledUV.y = unscaledUV.y + sin(speed * audiolinkData.x);

    float2 UV = unscaledUV * scale; //

    float TotalDist = iigo_hoodieDistance( UV );

    float TotalDots = iigo_hoodieDots( UV , float(1.0));

    TotalDots = ((TotalDots) - (0.5));

    //TotalDist = max(TotalDots, TotalDist);

    //return float4(TotalDots.xxx, 1.0);

    float BarAlpha = iigo_hoodieTing( TotalDist, pork, audiolinkData.z, beef, audiolinkData.w);

    BarAlpha = max(BarAlpha, iigo_hoodieTingDots( TotalDots, pork, audiolinkData.z, beef, audiolinkData.w));

    float Alpha = BarAlpha * alpha; //

    return float4(color.rgb, Alpha);
}

float4 iigo_glitchFlipbook(float4 audioLinkData, float2 uv, UNITY_ARGS_TEX2DARRAY(textureArray))
{
    float3 UV1 = float3(uv.xy, floor(fmod(audioLinkData.y * 2, 5)));
    float3 UV2 = float3(uv.x + (sin(uv.y * 3000) / 80), uv.y + (sin(uv.y * 3000) / 160) , floor(fmod((audioLinkData.y * 2) - 1 , 5)));

    float4 flipbook  = UNITY_SAMPLE_TEX2DARRAY(textureArray, UV1);
    float4 flipbook2 = UNITY_SAMPLE_TEX2DARRAY(textureArray, UV2);

    if(AudioLinkIsAvailable())
    {
        flipbook = lerp(flipbook, flipbook2, smoothstep(0.9,1,audioLinkData.z));
    }
    else
    {
        flipbook = lerp(flipbook, flipbook2, smoothstep(0.9,1, fmod((((audioLinkData.x * 5) * sin(audioLinkData.x + 10)) * 4 * 5) , 1)));
    }

    return flipbook;
}

float3 iigo_shoeTexColor(float2 uv, float3 color1, float3 color2, float rotation)
{
    float Overlay = glsl_mod((((atan2(uv.x - 0.5,(1 - uv.y) - 0.5) * 0.15915494309189533576888376337251 /*OneOverTau*/) ) + rotation), 1);

    float InvertOverlay = glsl_mod((1 - (((atan2(uv.x - 0.5,(1 - uv.y) - 0.5) * 0.15915494309189533576888376337251 /*OneOverTau*/) ) + rotation)), 1);

    Overlay = min(Overlay , InvertOverlay) * 2;

    Overlay = smoothstep(0.0, 1.0, Overlay);

    Overlay = smoothstep(0.0, 1.0, Overlay);

    Overlay = smoothstep(0.0, 1.0, Overlay);

    float3 color = lerp(color1, color2, Overlay);

    return color;
}

float iigo_shoeTexAlpha(float2 uv)
{
    uv = (uv * 2.0) - 1.0;
    float dist = (uv.x * uv.x) + (uv.y * uv.y);
    float baseAlpha = float4(0.0, 0.0, 0.0, 0.0);
    float thresholdWidth = iigo_AA(dist.xx);
    float plusThreshold = dist + thresholdWidth;

    float alpha = baseAlpha;

    float alpha1 = float(1.0);
    alpha = lerp(alpha, alpha1, smoothstep(dist, plusThreshold, 1.0));   

    float alpha2 = float(0.0);
    alpha = lerp(alpha, alpha2, smoothstep(dist, plusThreshold, 0.7));

    return alpha;
}

float4 iigo_shoeTex(float2 uv, float3 color1, float3 color2, float rotation)
{
    float4 col = float4(0.0, 0.0, 0.0, 1.0);
    col.rgb = iigo_shoeTexColor(uv, color1, color2, rotation);
    col.a   = iigo_shoeTexAlpha(uv);
    return col;
}