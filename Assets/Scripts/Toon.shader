Shader "Custom/Toon" {
    // エディタから触れる変数を宣言
    Properties {
        // 色を指定する変数
        _Color ("Color", Color) = (1,1,1,1)

        // ハイライトの色と閾値
        _HighColor ("Highlight Color", Color) = (1, 1, 1, 1)
        _HighThreshold ("Highlight Threshold", Range(0, 1)) = 0.8
        
        // 通常の色と閾値
        _NormalColor ("Normal Color", Color) = (1, 1, 1, 1)
        
        // 影の色と閾値
        _LowColor ("Shadow Color", Color) = (0.5, 0.5, 0.5, 1)
        _LowThreshold ("Shadow Threshold", Range(0, 1)) = 0.5
    }

    // GPUに送るコードを記述するブロック
    // デバイス性能によって分ける為複数用意できる
    SubShader {
        // 不透明オブジェクトとして描画するためのタグ
        Tags { "RenderType" = "Opaque" }
        // シェーダの切り替えのためのウエイトを設定（200は標準）
        LOD 100

        // ここからが本質的な処理
        CGPROGRAM

        // それぞれの処理の関数名を宣言しておく
        // pragma surface [サーフェース関数名] [ライティング関数名]
        // サーフェース関数: 色や模様を決める関数
        // ライティング関数: 光や影の計算をする関数(実際の名はLighting[ライティング関数名])
        #pragma surface surf ToonRamp
        
        // 使用するシェーダモデルのバージョン
        #pragma target 3.0

        // Propertiesで宣言したエディタ用変数を計算に使うためC言語に合わせ再宣言
        // fixed, fixed2, fixed3... はC#で言う所の float, Vector2(x, y), Vector3(r, g, b)...
        fixed4 _Color;
        fixed4 _NormalColor;
        fixed4 _HighColor;
        half _HighThreshold;
        fixed4 _LowColor;
        half _LowThreshold;

        // surfの引数を受け取るための構造体
        // 保守性の観点から構造体でまとめておく
        struct Input {
            float dummy;
        };

        // 独自のライティング関数を定義
        // 一般に、ライティング関数はLightingから始める必要がある（内部と規格を合わせるため）
        /// <summary>
        /// 独自のライティング関数
        /// </summary>
        /// <param name="s">表面の情報</param>
        /// <param name="lightDir">光源方向</param>
        /// <param name="atten">光の減衰係数</param>
        /// <returns>最終的な色</returns>
        fixed4 LightingToonRamp (SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            // 法線と光源方向との内積を計算し、範囲を -1.0 ~ 1.0 から 0.0 ~ 1.0 に変換
            half d = dot(s.Normal, lightDir) * 0.5 + 0.5;

            fixed3 ramp;
            if (d >= _HighThreshold) {
                ramp = _HighColor.rgb;
            } else if (d >= _LowThreshold) {
                ramp = _NormalColor.rgb;
            } else {
                ramp = _LowColor.rgb;
            }

            // 最終的な色を計算
            // s.Albedoにはsurf関数のo.Albedoが既に渡されている
            // _LightColor0は内部的に用意された変数で、シーンの光の色や強さの情報
            // 物体の色 * 光の色 * 影の色 でカラー乗算
            fixed4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * ramp;
            c.a = 0;
            return c;
        }

        /// <summary>
        /// 物体の表面の色だけを決める関数
        /// </summary>
        /// <param name="IN">UV座標データの構造体</param>
        /// <param name="o">結果を格納する構造体（Albedo, Normal, Alphaなどが入る）</param>
        /// <returns></returns>
        void surf (Input IN, inout SurfaceOutput o) {
            // 単色を指定する
            fixed4 c = _Color;

            // 結果格納
            // アルベドにRGB成分、アルファにA成分を入れる
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    // 上記のSubShaderが動かない場合に使うShaderを指定
    FallBack "Diffuse"
}