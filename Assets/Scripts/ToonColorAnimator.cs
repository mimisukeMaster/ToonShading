using System.Collections;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
public class ToonColorAnimator : MonoBehaviour
{
    [SerializeField]
    private Color highlightColor = Color.white;
    [SerializeField]
    private Color normalColor = Color.white;
    [SerializeField]
    private Color lowColor = Color.white;


    private Material targetMaterial;


    void Start()
    {
        // マテリアルを取得
        Renderer renderComponent = GetComponent<Renderer>();
        targetMaterial = renderComponent.material;

        // Shaderプロパティの各プロパティに適用
        targetMaterial.SetColor(Shader.PropertyToID("_HighColor"), highlightColor);
        targetMaterial.SetColor(Shader.PropertyToID("_NormalColor"), normalColor);
        targetMaterial.SetColor(Shader.PropertyToID("_LowColor"), lowColor);
    }
}