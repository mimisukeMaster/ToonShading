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
        // 描画の順番を指定するタグ（不透明）
        Tags { "RenderType" = "Opaque" }
        // シェーダの切り替えのためのウエイトを設定（200は標準）
        LOD 200
    
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
        sampler2D _MainTex;
        sampler2D _RampTex;

        // surfの引数を受け取るための構造体
        // 必要最低限の情報を入れた構造体を定義
        struct Input {
            float2 uv_MainTex;
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

            // tex2D(テクスチャ, 座標) でテクスチャから色を取る
            // fixed2(u, v)でUV座標（常に u, v ともに [0, 1] の範囲) を指定
            // _RampTexがカラーランプの役割を果たしdの位置に応じた色を返す(v座標は今回鑑みず中心の位置をとる)
            // .rgbで返り値のfixed4からRGB成分だけを抜き取る
            fixed3 ramp = tex2D(_RampTex, fixed2(d, 0.5)).rgb;

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
            // 設定した画像の色と、エディタで指定した色を掛け合わせる
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            // 結果格納
            // アルベドにRGB成分、アルファにA成分を入れる
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}