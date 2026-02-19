using UnityEngine;

public class HardEdgeModel : MonoBehaviour
{
    private void Awake()
    {
        // ゲーム開始時に、このオブジェクトの頂点カラーにソフトエッジ情報を埋め込む
        EmbedSoftEdgeToVertexColor(gameObject);
    }

    /// <summary>
    /// ソフトエッジ情報を頂点カラーに埋め込む
    /// </summary>
    private static void EmbedSoftEdgeToVertexColor(GameObject obj)
    {
        // 自分のMeshFilterを取得
        var meshFilter = obj.GetComponent<MeshFilter>();
        if (meshFilter == null) return;

        // sharedMeshではなくmeshにすることで、元のモデルデータを書き換えずに
        // このオブジェクト専用のメモリ上のコピーを使用する（安全策）
        var mesh = meshFilter.mesh;
        
        var normals = mesh.normals;
        var vertices = mesh.vertices;
        var vertexCount = mesh.vertexCount;

        // ソフトエッジ法線情報の生成
        var softEdges = new Color[normals.Length];

        // 全頂点を走査 (注意: 頂点数が多いモデルだと処理が重くなります)
        for (var i = 0; i < vertexCount; i++)
        {
            // 同じ位置にある頂点の法線を全部足し合わせる
            var softEdge = Vector3.zero;
            for (var j = 0; j < vertexCount; j++)
            {
                // 距離がほぼ0（同じ位置）なら
                var v = vertices[i] - vertices[j];
                if (v.sqrMagnitude < 1e-8f)
                {
                    softEdge += normals[j];
                }
            }
            // 正規化（長さを1にする）
            softEdge.Normalize();
            
            // 計算した「滑らかな法線」を、色のR,G,Bとして保存する
            // そのまま入れるとマイナス値が消滅するので、
            // (-1.0 ~ 1.0) の範囲を (0.0 ~ 1.0) にマッピング（圧縮）する
            Vector3 mappedEdge = softEdge * 0.5f + new Vector3(0.5f, 0.5f, 0.5f);
            
            softEdges[i] = new Color(mappedEdge.x, mappedEdge.y, mappedEdge.z, 0);
        }

        // メッシュの頂点カラーにセットする
        mesh.colors = softEdges;
    }
}