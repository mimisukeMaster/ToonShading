Shader "Custom/Toon" {
    // エディタから触れる変数を宣言
    Properties {
        // 色を指定する変数
        _Color ("Color", Color) = (1,1,1,1)

        // テクスチャを指定する変数
        // 変数名(ラベル名, 型) = デフォルト値の白画像, {}はテクスチャ変数宣言のお作法
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        // 影の付き方を制御するテクスチャを指定する変数
        _RampTex ("Ramp", 2D) = "white" {}
    }
    
    // GPUに送るコードを記述するブロック
    // デバイス性能によって分ける為複数用意できる
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf ToonRamp
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _RampTex;

        struct Input {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        fixed4 LightingToonRamp (SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            half d = dot(s.Normal, lightDir)*0.5 + 0.5;
            fixed3 ramp = tex2D(_RampTex, fixed2(d, 0.5)).rgb;
            fixed4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * ramp;
            c.a = 0;
            return c;
        }

        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}