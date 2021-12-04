Shader "URP/CrossSection"
{
    Properties
    {
        [NoScaleOffset]Texture2D_749cf82b63f148329502ab7811174366("Albedo", 2D) = "white" {}
        Color_4937b32baf6848678c32e85a81b0ba8e("AlbedoColor", Color) = (1, 1, 1, 0)
        Vector3_Plane1_Position("Plane1_Position", Vector) = (0, 0.2, 0, 0)
        Vector3_Plane1_Normal("Plane1_Norrmal", Vector) = (0, 1, 0, 0)
        Vector3_Plane2_Position("Plane2_Position", Vector) = (0, -0.3, 0, 0)
        Vector3_Plane2_Normal("Plane2_Normal", Vector) = (0, -1, 0, 0)
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
            Blend One Zero
            ZTest LEqual
            ZWrite On

            Stencil {
                Ref 255
                CompBack Always
                PassBack Replace

                CompFront Always
                PassFront Zero
            }

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_749cf82b63f148329502ab7811174366);
            float4 _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.tex, _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_R_4 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.r;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_G_5 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.g;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_B_6 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.b;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_A_7 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.a;
            float4 _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0 = Color_4937b32baf6848678c32e85a81b0ba8e;
            float4 _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2;
            Unity_Multiply_float(_SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0, _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0, _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2);
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.BaseColor = (_Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_749cf82b63f148329502ab7811174366);
            float4 _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.tex, _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_R_4 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.r;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_G_5 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.g;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_B_6 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.b;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_A_7 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.a;
            float4 _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0 = Color_4937b32baf6848678c32e85a81b0ba8e;
            float4 _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2;
            Unity_Multiply_float(_SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0, _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0, _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2);
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.BaseColor = (_Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_749cf82b63f148329502ab7811174366);
            float4 _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.tex, _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_R_4 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.r;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_G_5 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.g;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_B_6 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.b;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_A_7 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.a;
            float4 _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0 = Color_4937b32baf6848678c32e85a81b0ba8e;
            float4 _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2;
            Unity_Multiply_float(_SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0, _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0, _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2);
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.BaseColor = (_Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_749cf82b63f148329502ab7811174366);
            float4 _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.tex, _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_R_4 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.r;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_G_5 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.g;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_B_6 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.b;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_A_7 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.a;
            float4 _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0 = Color_4937b32baf6848678c32e85a81b0ba8e;
            float4 _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2;
            Unity_Multiply_float(_SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0, _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0, _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2);
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.BaseColor = (_Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2.xyz);
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_749cf82b63f148329502ab7811174366);
            float4 _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.tex, _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_R_4 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.r;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_G_5 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.g;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_B_6 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.b;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_A_7 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.a;
            float4 _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0 = Color_4937b32baf6848678c32e85a81b0ba8e;
            float4 _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2;
            Unity_Multiply_float(_SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0, _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0, _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2);
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.BaseColor = (_Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1;
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_749cf82b63f148329502ab7811174366);
            float4 _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.tex, _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_R_4 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.r;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_G_5 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.g;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_B_6 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.b;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_A_7 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.a;
            float4 _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0 = Color_4937b32baf6848678c32e85a81b0ba8e;
            float4 _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2;
            Unity_Multiply_float(_SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0, _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0, _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2);
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.BaseColor = (_Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Texture2D_749cf82b63f148329502ab7811174366_TexelSize;
        float4 Color_4937b32baf6848678c32e85a81b0ba8e;
        float3 Vector3_Plane1_Position;
        float3 Vector3_Plane1_Normal;
        float3 Vector3_Plane2_Position;
        float3 Vector3_Plane2_Normal;
        float4 Color_27a03e4caca545619b0c0ce31fdd17b8;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(Texture2D_749cf82b63f148329502ab7811174366);
        SAMPLER(samplerTexture2D_749cf82b63f148329502ab7811174366);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Comparison_Greater_float(float A, float B, out float Out)
        {
            Out = A > B ? 1 : 0;
        }

        void Unity_Or_float(float A, float B, out float Out)
        {
            Out = A || B;
        }

        void BooleanToFloat_float(float Value, out float Out){
            Out = Value * 1;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0 = UnityBuildTexture2DStructNoScale(Texture2D_749cf82b63f148329502ab7811174366);
            float4 _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.tex, _Property_56d38c50a9004cdbaf587fb610b47a00_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_R_4 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.r;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_G_5 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.g;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_B_6 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.b;
            float _SampleTexture2D_1d41594b15694a208beb260386eebca9_A_7 = _SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0.a;
            float4 _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0 = Color_4937b32baf6848678c32e85a81b0ba8e;
            float4 _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2;
            Unity_Multiply_float(_SampleTexture2D_1d41594b15694a208beb260386eebca9_RGBA_0, _Property_6fac2698265c43ca84dbf4cae595fa7d_Out_0, _Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2);
            float3 _Property_eabed797313a4d9ba701d16ce019d075_Out_0 = Vector3_Plane1_Position;
            float3 _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_eabed797313a4d9ba701d16ce019d075_Out_0, _Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2);
            float3 _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0 = Vector3_Plane1_Normal;
            float _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2;
            Unity_DotProduct_float3(_Subtract_5dfb505c9b564d64a10936cc20367e65_Out_2, _Property_e0028a934c2345eaa52d08c65a5b4a82_Out_0, _DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2);
            float _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_2a58e8ee681349aebce99e11d5e9bd79_Out_2, 0, _Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2);
            float3 _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0 = Vector3_Plane2_Position;
            float3 _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2;
            Unity_Subtract_float3(IN.WorldSpacePosition, _Property_a7b7dbeb392746ecb102691d163b74d4_Out_0, _Subtract_56f54604d65841689966a9821d8c5e8f_Out_2);
            float3 _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0 = Vector3_Plane2_Normal;
            float _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2;
            Unity_DotProduct_float3(_Subtract_56f54604d65841689966a9821d8c5e8f_Out_2, _Property_1c25ebe0af2d456c8671afd9d0232dcc_Out_0, _DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2);
            float _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2;
            Unity_Comparison_Greater_float(_DotProduct_adcd8ef11ed54fa89bfc2cfedcbd4d1f_Out_2, 0, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2);
            float _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2;
            Unity_Or_float(_Comparison_a42706de8dc247a6816e3bf1f123bdc6_Out_2, _Comparison_8862dd7c879c499f8425ac52fce7accc_Out_2, _Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2);
            float _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            BooleanToFloat_float(_Or_6f9a7343291e4e1d94bd6fdef5e47176_Out_2, _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1);
            surface.BaseColor = (_Multiply_c0ba0425d0e34adeaac3b2b5289f41d8_Out_2.xyz);
            surface.Alpha = 0;
            surface.AlphaClipThreshold = _BooleanToFloatCustomFunction_b25dca6623ee4cdfad05c8488e92551a_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}